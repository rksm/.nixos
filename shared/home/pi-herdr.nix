# Herdr's hooks for Pi, for a machine whose Pi agents run in Herdr panes. It
# goes with ./pi.nix.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  piAgentDir = import ./pi-agent-dir.nix { inherit config pkgs; };
in
{
  # Herdr reports Pi as blocked only when another extension says so.
  home.file."${lib.removePrefix "${config.home.homeDirectory}/" piAgentDir}/extensions/herdr-blocked.ts".source =
    ./pi-extensions/herdr-blocked.ts;

  # After ./pi.nix made the folder.
  home.activation.installHerdrPiHooks = lib.hm.dag.entryAfter [ "configurePiAuth" ] ''
    if [[ -v DRY_RUN ]]; then
      echo "Would install Herdr's hooks for Pi"
    else
      PI_CODING_AGENT_DIR="${piAgentDir}" ${pkgs.herdr}/bin/herdr integration install pi
    fi
  '';
}
