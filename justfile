set dotenv-load

default:
    just --list

switch cmd="switch" *args="":
    #!/usr/bin/env sh
    set -e
    if [ "$(uname)" = "Darwin" ]; then
        # impure b/c hosts/Roberts-MacBook-Pro/packages.nix access abs path
        cd macos
        echo "building for darwin on $(hostname)"
        darwin-rebuild {{ cmd }} {{ args }} --impure --flake ".#$(hostname)"
    else
        # nixos-rebuild switch --flake . --use-remote-sudo
        bash -c 'sudo nixos-rebuild {{ cmd }} --impure {{ args }} |& nom'
    fi

switch-debug:
    just switch --show-trace --print-build-logs --verbose

build:
     nix build '/etc/nixos/#nixosConfigurations.titan-linux.config.system.build.toplevel --impure'


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

