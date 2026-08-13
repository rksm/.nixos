{
  config,
  lib,
  pkgs,
  ...
}:
let
  fromConfigs = path: config.lib.file.mkOutOfStoreSymlink "/home/robert/configs/${path}";
in
{
  home = {
    username = "robert";
    homeDirectory = "/home/robert";
    stateVersion = "26.05";

    file = {
      ".authinfo.gpg".source = fromConfigs ".authinfo.gpg";
      ".aws".source = fromConfigs ".aws";
      ".gnupg".source = fromConfigs ".gnupg";
      ".npmrc".source = fromConfigs ".npmrc";
      ".style.yapf".source = fromConfigs ".style.yapf";
      ".wezterm.lua".source = fromConfigs ".wezterm.lua";
      ".config/herdr".source = fromConfigs "herdr";
      ".config/vale".source = fromConfigs "vale";
      "bin/start.sh".source = fromConfigs "start.sh";

      ".codex/AGENTS.md" = {
        source = fromConfigs "ai/codex/AGENTS.md";
        force = true;
      };
      ".codex/config.toml" = {
        source = fromConfigs "ai/codex/config.toml";
        force = true;
      };
      ".claude/CLAUDE.md" = {
        source = fromConfigs "ai/claude/CLAUDE.md";
        force = true;
      };
      ".claude/settings.json" = {
        source = fromConfigs "ai/claude/settings.json";
        force = true;
      };
    };
  };

  programs = {
    bash = {
      enable = true;
      initExtra = ''
        if [ -f "$HOME/configs/.bashrc" ]; then
          source "$HOME/configs/.bashrc"
        fi
      '';
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    fish = {
      enable = true;
      interactiveShellInit = ''
        if test -f "$HOME/configs/fish/config.fish"
          source "$HOME/configs/fish/config.fish"
        end
      '';
    };

    git = {
      enable = true;
      includes = [ { path = "~/configs/git/.gitconfig"; } ];
    };
  };
}
