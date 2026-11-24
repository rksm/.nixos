{ config, pkgs, lib, user, nixosConfig, ... }:

{
  imports = [
    ../home/agent-files.nix
    ./emacs.nix
    ../home/cli-proxy-api.nix
    ./devenv.nix
    ./devops.nix
    ./rust.nix
    ./gnome.nix
    ./freestyle.nix
    ./computer-use.nix
    ./packages.nix
    ../home/pi.nix
    ../home/pi-herdr.nix
  ];

  home.username = "${user}";
  home.homeDirectory = "/home/${user}";
}
