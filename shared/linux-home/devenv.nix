{
  config,
  lib,
  pkgs,
  user,
  ...
}:

{
  imports = [
    ./command-line.nix
    ../home/agent-tools.nix
  ];

  home.file.".config/herdr-mirror".source =
    config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/herdr/herdr-mirror;
  home.file.".wezterm.lua".source =
    config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/.wezterm.lua;

  home.file.".config/ai-quotas/config.yaml".source =
    config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/ai/ai-quotas/config.yaml;

  # Run by agent-1 for now
  # services.agent-files = {
  #   enable = true;
  #   bucket = "agent-files";
  #   environmentFile = "/etc/nixos/shared/secrets/agent-files-r2.env";
  #   directory = "/home/${user}/projects/ai/.agent-files";
  # };

  programs.autojump = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
  };

  home.packages = with pkgs; [
    # shell / utils
    latest.wezterm
    latest.warp-terminal
    tealdeer
    just
    eza
    tree
    gnused
    gnutar
    jq
    fx
    entr
    tokei
    mkcert
    llm
    latest.shell-gpt
    mermaid-cli
    graphviz

    jujutsu
    (lazyjj.overrideAttrs (oldAttrs: {
      doCheck = false;
    }))
    git-crypt
    git-extras
    difftastic

    # useful python packages
    (pkgs.python312.withPackages (
      packages: with packages; [
        loguru
        requests
        pydantic
        polars
        matplotlib
        seaborn
        pdftotext
        tqdm
        networkx
      ]
    ))

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor
    nix-tree
    nil
    nixpkgs-fmt # nix language server
    nixfmt
    # attic-client
    cachix
    # devbox

    # Managed via cli-proxy-api.nix
    # llm-agents.claude-code
    # codex-cli

    llm-agents.antigravity-cli
    llm-agents.ccusage
    llm-agents.rtk
    herdr
    skillshare
    ast-outline
    ai-quotas
    worktrunk

    vale # prose linter
    vale-ls
  ];

  # npm global
  home.sessionPath = [
    "$HOME/npm/bin"
    "$HOME/.local/bin"
  ];

  # mkcert suuport
  home.file.".local/share/mkcert/rootCA-key.pem".source =
    config.lib.file.mkOutOfStoreSymlink /etc/nixos/shared/secrets/mkcert/rootCA-key.pem;
  home.file.".local/share/mkcert/rootCA.pem".source =
    config.lib.file.mkOutOfStoreSymlink /etc/nixos/shared/secrets/mkcert/rootCA.pem;
}
