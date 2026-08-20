{ config, pkgs, lib, user, nixosConfig, ... }:

{
  imports = [
    ../../macos/herdr-skill.nix
    ../home/agent-files.nix
    ../home/pi-local.nix
    ./emacs.nix
    ./devenv.nix
    ./devops.nix
    ./rust.nix
    ./gnome.nix
    ./freestyle.nix
    ./packages.nix
  ];

  home.username = "${user}";
  home.homeDirectory = "/home/${user}";
}
