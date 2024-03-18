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

  home.file.".config/karabiner".source = config.lib.file.mkOutOfStoreSymlink /Users/${user}/configs/mac/karabiner;
  home.file.".wezterm.lua".source = config.lib.file.mkOutOfStoreSymlink /Users/${user}/configs/.wezterm.lua;
  home.file.".gnupg".source = config.lib.file.mkOutOfStoreSymlink /Users/${user}/configs/.gnupg;
  home.file.".authinfo.gpg".source = config.lib.file.mkOutOfStoreSymlink /Users/${user}/configs/.authinfo.gpg;
  home.file.".aws".source = config.lib.file.mkOutOfStoreSymlink /Users/${user}/configs/.aws;
  home.file.".npmrc".source = config.lib.file.mkOutOfStoreSymlink /Users/${user}/configs/.npmrc;
  home.file.".style.yapf".source = config.lib.file.mkOutOfStoreSymlink /Users/${user}/configs/.style.yapf;
}
