{
  config,
  lib,
  pkgs,
  user,
  machine,
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
    ".config/fm".source = fromConfigs "ai/fm";
    ".config/herdr".source = fromConfigs "herdr";
    ".config/skillshare/config.yaml".source =
      config.lib.file.mkOutOfStoreSymlink /home/${user}/projects/ai/skillshare/config.yaml;
    ".config/vale".source = fromConfigs "vale";
    ".local/share/fish/fish_history".source = fromConfigs "fish_history.linux";

    ".codex/AGENTS.md" = {
      source = fromConfigs "ai/codex/AGENTS.md";
      force = true;
    };
    ".codex/config.toml" = {
      source = fromConfigs "ai/codex/config.${machine}.toml";
      force = true;
    };
    "bin/start.sh" = {
      source = fromConfigs "start.sh";
      force = true;
    };
  };

  home.activation.linkClaudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "$HOME/.claude"
    $DRY_RUN_CMD ln -sfn "../configs/ai/claude/settings.${machine}.json" "/home/${user}/.claude/settings.json"
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

    # Git pushes over HTTPS with the gh token. GitHub rejects a push that
    # changes .github/workflows/ unless the token has the workflow scope:
    #   gh auth refresh -h github.com -s workflow
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

  systemd.user.services.herdr = {
    Unit = {
      Description = "Herdr ${machine} session";
      # A Home Manager switch must not stop the server and its running panes.
      X-SwitchMethod = "keep-old";
    };
    Service = {
      # Pane shells need the same login environment as interactive shells.
      Environment = [ "HERDR_SESSION=${machine}" ];
      ExecStart = "${pkgs.bash}/bin/bash -lc 'exec ${pkgs.herdr}/bin/herdr server'";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };

  home.packages = with pkgs; [
    fzf
    oh-my-fish
  ];
}
