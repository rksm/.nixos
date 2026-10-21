{ pkgs, ... }:
{
  imports = [
    ./linux.nix
    ./virtualization.nix
    ./fhs.nix
    ./nvidia.nix
    ./firefox.nix
    ./users.nix
    ./packages.nix
    ./ssh.nix
    ./moshi.nix
    ./docker.nix
    ./network.nix
    ./tailscale.nix
    ./k3s
    ./syncthing.nix
    ./mullvad.nix
    ./gaming.nix
    ./printing.nix
    ./postgres.nix
    ./audio-video-image-editing.nix
    ./nix-cache.nix
    ./nix.nix
    ./vibetyper.nix
    ./freestyle.nix
    ./hex.nix
    ./computer-use.nix
  ];

  environment.variables.EDITOR = toString (pkgs.writeShellScript "editor" ''
    # Over SSH, a running Emacs server would open the file on the desktop, not in this terminal.
    if [ -n "$SSH_CONNECTION" ]; then
      exec emacs -Q -nw "$@"
    fi
    exec emacsclient -q --alternate-editor="emacs -Q -nw" "$@"
  '');

  more-nix-substituters = [
    "https://cache.flox.dev"
    "https://cache.numtide.com" # for numtide/llm-agents
  ];
  more-nix-trusted-public-keys = [
    "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
    "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
  ];
}
