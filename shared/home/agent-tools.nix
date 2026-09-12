{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    agent-browser
    fastmail-cli
    slackcli
  ];
  # Skillshare needs real source directories. Codex needs real SKILL.md files.
  # These three directories belong to their packages and refresh on activation.
  home.activation.copyPackagedSkills = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    skills_dir="${config.home.homeDirectory}/projects/ai/skillshare/skills"
    run mkdir -p "$skills_dir/fastmail"
    run ${pkgs.rsync}/bin/rsync -rLpt --chmod=Du+w --delete \
      "${pkgs.agent-browser}/skills/agent-browser/" "$skills_dir/agent-browser/"
    run ${pkgs.rsync}/bin/rsync -rLpt --chmod=Du+w --delete \
      "${pkgs.fastmail-cli}/share/fm/skills/review-email/" "$skills_dir/fastmail/review-email/"
    run ${pkgs.rsync}/bin/rsync -rLpt --chmod=Du+w --delete \
      "${pkgs.slackcli}/share/slackcli/skills/slackcli/" "$skills_dir/slackcli/"
    run ${pkgs.gnused}/bin/sed -i '1a\
    # Managed by shared/home/agent-tools.nix.\
    # Do not edit this copy. Home Manager overwrites it on activation.\
    # Change the package definition under packages/ instead.' \
      "$skills_dir/agent-browser/SKILL.md" \
      "$skills_dir/fastmail/review-email/SKILL.md" \
      "$skills_dir/slackcli/SKILL.md"
  '';

}
