{ config, pkgs, user, ... }:

{
  home.file.".wezterm.lua".source = config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/.wezterm.lua;
  home.file.".gnupg".source = config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/.gnupg;
  home.file.".authinfo.gpg".source = config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/.authinfo.gpg;
  home.file.".aws".source = config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/.aws;
  home.file.".npmrc".source = config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/.npmrc;
  home.file.".style.yapf".source = config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/.style.yapf;

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
      { name = "myfish"; src = /home/${user}/configs/fish; }
    ];
  };

  home.file.".local/share/fish/fish_history".source = config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/fish_history.linux;


  # find missing packages
  # https://discourse.nixos.org/t/command-not-found-unable-to-open-database/3807/4
  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
  };

  programs.git = {
    enable = true;
    includes = [
      { path = "~/configs/git/.gitconfig"; }
    ];
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };

  home.packages = with pkgs; [
    # shell / utils
    wezterm
    latest.warp-terminal
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
    tokei
    mkcert
    llm
    shell-gpt
    mermaid-cli
    graphviz

    jujutsu
    (lazyjj.overrideAttrs (oldAttrs: { doCheck = false; }))
    git-crypt
    git-extras
    difftastic

    # useful python packages
    (pkgs.python312.withPackages (packages: with packages; [
      loguru
      requests
      pydantic
      polars
      matplotlib
      seaborn
      pdftotext
      tqdm
      networkx
    ]))

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor
    nix-tree
    nil
    nixpkgs-fmt # nix language server
    nixfmt-rfc-style
    # attic-client
    cachix
    # devbox

    # jetbrains.rust-rover
    # ai.aider-chat
    code-cursor
    claude-code
    codex-cli
  ];

  # npm global
  home.sessionPath = [
    "$HOME/npm/bin"
    "$HOME/.local/bin"
  ];

  # mkcert suuport
  home.file.".local/share/mkcert/rootCA-key.pem".source = config.lib.file.mkOutOfStoreSymlink /etc/nixos/shared/secrets/mkcert/rootCA-key.pem;
  home.file.".local/share/mkcert/rootCA.pem".source = config.lib.file.mkOutOfStoreSymlink /etc/nixos/shared/secrets/mkcert/rootCA.pem;
}
