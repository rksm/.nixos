{ config, pkgs, lib, user, nixosConfig, ... }:

{
  imports = [
    ./emacs.nix
    ./devenv.nix
    ./devops.nix
    ./rust.nix
    ./gnome.nix
    ./packages.nix
    ./audio-input.nix
  ];

  home.username = "${user}";
  home.homeDirectory = "/home/${user}";
}
