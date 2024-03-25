# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, options, user, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./firefox.nix
    ./users.nix
    ./packages.nix
    ./linux.nix
    ./docker.nix
    ./infra.nix
    ./fhs.nix
    ./syncthing.nix
    ./virtualization.nix
  ];

  system.stateVersion = "24.05";
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      trusted-users = [ "root" user ];

      experimental-features = [ "flakes" "nix-command" ];

      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
}
