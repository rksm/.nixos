{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  # rust-overlay.url = "github:oxalica/rust-overlay";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  home-manager.useGlobalPkgs = true;

  home-manager.users.robert = { pkgs, lib, ... }: {

    # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # rust specific

    home.file.".cargo/config.toml".text = ''
      [target.x86_64-unknown-linux-gnu]
      linker = "clang"
      rustflags = ["-C", "link-arg=--ld-path=${pkgs.mold-wrapped}/bin/mold"]

      # [build]
      # rustc-wrapper = "sccache"

      [registries]
      krahn = { index = "sparse+https://crates.kra.hn/api/v1/crates/", token = "OAZuEQBTDexae5pVbWZYgfXwFCuNbMia" }
    '';


    # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

    home.sessionVariables = {
      EDITOR = "emacsclient -n";
    };

    # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # bash

    programs.bash = {
      enable = true;
      initExtra = ''
        if [ -f $HOME/configs/.bashrc ];
        then
          source $HOME/configs/.bashrc
        fi
      '';
    };

    # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

    programs.fish = {
      enable = true;
      shellInitLast = ''
        set -gx OMF_PATH "${pkgs.oh-my-fish}/share/oh-my-fish"
        source $OMF_PATH/init.fish
      '';

      plugins = [
        { name = "myfish"; src = /home/robert/configs/fish; }
      ];
    };

    # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

    # https://discourse.nixos.org/t/command-not-found-unable-to-open-database/3807/4
    programs.nix-index = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
    };

    # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

    home.packages = with pkgs; [
      # archives
      zip
      unzip
      jq

      # utils
      wezterm
      just
      silver-searcher
      eza
      fzf
      tree
      gnused
      gnutar

      # networking tools
      mtr # A network diagnostic tool
      iperf3
      dnsutils  # `dig` + `nslookup`
      ldns # replacement of `dig`, it provide the command `drill`
      aria2 # A lightweight multi-protocol & multi-source command-line download utility
      socat # replacement of openbsd-netcat
      nmap # A utility for network discovery and security auditing
      ipcalc  # it is a calculator for the IPv4/v6 addresses

      # nix related
      #
      # it provides the command `nom` works just like `nix`
      # with more details log output
      nix-output-monitor

      # system tools
      sysstat
      lm_sensors # for `sensors` command
      ethtool
      pciutils # lspci
      usbutils # lsusb

      # fish
      oh-my-fish

      # misc
      killall
    ];


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
        # "org/gnome/desktop/interface" = {
        #   color-scheme = "prefer-dark";
        # };

        "org/gnome/shell/keybindings" = {
          toggle-overview = ["<Super>space"];
        };

        "org/gnome/settings-daemon/plugins/media-keys" = {
          area-screenshot = ["<Alt><Super>4"];
          screencast = ["<Alt><Super>5"];
          screensaver = ["<Primary><Super>q"];
          logout = [];
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

        "org/gnome/mutter/keybindings" = {
          switch-monitor = [];
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

        "org/gnome/desktop/wm/keybindings" = {
          switch-to-workspace-left = [];
          switch-to-workspace-right = [];
        };

        "org/gnome/desktop/input-sources" = {
          xkb-options = ["compose:caps"];
        };
      };
    };

    home.stateVersion = "24.05";

  };
}
