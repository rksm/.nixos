{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  home-manager.useGlobalPkgs = true;

  home-manager.users.robert = { pkgs, lib, ... }: {
    programs.bash.enable = true;

    home.sessionVariables = {
      EDITOR = "emacs";
    };

    programs.emacs = {
      enable = true;
      extraPackages = epkgs: with epkgs; [
        nix-mode
        magit
        use-package
        dash
        dash-functional
        s
      ];
    };

    programs.git = {
      enable = true;
      includes = [
        { path = "~/configs/git/.gitconfig"; }
      ];
    };

    dconf = {
      enable = true;
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };

        "org/gnome/shell/keybindings" = {
          toggle-overview = ["<Super>space"];
        };

        "org/gnome/settings-daemon/plugins/media-keys" = {
          area-screenshot = ["<Alt><Super>4"];
          screencast = ["<Alt><Super>5"];
          screensaver = ["<Primary><Super>q"];
        };

        "org/gnome/desktop/peripherals/keyboard" = {
          numlock-state = lib.hm.gvariant.mkBoolean true;
          delay = lib.hm.gvariant.mkUint32 180;
          repeat-interval = lib.hm.gvariant.mkUint32 19;
	      };

        "org/gnome/shell" = {
          enabled-extensions = [ "awesome-tiles@velitasali.com" ];
        };

        "org/gnome/mutter" = {
          # disable Super key
          # dconf write /org/gnome/mutter/overlay-key "''"
          overlay-key = "";
        };

        "org/gnome/shell/extensions/awesome-tiles" = {
          gap-size = 0;
          enable-inner-gaps = lib.hm.gvariant.mkBoolean false;
          shortcut-align-window-to-center = [ "<Control><Alt><Shift>KP_5" ];
          shortcut-decrease-gap-size = [ "<Control><Alt><Shift>KP_2" ];
          shortcut-tile-window-to-bottom = [ "<Control><Alt>KP_2" ];
          shortcut-tile-window-to-bottom-left = [ "<Control><Alt>KP_1" ];
          shortcut-tile-window-to-bottom-right = [ "<Control><Alt>KP_3" ];
          shortcut-tile-window-to-center = [ "<Control><Alt>KP_5" ];
          shortcut-tile-window-to-left = [ "<Control><Alt>KP_4" ];
          shortcut-tile-window-to-right = [ "<Control><Alt>KP_6" ];
          shortcut-tile-window-to-top = [ "<Control><Alt>KP_8" ];
          shortcut-tile-window-to-top-left = [ "<Control><Alt>KP_7" ];
          shortcut-tile-window-to-top-right = [ "<Control><Alt>KP_9" ];
        };

        "org/gnome/settings-daemon/plugins/power" = {
          power-button-action = "suspend";
          sleep-inactive-ac-timeout = 3600;
          sleep-inactive-ac-type = "nothing";
        };

        "org/gnome/desktop/session" = {
          idle-delay = lib.hm.gvariant.mkUint32 0;
        };

      };
    };

    home.stateVersion = "24.05";
  };
}
