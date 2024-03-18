{ config, pkgs, lib, user, ... }:

{
  imports = [
    ./devenv.nix
    ./devops.nix
    ./rust.nix
    ./gnome.nix
  ];

  home.stateVersion = "24.05";
  home.username = "robert";
  home.homeDirectory = "/home/${user}";

  home.packages = with pkgs; [
    # helpful
    zip
    unzip
    gnused
    gnutar
    killall
  ];
}
