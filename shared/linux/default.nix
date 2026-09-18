{ ... }:
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
    ./computer-use.nix
  ];

  environment.variables.EDITOR = "emacs -Q -nw";

  more-nix-substituters = [ "https://cache.flox.dev" ];
  more-nix-trusted-public-keys = [
    "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
  ];
}
