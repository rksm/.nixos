{ config, pkgs, lib, ... }:

{

  home.sessionVariables = {
    EDITOR = "emacsclient -n";
  };

  programs.emacs = {
    enable = true;

    package = pkgs.emacs;

    extraPackages = epkgs: with epkgs; [
      # for bootstrapping my .emacs.d
      nix-mode
      use-package
      dash
      dash-functional
      s
      quelpa
      quelpa-use-package

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
      company-go
      company-glsl
      company-qml
      company-shell
      company-terraform

      # init-shell.el
      direnv
      bash-completion
      with-editor
      flash-region
      fish-mode
      fish-completion

      # init-projects.el
      projectile
      editorconfig
      projectile-ripgrep
      helm-rg
      helm-projectile
      skeletor

      # init-snippets.el
      yasnippet
      helm-c-yasnippet

      # init-org.el
      org
      org-ql
      org-bullets
      org-download
      ob-mermaid
      # ob-rust
      # ob-typescript
      helm-org
      helm-org-ql
      htmlize
      ebib

      # init-vc.el
      transient
      magit
      magit-lfs
      magit-section
      gist
      git-link

      # init-helm.el
      helm
      # helm-ag
      helm-company
      helm-core
      helm-dictionary
      helm-eww
      helm-lsp
      helm-nixos-options
      # helm-swoop
      helm-system-packages
      helm-systemd
      # helm-themes

      # init-keybindings.el
      key-chord
      which-key
      move-text
      expand-region
      avy
      avy-zap
      ace-jump-mode
      ace-window
      multiple-cursors
      embark

      # init-web.el
      google-this
      # helm-google
      helm-wikipedia
      hnreader
      hydra
      helm-lobsters
      wttrin
      dictcc
      powerthesaurus
      mediawiki

      # init-natural-language.el
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

    # spell checking
    hunspell
    hunspellDicts.en_US
    hunspellDicts.de_DE

    # web / reading
    lynx # for rk/eww-extract-all-links

    # spell checking
    enchant
  ];

  programs.msmtp = {
    enable = true;
    package = pkgs.stable.msmtp;
  };
}
