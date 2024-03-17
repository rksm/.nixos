{ config, pkgs, lib, user, ... }:

{

  home.sessionVariables = {
    EDITOR = "emacsclient -n";
  };

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: with epkgs; [
      nix-mode
      magit
      use-package
      dash
      dash-functional
      s
      modus-themes
      uuidgen
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
    nodejs # for language server / copilot
  ];
}
