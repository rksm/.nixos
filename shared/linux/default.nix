# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, options, user, ... }:
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
    ./docker.nix
    ./network.nix
    ./tailscale.nix
    ./k3s
    ./syncthing.nix
    ./mullvad.nix
    ./gaming.nix
    ./printing.nix
  ];

  system.stateVersion = "24.05";
  nixpkgs.config.allowUnfree = true;
  environment.variables.EDITOR = "emacs -Q -nw";

  nix = {
    settings = {
      trusted-users = [ "root" user ];

      experimental-features = [ "flakes" "nix-command" ];

      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
        "https://cuda-maintainers.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];
    };
  };
}
