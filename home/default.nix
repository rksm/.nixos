{ config, pkgs, lib, ... }:

{
  imports = [
    ./devenv.nix
    ./devops.nix
    ./rust.nix
    ./gnome.nix
  ];

  home.stateVersion = "24.05";
  home.username = "robert";
  home.homeDirectory = "/home/robert";

  home.packages = with pkgs; [
    # helpful
    zip
    unzip
    gnused
    gnutar
    killall
  ];
}
