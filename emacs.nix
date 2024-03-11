# home.sessionVariables = {
#   EDITOR = "emacs";
# };

# programs.emacs = {
#   enable = true;
#   extraPackages = epkgs: [
#     epkgs.nix-mode
#     epkgs.magit
#   ];
# };

# environment.systemPackages = with pkgs; [
#   emacs

{ config, pkgs, ... }:

{
  nixpkgs.overlays = [
    (import (builtins.fetchGit {
      url = "https://github.com/nix-community/emacs-overlay.git";
      ref = "master";
      rev = "a230393bb7e2db667c63c3f5c279a6e26d8b1c5a";
    }))
  ];

  environment.systemPackages = with pkgs;
    [
      emacs
      ((emacsPackagesFor emacs-pgtk).emacsWithPackages (
        epkgs: [ epkgs.use-package epkgs.dash epkgs.s ]
      ))
    ];

  # environment.systemPackages = with pkgs; [
  #   emacs

  #   (emacsWithPackagesFromUsePackage {
  #     package = emacs-unstable;
  #     config = /home/robert/.emacs.d/init.el;
  #     defaultInitFile = true;

  #     extraEmacsPackages = epkgs: [
  #       epkgs.use-package
  #       epkgs.dash
  #       epkgs.s
  #     ];

  #     # # Optionally override derivations.
  #     # override = epkgs: epkgs // {
  #     #   somePackage = epkgs.melpaPackages.somePackage.overrideAttrs(old: {
  #     #      # Apply fixes here
  #     #   });
  #     # };
  #   })
  # ];

  services.emacs.package = pkgs.emacs-unstable;
  services.emacs.enable = true;
}
