{
  config,
  lib,
  pkgs,
  ...
}:

let
  moshiHook = pkgs.callPackage ../../custom/moshi-hook { };
  piPackages = [
    "git:github.com/DietrichGebert/ponytail"
    "npm:pi-agent-browser-native@${pkgs.agent-browser.piAgentBrowserNativeVersion}"
    "npm:@tintinweb/pi-subagents"
    "npm:pi-web-access"
    "npm:pi-mcp-adapter"
  ];
  piNpmDir = "${config.home.homeDirectory}/.pi/npm";
  piAgentDir = "${config.home.homeDirectory}/.pi/agent";
  piWebSearchConfig = "${piAgentDir}/web-search.json";
  braveSearchKey = "/etc/nixos/shared/secrets/brave-search.key";
  openrouterKey = "/etc/nixos/shared/secrets/openrouter.key";
  pi = pkgs.symlinkJoin {
    name = "pi-coding-agent";
    paths = [ pkgs.llm-agents.pi ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/pi \
        --set NPM_CONFIG_PREFIX "${piNpmDir}" \
        --set-default PI_CODING_AGENT_DIR "${piAgentDir}" \
        --prefix PATH : ${
          lib.makeBinPath [
            pkgs.agent-browser
            moshiHook
            pkgs.bun
            pkgs.git
            pkgs.herdr
            pkgs.llm-agents.rtk
            pkgs.nodejs_latest
          ]
        }
    '';
  };
in
{
  home.packages = [ pi ];

  home.file.".pi/agent/AGENTS.md" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/configs/ai/codex/AGENTS.md";
    force = true;
  };

  home.activation.configurePiAuth = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [[ -v DRY_RUN ]]; then
      echo "Would configure Pi to read the shared OpenRouter key"
    else
      ${pkgs.coreutils}/bin/mkdir -p "${piAgentDir}"
      pi_auth="${piAgentDir}/auth.json"
      pi_auth_source="$pi_auth"
      if [[ ! -e "$pi_auth_source" ]]; then
        pi_auth_source=/dev/null
      fi
      pi_auth_new="$(${pkgs.coreutils}/bin/mktemp "${piAgentDir}/auth.json.XXXXXX")"
      ${pkgs.jq}/bin/jq -s \
        --arg key ${lib.escapeShellArg "!${pkgs.coreutils}/bin/cat ${lib.escapeShellArg openrouterKey}"} \
        '(if length == 0 then {} else .[0] end) |
         .openrouter = {type: "api_key", key: $key}' \
        "$pi_auth_source" > "$pi_auth_new"
      ${pkgs.coreutils}/bin/chmod 600 "$pi_auth_new"
      ${pkgs.coreutils}/bin/mv "$pi_auth_new" "$pi_auth"
    fi
  '';

  home.activation.configurePi = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    pi_settings="${piAgentDir}/settings.json"
    pi_web_search="${piWebSearchConfig}"
    brave_search_key="${braveSearchKey}"

    if [[ -v DRY_RUN ]]; then
      echo "Would configure Pi packages and integrations in ${piAgentDir}"
    else
      ${pkgs.coreutils}/bin/mkdir -p "${piAgentDir}/extensions"

      if [[ ! -r "$brave_search_key" ]]; then
        echo "Brave Search key is not readable: $brave_search_key" >&2
        exit 1
      fi
      if ! ${pkgs.jq}/bin/jq -eRs 'gsub("\\s+$"; "") | length > 0' \
        "$brave_search_key" > /dev/null
      then
        echo "Brave Search key is empty: $brave_search_key" >&2
        exit 1
      fi

      pi_settings_new="$(${pkgs.coreutils}/bin/mktemp "${piAgentDir}/settings.json.XXXXXX")"

      if [[ -f "$pi_settings" ]]; then
        ${pkgs.jq}/bin/jq '.npmCommand = ["bun"]' "$pi_settings" > "$pi_settings_new"
      else
        ${pkgs.jq}/bin/jq -n '{ npmCommand: ["bun"] }' > "$pi_settings_new"
      fi

      ${pkgs.coreutils}/bin/mv "$pi_settings_new" "$pi_settings"

      pi_web_search_new="$(${pkgs.coreutils}/bin/mktemp "${piWebSearchConfig}.XXXXXX")"
      pi_web_search_source="$pi_web_search"
      if [[ ! -f "$pi_web_search_source" ]]; then
        pi_web_search_source="${config.home.homeDirectory}/.pi/web-search.json"
      fi
      if [[ -f "$pi_web_search_source" ]]; then
        ${pkgs.jq}/bin/jq --rawfile braveApiKey "$brave_search_key" \
          '.braveApiKey = ($braveApiKey | gsub("\\s+$"; ""))' \
          "$pi_web_search_source" > "$pi_web_search_new"
      else
        ${pkgs.jq}/bin/jq -n --rawfile braveApiKey "$brave_search_key" \
          '{ braveApiKey: ($braveApiKey | gsub("\\s+$"; "")) }' \
          > "$pi_web_search_new"
      fi
      ${pkgs.coreutils}/bin/chmod 600 "$pi_web_search_new"
      ${pkgs.coreutils}/bin/mv "$pi_web_search_new" "$pi_web_search"

      for package in ${lib.escapeShellArgs piPackages}; do
        PI_CODING_AGENT_DIR="${piAgentDir}" ${pi}/bin/pi install "$package"
      done

      PI_CODING_AGENT_DIR="${piAgentDir}" ${moshiHook}/bin/moshi-hook install --target pi
      PI_CODING_AGENT_DIR="${piAgentDir}" ${pkgs.herdr}/bin/herdr integration install pi
      PI_CODING_AGENT_DIR="${piAgentDir}" ${pkgs.llm-agents.rtk}/bin/rtk init --agent pi --global
    fi
  '';
}
