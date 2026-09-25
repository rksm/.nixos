{
  config,
  lib,
  pkgs,
  ...
}:

let
  skillSource = pkgs.runCommand "herdr-skill.md" { nativeBuildInputs = [ pkgs.patch ]; } ''
    cp ${pkgs.herdr.src}/skills/herdr/SKILL.md "$out"
    chmod u+w "$out"
    # Remove each replacement once both pinned Herdr sources include its fix.
    substituteInPlace "$out" \
      --replace-fail \
        'If the agent is blocked during startup, the command returns `agent_not_ready` immediately but keeps the name available for `agent read` and `agent send-keys`. Wait until the agent becomes idle before prompting it.' \
        'If Herdr recognizes a blocked startup dialog, the command returns `agent_not_ready` immediately but keeps the name available for `agent read` and `agent send-keys`. An unrecognized dialog can instead cause a startup timeout and clear the name while the process keeps running. Inspect the recorded pane with `pane read --source visible` before retrying. Confirm that the agent is ready for input before prompting it.' \
      --replace-fail \
        'Inspect the blocked UI and ask the user before answering it.' \
        'Inspect the blocked UI and answer through its displayed controls using known context and existing authorization. Ask the user when a required decision or fact is missing.' \
      --replace-fail \
        'Use this only as a fallback; do not request file output in the initial prompt.' \
        'Use this only as a fallback for the chat report. Request deliverable files in the initial prompt when the task needs them.'
    # Keep local preferences separate from upstream fixes. Review failed hunks on updates.
    patch --batch --forward --fuzz=0 "$out" < ${./patches/herdr-skill-preferences.patch}
  '';
  skillPath = "${config.home.homeDirectory}/projects/ai/skillshare/skills/herdr/SKILL.md";
in
{
  home.activation.installHerdrSkill = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${pkgs.coreutils}/bin/install \
      --directory ${lib.escapeShellArg (builtins.dirOf skillPath)}
    $DRY_RUN_CMD ${pkgs.coreutils}/bin/install \
      --mode 0644 \
      ${lib.escapeShellArg skillSource} \
      ${lib.escapeShellArg skillPath}
  '';
}
