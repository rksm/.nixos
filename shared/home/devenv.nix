{
  config,
  lib,
  pkgs,
  user,
  ...
}:

let
  fromConfigs = path: config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/${path};
in
{
  home.file = {
    ".authinfo.gpg".source = fromConfigs ".authinfo.gpg";
    ".aws".source = fromConfigs ".aws";
    ".gnupg".source = fromConfigs ".gnupg";
    ".npmrc".source = fromConfigs ".npmrc";
    ".style.yapf".source = fromConfigs ".style.yapf";
    ".config/herdr".source = fromConfigs "herdr";
    ".config/skillshare/config.yaml".source =
      config.lib.file.mkOutOfStoreSymlink /home/${user}/projects/ai/skillshare/config.yaml;
    ".config/vale".source = fromConfigs "vale";
    ".local/share/fish/fish_history".source = fromConfigs "fish_history.linux";

    ".cli-proxy-api/config.yaml" = {
      source = fromConfigs "ai/cli-proxy-api/config.yaml";
      force = true;
    };
    ".codex/AGENTS.md" = {
      source = fromConfigs "ai/codex/AGENTS.md";
      force = true;
    };
    ".codex/config.toml" = {
      source = fromConfigs "ai/codex/config.toml";
      force = true;
    };
    "bin/start.sh" = {
      source = fromConfigs "start.sh";
      force = true;
    };
  };

  home.activation.linkClaudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "$HOME/.claude"
    $DRY_RUN_CMD ln -sfn "../configs/ai/claude/settings.json" "/home/${user}/.claude/settings.json"
    $DRY_RUN_CMD ln -sfn "../configs/ai/claude/CLAUDE.md" "/home/${user}/.claude/CLAUDE.md"
  '';

  programs = {
    bash = {
      enable = true;
      initExtra = ''
        if [ -f $HOME/configs/.bashrc ];
        then
          source $HOME/configs/.bashrc
        fi
      '';
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    fish = {
      enable = true;
      shellInitLast = ''
        set -gx OMF_PATH "${pkgs.oh-my-fish}/share/oh-my-fish"
        source $OMF_PATH/init.fish

        source $HOME/configs/fish/config.fish
      '';
      plugins = [
        {
          name = "myfish";
          src = fromConfigs "fish";
        }
      ];
    };

    gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };

    git = {
      enable = true;
      includes = [ { path = "~/configs/git/.gitconfig"; } ];
    };

    nix-index = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
  };

  home.packages = with pkgs; [
    fzf
    oh-my-fish
  ];
}
