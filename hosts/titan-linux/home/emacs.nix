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
      use-package
      dash
      dash-functional
      s

      # pdf
      pdf-tools
      org-pdftools

      # email
      mu4e

      # init-defaults.el
      adaptive-wrap
      flycheck

      # init-windows.el
      shackle
      dedicated
      diminish

      # init-undo.el
      undo-fu

      # init-autocomplete.el
      company

      # init-projects.el
      projectile
      editorconfig
      projectile-ripgrep
      helm-rg
      helm-projectile
      skeletor

      # init-snippets.el
      yasnippet

      # init-org.el
      org
      org-bullets
      org-download
      ob-mermaid
      # ob-rust
      # ob-typescript
      helm-org
      helm-org-rifle
      htmlize

      # init-vc.el
      magit
      magit-lfs
      gist
      git-link

      # init-helm.el
      helm
      helm-ag
      helm-company
      helm-core
      helm-dictionary
      helm-eww
      helm-lsp
      helm-nixos-options
      helm-swoop
      helm-system-packages
      helm-systemd
      helm-themes

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
