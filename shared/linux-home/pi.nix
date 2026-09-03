{
  config,
  lib,
  pkgs,
  ...
}:

let
  # pi-agent-browser-native validates agent-browser against an exact capability
  # baseline and rejects other versions at runtime. This pin follows the
  # managed extension, not the latest independent agent-browser release. See
  # docs/2026-09-03_integrate-pi.org for the paired upgrade procedure.
  agentBrowserVersion = "0.34.0";
  agentBrowser = pkgs.stdenvNoCC.mkDerivation {
    pname = "agent-browser";
    version = agentBrowserVersion;

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/agent-browser/-/agent-browser-${agentBrowserVersion}.tgz";
      hash = "sha256-pHRPsYnlmEZ6vPs6zd4HEY2eXLQ9w7MXJ/hpr0651Zg=";
    };

    nativeBuildInputs = [
      pkgs.autoPatchelfHook
      pkgs.makeWrapper
    ];
    dontUnpack = true;

    installPhase = ''
      runHook preInstall
      tar -xzf "$src" \
        package/bin/agent-browser-linux-x64 \
        package/skill-data \
        package/skills
      install -Dm755 package/bin/agent-browser-linux-x64 $out/bin/agent-browser
      cp -r package/skill-data package/skills $out/
      runHook postInstall
    '';

    postFixup = ''
      wrapProgram $out/bin/agent-browser \
        --set AGENT_BROWSER_EXECUTABLE_PATH ${pkgs.chromium}/bin/chromium
    '';

    meta = {
      description = "Headless browser automation CLI for AI agents";
      homepage = "https://github.com/vercel-labs/agent-browser";
      license = lib.licenses.asl20;
      mainProgram = "agent-browser";
      platforms = [ "x86_64-linux" ];
    };
  };
  moshiHook = pkgs.callPackage ../../custom/moshi-hook { };
  piPackages = [
    "git:github.com/DietrichGebert/ponytail"
    "npm:pi-agent-browser-native"
    "npm:@tintinweb/pi-subagents"
    "npm:pi-web-access"
  ];
  piNpmDir = "${config.home.homeDirectory}/.pi/npm";
  piAgentDir = "${config.home.homeDirectory}/.pi/agent";
  piWebSearchConfig = "${config.home.homeDirectory}/.pi/web-search.json";
  braveSearchKey = "/etc/nixos/shared/secrets/brave-search.key";
  pi = pkgs.symlinkJoin {
    name = "pi-coding-agent";
    paths = [ pkgs.llm-agents.pi ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/pi \
        --set NPM_CONFIG_PREFIX "${piNpmDir}" \
        --prefix PATH : ${
          lib.makeBinPath [
            agentBrowser
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
  home.packages = [
    agentBrowser
    pi
  ];

  home.file.".pi/agent/AGENTS.md" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/configs/ai/codex/AGENTS.md";
    force = true;
  };

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
      if [[ -f "$pi_web_search" ]]; then
        ${pkgs.jq}/bin/jq --rawfile braveApiKey "$brave_search_key" \
          '.braveApiKey = ($braveApiKey | gsub("\\s+$"; ""))' \
          "$pi_web_search" > "$pi_web_search_new"
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
