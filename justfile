set dotenv-load

default:
    just --list

switch cmd="switch" *args="":
    #!/usr/bin/env sh
    set -e
    if [ "$(uname)" = "Darwin" ]; then
        # impure b/c hosts/Roberts-MacBook-Pro/packages.nix access abs path
        cd macos && sudo just switch {{ cmd }} {{ args }}
    else
        # nixos-rebuild switch --flake . --use-remote-sudo
        bash -o pipefail -c 'sudo nixos-rebuild {{ cmd }} --impure {{ args }} |& nom'
    fi

switch-debug:
    just switch --print-build-logs --verbose

# Deploy to the agent-files fleet hosts. Omit HOST for all hosts in agent-fleet/nix/fleet.json.
[working-directory: './agent-fleet']
agent-files-deploy host="":
    nix develop ..#agent-fleet -c just deploy {{ host }}

build-abort-on-warn:
    just switch build --option abort-on-warn --show-trace

update-moshi:
    nix shell --inputs-from . nixpkgs#curl -c ./custom/moshi-hook/update.sh

update-agent-browser:
    nix shell --inputs-from . nixpkgs#python3 -c python3 packages/agent-browser/update.py

update-computer-use:
    nix develop .#computer-use -c nix-update --flake --use-github-releases computer-use-linux
    just check-computer-use

check-computer-use:
    nix develop .#computer-use -c shellcheck packages/computer-use-linux/separate.sh packages/computer-use-linux/session.sh
    nix build .#computer-use-linux .#computer-use-desktop --no-link

[positional-arguments]
test-computer-use *args:
    #!/usr/bin/env bash
    set -euo pipefail
    desktop_package=$(nix build .#computer-use-desktop --no-link --print-out-paths)
    host_bus_id=$(gdbus call --session --dest org.freedesktop.DBus --object-path /org/freedesktop/DBus --method org.freedesktop.DBus.GetId)
    check_state=$(mktemp -d)
    trap 'rm -rf -- "$check_state"' EXIT
    XDG_STATE_HOME="$check_state" nix develop .#computer-use -c "$desktop_package/bin/computer-use-separate" --run python3 "$HOME/workspace/packages/computer-use-linux/check-session.py" "$host_bus_id" "$@"

pair-moshi:
    @./custom/moshi-hook/pair.sh

# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

[working-directory: './macos']
macos-switch:
    sudo just switch

update-ai:
    #!/usr/bin/env sh
    set -e

    root="$PWD"
    if [ "$(uname)" = "Darwin" ]; then
        cd macos
        set -- \
          ast-outline \
          herdr-nix \
          llm-agents \
          skillshare-nix \
          worktrunk-nix
        commit_message="macos: update ai"
    else
        set -- \
          ai-quotas \
          ast-outline \
          herdr-nix \
          llm-agents \
          skillshare-nix \
          worktrunk-nix
        commit_message="linux: update ai"
    fi

    nix flake update "$@"
    updated_files="flake.lock"
    if [ "$(uname)" != "Darwin" ]; then
        just update-agent-browser
        just update-computer-use
        # Pin the newest commit of the CLIProxyAPI dev branch.
        nix run --inputs-from . nixpkgs#nix-update -- --flake --version=branch=dev cliproxyapi
        updated_files="$updated_files packages/agent-browser/package.nix packages/cliproxyapi/package.nix packages/computer-use-linux/package.nix"
    fi
    if ! git diff --quiet HEAD -- $updated_files; then
        git add $updated_files
        git commit -m "$commit_message"
        cd "$root"
        just switch
        ./scripts/herdr-install
    else
        cd "$root"
    fi

    skillshare sync --all
    # This also bootstraps missing host plugins.
    just --justfile "$HOME/projects/ai/lessismore/justfile" sync

# stuff
#
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Update like this:
# # Update flake.lock
# nix flake update
# # Or replace only the specific input, such as home-manager:
# nix flake lock --update-input home-manager
# # Apply the updates
# sudo nixos-rebuild switch --flake .
up:
  nix flake update

# Update specific input
# usage: just upp i=home-manager
upp:
  nix flake lock --update-input $(i)

history:
  nix profile history --profile /nix/var/nix/profiles/system

repl:
  nix repl -f flake:nixpkgs

# then do :r
repll:
  nix repl -f repl.nix

clean:
  # remove all generations older than 7 days
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

gc:
  # garbage collect all unused nix store entries
  sudo nix-collect-garbage --delete-old
