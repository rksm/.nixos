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
  ];

  environment.variables.EDITOR = "emacs -Q -nw";

  more-nix-substituters = [ "https://cuda-maintainers.cachix.org" ];
  more-nix-trusted-public-keys = [
    "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
  ];
}
