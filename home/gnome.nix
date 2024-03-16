{ config, pkgs, lib, ... }: {
  home.packages = with pkgs; [
    gnomeExtensions.awesome-tiles
    gnomeExtensions.unite
  ];

  dconf = {
    enable = true;
    settings = {
      # "org/gnome/desktop/interface" = {
      #   color-scheme = "prefer-dark";
      # };

      "org/gnome/shell/keybindings" = {
        toggle-overview = [ "<Super>space" ];
        # unbind Super + N
        focus-active-notification = [ "" ];
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        area-screenshot = [ "<Alt><Super>4" ];
        screencast = [ "<Alt><Super>5" ];
        screensaver = [ "<Primary><Super>q" ];
        logout = [ ];
      };

      "org/gnome/desktop/peripherals/keyboard" = {
        numlock-state = lib.hm.gvariant.mkBoolean true;
        delay = lib.hm.gvariant.mkUint32 180;
        repeat-interval = lib.hm.gvariant.mkUint32 19;
      };

      "org/gnome/mutter" = {
        # disable Super key
        # dconf write /org/gnome/mutter/overlay-key "''"
        overlay-key = "";
      };

      "org/gnome/mutter/keybindings" = {
        switch-monitor = [ ];
      };

      "org/gnome/settings-daemon/plugins/power" = {
        power-button-action = "suspend";
        sleep-inactive-ac-timeout = 3600;
        sleep-inactive-ac-type = "nothing";
      };

      "org/gnome/desktop/session" = {
        idle-delay = lib.hm.gvariant.mkUint32 0;
      };

      "org/gnome/desktop/wm/keybindings" = {
        switch-windows = [ "<Alt>Tab" ];
        switch-windows-backward = [ "<Shift><Alt>Tab" ];
        switch-to-workspace-left = [ ];
        switch-to-workspace-right = [ ];
      };

      "org/gnome/desktop/input-sources" = {
        xkb-options = [ "compose:caps" ];
      };


      # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      # gnome extensions

      "org/gnome/shell" = {
        enabled-extensions = [ "awesome-tiles@velitasali.com" "unite@hardpixel.eu" ];
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

      "org/gnome/shell/extensions/unite" = {
        app-menu-ellipsize-mode = "end";
        app-menu-max-width = 0;
        enable-titlebar-actions = true;
        extend-left-box = false;
        greyscale-tray-icons = false;
        hide-activities-button = "auto";
        hide-app-menu-icon = false;
        hide-dropdown-arrows = true;
        hide-window-titlebars = "always";
        reduce-panel-spacing = false;
        restrict-to-primary-screen = true;
        show-desktop-name = true;
        show-legacy-tray = true;
        show-window-buttons = "always";
        show-window-title = "always";
      };

    };
  };
}
