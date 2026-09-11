{
  config,
  lib,
  pkgs,
  user,
  ...
}:

{
  imports = [ ./command-line.nix ];

  home.file.".config/herdr-mirror".source =
    config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/herdr/herdr-mirror;
  home.file.".wezterm.lua".source =
    config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/.wezterm.lua;

  home.file.".config/ai-quotas/config.yaml".source =
    config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/ai/ai-quotas/config.yaml;

  # Skillshare needs real source directories. Codex needs real SKILL.md files.
  # These three directories belong to their packages and refresh on activation.
  home.activation.copyPackagedSkills = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    skills_dir="${config.home.homeDirectory}/projects/ai/skillshare/skills"
    run mkdir -p "$skills_dir/fastmail"
    run ${pkgs.rsync}/bin/rsync -rLpt --chmod=Du+w --delete \
      "${pkgs.agent-browser}/skills/agent-browser/" "$skills_dir/agent-browser/"
    run ${pkgs.rsync}/bin/rsync -rLpt --chmod=Du+w --delete \
      "${pkgs.fastmail-cli}/share/fm/skills/review-email/" "$skills_dir/fastmail/review-email/"
    run ${pkgs.rsync}/bin/rsync -rLpt --chmod=Du+w --delete \
      "${pkgs.slackcli}/share/slackcli/skills/slackcli/" "$skills_dir/slackcli/"
    run ${pkgs.gnused}/bin/sed -i '1a\
    # Managed by /etc/nixos/shared/linux-home/devenv.nix.\
    # Do not edit this copy. Home Manager overwrites it on activation.\
    # Change the package definition under /etc/nixos/packages instead.' \
      "$skills_dir/agent-browser/SKILL.md" \
      "$skills_dir/fastmail/review-email/SKILL.md" \
      "$skills_dir/slackcli/SKILL.md"
  '';

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
    agent-browser
    fastmail-cli
    slackcli
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
