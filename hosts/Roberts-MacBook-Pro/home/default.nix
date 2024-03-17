{ config, pkgs, lib, user, nixpkgs-firefox-darwin, ... }:

{
  nixpkgs.overlays = [ nixpkgs-firefox-darwin.overlay ];

  imports = [
    ./devenv.nix
    ./devops.nix
    #   ./rust.nix
    #   ./gnome.nix
    ./firefox.nix
  ];

  home.stateVersion = "24.05";
  home.username = "${user}";
  home.homeDirectory = "/Users/${user}";

  home.file.".config/karabiner".source = config.lib.file.mkOutOfStoreSymlink /Users/${user}/configs/mac/karabiner;
  home.file.".wezterm.lua".source = config.lib.file.mkOutOfStoreSymlink /Users/${user}/configs/.wezterm.lua;
  home.file.".gnupg".source = config.lib.file.mkOutOfStoreSymlink /Users/${user}/configs/.gnupg;
}
