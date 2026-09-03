{
  config,
  lib,
  pkgs,
  ...
}:

let
  piPackages = [
    "git:github.com/DietrichGebert/ponytail"
    "npm:pi-agent-browser-native"
  ];
  piNpmDir = "${config.home.homeDirectory}/.pi/npm";
  piAgentDir = "${config.home.homeDirectory}/.pi/agent";
  pi = pkgs.symlinkJoin {
    name = "pi-coding-agent";
    paths = [ pkgs.llm-agents.pi ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/pi \
        --set NPM_CONFIG_PREFIX "${piNpmDir}" \
        --prefix PATH : ${
          lib.makeBinPath [
            pkgs.bun
            pkgs.nodejs_latest
          ]
        }
    '';
  };
in
{
  home.packages = [
    pkgs.llm-agents.agent-browser
    pi
  ];

  home.activation.installPiPackages = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    pi_settings="${piAgentDir}/settings.json"

    if [[ -v DRY_RUN ]]; then
      echo "Would configure Bun and install Pi packages in ${piAgentDir}"
    else
      mkdir -p "${piAgentDir}"
      pi_settings_new="$(${pkgs.coreutils}/bin/mktemp "${piAgentDir}/settings.json.XXXXXX")"

      if [[ -f "$pi_settings" ]]; then
        ${pkgs.jq}/bin/jq '.npmCommand = ["bun"]' "$pi_settings" > "$pi_settings_new"
      else
        ${pkgs.jq}/bin/jq -n '{ npmCommand: ["bun"] }' > "$pi_settings_new"
      fi

      mv "$pi_settings_new" "$pi_settings"

      for package in ${lib.escapeShellArgs piPackages}; do
        ${pi}/bin/pi install "$package"
      done
    fi
  '';
}
