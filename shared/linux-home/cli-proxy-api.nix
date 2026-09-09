{
  config,
  machine,
  pkgs,
  user,
  lib,
  ...
}:

let
  authDir = "/home/${user}/configs/ai/cli-proxy-api/auths/${machine}";

  claudeCode = pkgs.llm-agents.claude-code;
  cliProxyApi = pkgs.cliproxyapi;
  cliProxyKey = "sk-local-cli-proxy-api";
  codexCli = pkgs.llm-agents.codex;
  grokCli = pkgs.llm-agents.grok;
  grokAuthProvider = pkgs.writeShellScript "grok-cli-proxy-auth" ''
    ${pkgs.coreutils}/bin/printf '%s\n' ${lib.escapeShellArg cliProxyKey}
  '';

  requireCliProxyApi = ''
    if ! ${pkgs.systemd}/bin/systemctl --user is-active --quiet cli-proxy-api.service; then
      echo "CLIProxyAPI is not running." >&2
      echo "Check it with: systemctl --user status cli-proxy-api.service" >&2
      echo "View logs with: journalctl --user -u cli-proxy-api.service" >&2
      exit 1
    fi
  '';

  claudeCommands =
    pkgs.runCommand "claude-commands"
      {
        nativeBuildInputs = [ pkgs.makeWrapper ];
      }
      ''
        mkdir -p "$out/bin"

        makeWrapper ${lib.getExe claudeCode} "$out/bin/claude" \
          --run ${lib.escapeShellArg requireCliProxyApi} \
          --unset ANTHROPIC_API_KEY \
          --set ANTHROPIC_BASE_URL "http://127.0.0.1:8317" \
          --set ANTHROPIC_AUTH_TOKEN ${lib.escapeShellArg cliProxyKey}

        makeWrapper "$out/bin/claude" "$out/bin/claude-gpt" \
          --add-flag "--dangerously-skip-permissions" \
          --set CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY "1" \
          --set ANTHROPIC_MODEL "gpt-6-astra-fast(high)" \
          --set ANTHROPIC_DEFAULT_OPUS_MODEL "gpt-6-astra(high)" \
          --set ANTHROPIC_DEFAULT_FABLE_MODEL "gpt-6-astra(high)" \
          --set ANTHROPIC_DEFAULT_SONNET_MODEL "gpt-5.6-sol" \
          --set ANTHROPIC_DEFAULT_HAIKU_MODEL "gpt-5.6-luna" \
          --set CLAUDE_CODE_SUBAGENT_MODEL "gpt-5.6-sol"

        ln -s ${lib.getExe claudeCode} "$out/bin/claude-plain"
      '';

  codexCommands =
    pkgs.runCommand "codex-commands"
      {
        nativeBuildInputs = [ pkgs.makeWrapper ];
      }
      ''
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

  grokCommands =
    pkgs.runCommand "grok-commands"
      {
        nativeBuildInputs = [ pkgs.makeWrapper ];
      }
      ''
        mkdir -p "$out/bin"

        makeWrapper ${lib.getExe grokCli} "$out/bin/grok" \
          --run ${lib.escapeShellArg requireCliProxyApi} \
          --set GROK_AUTH_PROVIDER_COMMAND ${lib.escapeShellArg grokAuthProvider} \
          --set GROK_MODELS_BASE_URL "http://127.0.0.1:8317/v1"

        ln -s ${lib.getExe grokCli} "$out/bin/grok-plain"
      '';
in
{
  # Every host reads the same synced config.yaml, and CLIProxyAPI does not expand
  # variables in auth-dir, so config.yaml names ~/.cli-proxy-api/auths and this
  # symlink points that at one directory per host under ~/configs. Each host then
  # owns its credential files instead of overwriting the other hosts' copies.
  #
  # Give each host its own login per provider. A provider rotates the refresh
  # token on every refresh and revokes the previous one, so two hosts holding
  # copies of one grant lock each other out however the files are stored.
  # cli-proxy-api -config ~/.cli-proxy-api/config.yaml -claude-login
  # cli-proxy-api -config ~/.cli-proxy-api/config.yaml -codex-login
  # cli-proxy-api -config ~/.cli-proxy-api/config.yaml -xai-login
  home.activation.cliProxyApiAuthDir = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
    run ${pkgs.coreutils}/bin/mkdir -p ${lib.escapeShellArg authDir}
  '';

  home.file.".cli-proxy-api/auths" = {
    source = config.lib.file.mkOutOfStoreSymlink authDir;
    force = true;
  };

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

  home.packages = [
    cliProxyApi
    grokCommands
    codexCommands
    claudeCommands
  ];
}
