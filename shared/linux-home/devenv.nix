{ config, pkgs, user, lib, ... }:

let
  claudeCode = pkgs.llm-agents.claude-code;
  cliProxyApi = pkgs.llm-agents.cli-proxy-api;
  cliProxyKey = "sk-local-cli-proxy-api";
  codexCli = pkgs.codex-cli;

  requireCliProxyApi = ''
    if ! ${pkgs.systemd}/bin/systemctl --user is-active --quiet cli-proxy-api.service; then
      echo "CLIProxyAPI is not running." >&2
      echo "Check it with: systemctl --user status cli-proxy-api.service" >&2
      echo "View logs with: journalctl --user -u cli-proxy-api.service" >&2
      exit 1
    fi
  '';

  claudeCommands = pkgs.runCommand "claude-commands"
    {
      nativeBuildInputs = [ pkgs.makeWrapper ];
    } ''
    mkdir -p "$out/bin"

    makeWrapper ${lib.getExe claudeCode} "$out/bin/claude" \
      --run ${lib.escapeShellArg requireCliProxyApi} \
      --unset ANTHROPIC_API_KEY \
      --set ANTHROPIC_BASE_URL "http://127.0.0.1:8317" \
      --set ANTHROPIC_AUTH_TOKEN ${lib.escapeShellArg cliProxyKey}

    ln -s ${lib.getExe claudeCode} "$out/bin/claude-plain"
  '';

  codexCommands = pkgs.runCommand "codex-commands"
    {
      nativeBuildInputs = [ pkgs.makeWrapper ];
    } ''
    mkdir -p "$out/bin"

    makeWrapper ${lib.getExe codexCli} "$out/bin/codex" \
      --run ${lib.escapeShellArg requireCliProxyApi} \
      --set CLI_PROXY_API_KEY ${lib.escapeShellArg cliProxyKey} \
      --add-flag "-c" \
      --add-flag ${lib.escapeShellArg ''model_provider="cli_proxy_api"''} \
      --add-flag "-c" \
      --add-flag ${lib.escapeShellArg ''model_providers.cli_proxy_api.name="CLIProxyAPI"''} \
      --add-flag "-c" \
      --add-flag ${lib.escapeShellArg ''model_providers.cli_proxy_api.base_url="http://127.0.0.1:8317/v1"''} \
      --add-flag "-c" \
      --add-flag ${lib.escapeShellArg ''model_providers.cli_proxy_api.env_key="CLI_PROXY_API_KEY"''} \
      --add-flag "-c" \
      --add-flag ${lib.escapeShellArg ''model_providers.cli_proxy_api.wire_api="responses"''}

    ln -s ${lib.getExe codexCli} "$out/bin/codex-plain"
  '';
in
{
  home.file.".config/herdr".source = config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/herdr;
  home.file.".config/herdr-mirror".source = config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/herdr/herdr-mirror;
  home.file.".wezterm.lua".source = config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/.wezterm.lua;
  home.file.".gnupg".source = config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/.gnupg;
  home.file.".authinfo.gpg".source = config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/.authinfo.gpg;
  home.file.".aws".source = config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/.aws;
  home.file.".npmrc".source = config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/.npmrc;
  home.file.".style.yapf".source = config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/.style.yapf;
  home.file.".config/vale".source = config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/vale;

  home.file.".config/skillshare/config.yaml".source = config.lib.file.mkOutOfStoreSymlink /home/${user}/projects/ai/skillshare/config.yaml;
  home.file.".config/ai-quotas/config.yaml".source = config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/ai/ai-quotas/config.yaml;
  home.file.".cli-proxy-api/config.yaml" = {
    source = config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/ai/cli-proxy-api/config.yaml;
    force = true;
  };
  home.file.".codex/config.toml".source = config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/ai/codex/config.toml;
  home.file.".codex/config.toml".force = true;
  home.file.".codex/AGENTS.md".source = config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/ai/codex/AGENTS.md;
  home.file.".codex/AGENTS.md".force = true;
  home.file."bin/start.sh".source = config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/start.sh;
  home.file."bin/start.sh".force = true;

  home.activation.linkClaudeSettings =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p "$HOME/.claude"
      $DRY_RUN_CMD ln -sfn "../configs/ai/claude/settings.json" "/home/${user}/.claude/settings.json"
      $DRY_RUN_CMD ln -sfn "../configs/ai/claude/CLAUDE.md" "/home/${user}/.claude/CLAUDE.md"
    '';

  # Add another Claude or Codex account:
  # cli-proxy-api -config ~/.cli-proxy-api/config.yaml -claude-login
  # cli-proxy-api -config ~/.cli-proxy-api/config.yaml -codex-login
  systemd.user.services.cli-proxy-api = {
    Unit.Description = "CLIProxyAPI";
    Service = {
      Type = "simple";
      ExecStart = "${lib.getExe cliProxyApi} -config /home/${user}/.cli-proxy-api/config.yaml";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };

  # Run by agent-1 for now
  # services.agent-files = {
  #   enable = true;
  #   bucket = "agent-files";
  #   environmentFile = "/etc/nixos/shared/secrets/agent-files-r2.env";
  #   directory = "/home/${user}/projects/ai/.agent-files";
  # };

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
      { name = "myfish"; src = config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/fish; }
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
    latest.wezterm
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
    latest.shell-gpt
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
    nixfmt
    # attic-client
    cachix
    # devbox

    claudeCommands
    llm-agents.antigravity-cli
    llm-agents.cli-proxy-api
    llm-agents.hermes-agent
    llm-agents.ccusage
    llm-agents.rtk
    herdr
    codexCommands
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
  home.file.".local/share/mkcert/rootCA-key.pem".source = config.lib.file.mkOutOfStoreSymlink /etc/nixos/shared/secrets/mkcert/rootCA-key.pem;
  home.file.".local/share/mkcert/rootCA.pem".source = config.lib.file.mkOutOfStoreSymlink /etc/nixos/shared/secrets/mkcert/rootCA.pem;
}
