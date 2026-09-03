{ config, pkgs, ... }:

let
  piNpmDir = "${config.home.homeDirectory}/.pi/npm";
in
{
  home.packages = [
    (pkgs.symlinkJoin {
      name = "pi-coding-agent";
      paths = [ pkgs.llm-agents.pi ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/pi \
          --set NPM_CONFIG_PREFIX "${piNpmDir}" \
          --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.nodejs_latest ]}
      '';
    })
    (pkgs.writeShellApplication {
      name = "install-pi-pkg";
      runtimeInputs = [ pkgs.bun ];
      text = ''
        if (( $# == 0 )); then
          echo "Usage: install-pi-pkg <package> [package...]" >&2
          exit 2
        fi

        export BUN_INSTALL_GLOBAL_DIR="${piNpmDir}"
        export BUN_INSTALL_BIN="${piNpmDir}/bin"
        exec bun add --global "$@"
      '';
    })
  ];
}
