{
  config,
  lib,
  pkgs,
  ...
}:

let
  skillUrl = "https://raw.githubusercontent.com/rksm/herdr/master/SKILL.md";
  skillPath = "${config.home.homeDirectory}/projects/ai/skillshare/skills/herdr/SKILL.md";
in
{
  home.activation.installHerdrSkill = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    skill_path=${lib.escapeShellArg skillPath}
    skill_directory="$(${pkgs.coreutils}/bin/dirname "$skill_path")"
    temporary_path="$skill_path.tmp"

    $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p "$skill_directory"

    if ! $DRY_RUN_CMD ${pkgs.curl}/bin/curl \
      --fail \
      --location \
      --silent \
      --show-error \
      --output "$temporary_path" \
      ${lib.escapeShellArg skillUrl}; then
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/rm -f "$temporary_path"
      echo "warning: could not refresh Herdr's SKILL.md" >&2
    else
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/mv "$temporary_path" "$skill_path"
    fi
  '';
}
