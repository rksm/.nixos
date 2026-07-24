{ config, pkgs, lib, user, inputs, ... }:

{
  imports = [
    ../../../herdr-skill.nix
    ../../../../shared/home/pi-local.nix
    ./devenv.nix
    ./devops.nix
    ./rust.nix
  ];

  home.stateVersion = "25.05";
  home.username = "${user}";
  home.homeDirectory = "/Users/${user}";

  home.file.".config/karabiner".source = config.lib.file.mkOutOfStoreSymlink /Users/${user}/configs/mac/karabiner;
  home.file.".config/herdr/config.toml".source = config.lib.file.mkOutOfStoreSymlink /Users/${user}/configs/herdr/config.toml;
  home.file.".wezterm.lua".source = config.lib.file.mkOutOfStoreSymlink /Users/${user}/configs/.wezterm.lua;
  home.file.".gnupg".source = config.lib.file.mkOutOfStoreSymlink /Users/${user}/configs/.gnupg;
  home.file.".authinfo.gpg".source = config.lib.file.mkOutOfStoreSymlink /Users/${user}/configs/.authinfo.gpg;
  home.file.".aws".source = config.lib.file.mkOutOfStoreSymlink /Users/${user}/configs/.aws;
  home.file.".npmrc".source = config.lib.file.mkOutOfStoreSymlink /Users/${user}/configs/.npmrc;
  home.file.".style.yapf".source = config.lib.file.mkOutOfStoreSymlink /Users/${user}/configs/.style.yapf;

  home.file.".config/skillshare/config.yaml".source = config.lib.file.mkOutOfStoreSymlink /Users/${user}/projects/ai/skillshare/config.yaml;
  home.file.".config/skillshare/config.yaml".force = true;
  home.file.".codex/config.toml".source = config.lib.file.mkOutOfStoreSymlink /Users/${user}/configs/ai/codex/config.toml;
  home.file.".codex/config.toml".force = true;
  home.file.".codex/AGENTS.md".source = config.lib.file.mkOutOfStoreSymlink /Users/${user}/configs/ai/codex/AGENTS.md;
  home.file.".codex/AGENTS.md".force = true;

  home.activation.linkClaudeSettings =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p "$HOME/.claude"
      $DRY_RUN_CMD ln -sfn "../configs/ai/claude/settings.json" "/Users/${user}/.claude/settings.json"
      $DRY_RUN_CMD ln -sfn "../configs/ai/claude/CLAUDE.md" "/Users/${user}/.claude/CLAUDE.md"
    '';

}
