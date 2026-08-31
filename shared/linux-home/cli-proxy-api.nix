{ pkgs, user, lib, ... }:

let
  claudeCode = pkgs.llm-agents.claude-code;
  cliProxyApi = pkgs.llm-agents.cli-proxy-api;
  cliProxyKey = "sk-local-cli-proxy-api";
  codexCli = pkgs.codex-cli;
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

  grokCommands = pkgs.runCommand "grok-commands"
    {
      nativeBuildInputs = [ pkgs.makeWrapper ];
    } ''
    mkdir -p "$out/bin"

    makeWrapper ${lib.getExe grokCli} "$out/bin/grok" \
      --run ${lib.escapeShellArg requireCliProxyApi} \
      --set GROK_AUTH_PROVIDER_COMMAND ${lib.escapeShellArg grokAuthProvider} \
      --set GROK_MODELS_BASE_URL "http://127.0.0.1:8317/v1"

    ln -s ${lib.getExe grokCli} "$out/bin/grok-plain"
  '';
in
{
  # Add another Claude, Codex, or xAI account:
  # cli-proxy-api -config ~/.cli-proxy-api/config.yaml -claude-login
  # cli-proxy-api -config ~/.cli-proxy-api/config.yaml -codex-login
  # cli-proxy-api -config ~/.cli-proxy-api/config.yaml -xai-login
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
    codexCommands
    claudeCommands
    grokCommands
  ];
}
