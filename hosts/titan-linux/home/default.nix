{ config, pkgs, lib, user, ... }:

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
  home.username = "robert";
  home.homeDirectory = "/home/${user}";

  home.packages = with pkgs; [
    # helpful
    zip
    unzip
    gnused
    gnutar
    killall
    mullvad-vpn
    transmission_4-qt
    wineWowPackages.staging
    vlc
    drawio
  ];

  home.file.".config/karabiner".source = config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/mac/karabiner;
  home.file.".wezterm.lua".source = config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/.wezterm.lua;
  home.file.".gnupg".source = config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/.gnupg;
  home.file.".authinfo.gpg".source = config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/.authinfo.gpg;
  home.file.".aws".source = config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/.aws;
  home.file.".npmrc".source = config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/.npmrc;
  home.file.".style.yapf".source = config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/.style.yapf;
}
