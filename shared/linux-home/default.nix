{ config, pkgs, lib, user, nixosConfig, ... }:

{
  imports = [
    ../../macos/herdr-skill.nix
    ../home/agent-files.nix
    ./emacs.nix
    ./cli-proxy-api.nix
    ./devenv.nix
    ./devops.nix
    ./rust.nix
    ./gnome.nix
    ./freestyle.nix
    ./computer-use.nix
    ./packages.nix
    ../home/pi.nix
  ];

  home.username = "${user}";
  home.homeDirectory = "/home/${user}";
}
