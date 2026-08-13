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
      ".config/skillshare/config.yaml" = {
        source = config.lib.file.mkOutOfStoreSymlink "/home/robert/projects/ai/skillshare/config.yaml";
        force = true;
      };
      ".config/vale".source = fromConfigs "vale";
      ".emacs.d/init.el".source = ./emacs/init.el;
      ".local/share/fish/fish_history".source = fromConfigs "fish_history.linux";
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
      shellInitLast = ''
        if status is-interactive
          set -gx OMF_PATH "${pkgs.oh-my-fish}/share/oh-my-fish"
          source $OMF_PATH/init.fish
          source $HOME/configs/fish/config.fish
        end
      '';
      plugins = [
        {
          name = "myfish";
          src = fromConfigs "fish";
        }
      ];
    };

    git = {
      enable = true;
      includes = [ { path = "~/configs/git/.gitconfig"; } ];
    };
  };

  home.packages = with pkgs; [
    emacs-nox
    fzf
    kubectl
    oh-my-fish
  ];
}
