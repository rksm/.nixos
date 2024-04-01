{ config, pkgs, lib, user, nixosConfig, ... }:

{
  imports = [
    ./emacs.nix
    ./devenv.nix
    ./devops.nix
    ./rust.nix
    ./gnome.nix
    ./misc.nix
  ];

  home.stateVersion = "24.05";
  home.username = "${user}";
  home.homeDirectory = "/home/${user}";
}
