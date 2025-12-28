{ lib, inputs, config, pkgs, options, user, ... }:
{
  # Set primary user for nix-darwin options that require it
  system.primaryUser = user;
  imports = [
    ./packages.nix
  ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # nixpkgs.overlays = [ inputs.nixpkgs-firefox-darwin.overlay ];

  users.users.${user} = {
    description = "${user} account";
    home = "/Users/${user}";
  };

  ####################
  # nix config

  # # Needed since Determinate Nix manages the main config file for system.
  # environment.etc."nix/nix.custom.conf".text = pkgs.lib.mkForce ''
  #   # Add nix settings to seperate conf file
  #   # since we use Determinate Nix on our systems.
  #   trusted-users = ${user}
  #   accept-flake-config = true
  #   substituters = https://nix-cache.dev.hyper.video/hyper https://cache.nixos.org
  #   trusted-substituters = https://nix-cache.dev.hyper.video/hyper
  #   trusted-public-keys = hyper:DjxBNvAnvX4QkO9tsA9NykspiVhqfYbxAqnNWr+FUNE= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
  # '';
  # # Determinate uses its own daemon to manage the Nix installation that
  # # conflicts with nix-darwin's native Nix management.
  # # To turn off nix-darwin's management of the Nix installation, set:
  # # This will allow you to use nix-darwin with Determinate. Some nix-darwin
  # # functionality that relies on managing the Nix installation, like the
  # # `nix.*` options to adjust Nix settings or configure a Linux builder,
  # # will be unavailable.
  # nix.enable = false;

  # Non-Determinate Nix settings
  nix = {
    settings = {
      substituters = [
        "https://cache.nixos.org/"
        "https://hyper-video.cachix.org/"
        "https://nix-community.cachix.org/"
      ];
      trusted-public-keys = [
        "hyper-video.cachix.org-1:47YSCAg+fJBEH3oAhSzlcZAbjTMgnHTmQ6gI1la0Su4="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-substituters = [
        "https://hyper-video.cachix.org"
      ];
      trusted-users = [
        "@admin" "${user}"
      ];
      experimental-features = "nix-command flakes";
    };
    package = pkgs.nixVersions.latest;
    extraOptions = ''
      auto-optimise-store = true
    '' + lib.optionalString (pkgs.system == "x86_64-darwin") ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';
    # configureBuildUsers is deprecated and removed in newer nix-darwin
    # https://github.com/NixOS/nix/issues/2982#issuecomment-2477618346
    channel.enable = false;
  };
  # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable is deprecated and removed in newer nix-darwin

  # Add ability to used TouchID for sudo authentication
  # security.pam.enableSudoTouchIdAuth = true;

  # # Fonts
  # fonts.enableFontDir = true;
  # fonts.fonts = with pkgs; [
  #    recursive
  #    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  #  ];


  # Set Git commit hash for darwin-version.
  # system.configurationRevision = self.rev or self.dirtyRev or null;

  ##############

  # The platform the configuration will be used on.
  # nixpkgs.hostPlatform = "x86_64-darwin";
  nixpkgs.hostPlatform = "aarch64-darwin";

  #https://github.com/LnL7/nix-darwin/blob/master/modules/examples/lnl.nix
  system = {
    defaults = {
      NSGlobalDomain.AppleKeyboardUIMode = 3;
      NSGlobalDomain.ApplePressAndHoldEnabled = false;
      NSGlobalDomain.InitialKeyRepeat = 10;
      NSGlobalDomain.KeyRepeat = 1;
      NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
      NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
      NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
      NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
      NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
      NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
      NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;
      NSGlobalDomain._HIHideMenuBar = false;

      # to not have screen slide when going between fullscreen / normal apps
      universalaccess.reduceMotion = true;
      # to not have a white menu bar in dark mode
      universalaccess.reduceTransparency = true;

      dock.autohide = true;
      dock.mru-spaces = false;
      # dock.orientation = "left";
      dock.showhidden = true;

      finder.AppleShowAllExtensions = true;
      finder.QuitMenuItem = true;
      finder.FXEnableExtensionChangeWarning = false;
      finder.ShowPathbar = true;

      trackpad.Clicking = true;
      trackpad.TrackpadThreeFingerDrag = true;

      menuExtraClock.Show24Hour = true; # show 24 hour clock

      NSGlobalDomain."com.apple.keyboard.fnState" = true;
    };

    keyboard = {
      enableKeyMapping = true;
      # remapCapsLockToControl = true;
    };


    # activationScripts are executed every time you boot the system or run `nixos-rebuild` / `darwin-rebuild`.
    # postUserActivation is deprecated, now all activation runs as root
    activationScripts.postActivation.text = ''
      # activateSettings -u will reload the settings from the database and apply them to the current session,
      # so we do not need to logout and login again to make the changes take effect.
      sudo -u ${user} /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    # activationScripts.applications.text = pkgs.lib.mkForce (
    #   ''
    #       echo "setting up ~/Applications/Nix..."
    #       if [[ -d ~/Applications/Nix ]]; then
    #         rm -rf ~/Applications/Nix/*
    #         rm -rf ~/Applications/Nix
    #       fi
    #       mkdir -p ~/Applications/Nix
    #       chown ${user} ~/Applications/Nix
    #       find ${config.system.build.applications}/Applications -maxdepth 1 -type l | while read f; do
    #         src="$(/usr/bin/stat -f%Y $f)"
    #         appname="$(basename $src)"
    #         osascript -e "tell app \"Finder\" to make alias file at POSIX file \"/Users/${user}/Applications/Nix/\" to POSIX file \"$src\" with properties {name: \"$appname\"}" || true;
    #     done
    #   ''
    # );
  };
}
