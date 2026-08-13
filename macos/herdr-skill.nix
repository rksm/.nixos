{
  config,
  lib,
  pkgs,
  ...
}:

let
  skillSource = "${pkgs.herdr.src}/skills/herdr/SKILL.md";
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
