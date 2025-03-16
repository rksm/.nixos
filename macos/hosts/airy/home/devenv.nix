{ config, pkgs, lib, user, ... }:

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
      magit
      magit-lfs
      magit-section
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
      helm-google
      helm-wikipedia
      hnreader
      hydra
      helm-lobsters
      wttrin
      dictcc
      powerthesaurus
      mediawiki
    ];
  };

  programs.git = {
    enable = true;
    includes = [
      { path = "~/configs/git/.gitconfig"; }
    ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    # enableFishIntegration = true;
    # enableBashIntegration = true;
  };

  programs.autojump = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      if [ -f $HOME/configs/.bashrc ];
      then
        source $HOME/configs/.bashrc
      fi
    '';
  };

  programs.fish = {
    enable = true;
    shellInitLast = ''
      set -gx OMF_PATH "${pkgs.oh-my-fish}/share/oh-my-fish"
      source $OMF_PATH/init.fish
      source $HOME/configs/fish/config.fish
    '';

    plugins = [
      { name = "myfish"; src = /Users/${user}/configs/fish; }
    ];
  };

  # find missing packages
  # https://discourse.nixos.org/t/command-not-found-unable-to-open-database/3807/4
  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
  };

  programs.k9s = {
    enable = true;
  };

  home.packages = with pkgs; [
    # shell / utils
    # wezterm
    oh-my-fish
    tealdeer
    just
    eza
    fzf
    tree
    gnused
    gnutar
    jq
    fx
    entr
    git-crypt

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor
    nix-tree
    nil
    nixpkgs-fmt # nix language server

    # emacs
    tree-sitter-grammars.tree-sitter-yaml
    silver-searcher
    nodejs_latest # for language server / copilot
  ];
}
