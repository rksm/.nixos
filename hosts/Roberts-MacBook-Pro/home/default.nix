{ config, pkgs, lib, user, ... }:

{
 imports = [
     ./devenv.nix
  #   ./devops.nix
  #   ./rust.nix
  #   ./gnome.nix
  ];

  home.stateVersion = "24.05";
  home.username = "${user}";
  home.homeDirectory = "/Users/${user}";

            programs.firefox = {
              enable = true;
              package = pkgs.firefox-bin;
            };

  home.packages = with pkgs; [
    # helpful
    zip
    unzip
    gnused
    gnutar
    killall
  ];
}