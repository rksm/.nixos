{ config, pkgs, lib, user, nixosConfig, ... }:

{
  imports = [
    ../../macos/herdr-skill.nix
    ./emacs.nix
    ./devenv.nix
    ./devops.nix
    ./rust.nix
    ./gnome.nix
    ./packages.nix
  ];

  home.username = "${user}";
  home.homeDirectory = "/home/${user}";
}
