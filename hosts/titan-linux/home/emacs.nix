{ config, pkgs, lib, ... }:

{

  home.sessionVariables = {
    EDITOR = "emacsclient -n";
  };

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: with epkgs; [
      # for bootstrapping my .emacs.d
      nix-mode
      magit
      use-package
      dash
      dash-functional
      s

      # pdf
      pdf-tools
      org-pdftools

      # email
      mu4e
    ];
  };

  home.packages = with pkgs; [
    tree-sitter-grammars.tree-sitter-yaml
    silver-searcher

    # for language server / copilot
    nodejs

    # email
    mu
    isync # aka mbsync
  ];
}
