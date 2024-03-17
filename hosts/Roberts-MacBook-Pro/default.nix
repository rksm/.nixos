{ inputs, config, pkgs, options, user, nixpkgs-firefox-darwin, ... }:
{
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget

  users.users.${user} = {
    description = "${user} account";
    home = "/Users/${user}";
    };

####################
# nix config

  nix.settings.substituters = [
    "https://cache.nixos.org/"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];
  nix.settings.trusted-users = [
    "@admin"
  ];
  nix.configureBuildUsers = true;
  # Add ability to used TouchID for sudo authentication
  # security.pam.enableSudoTouchIdAuth = true;



  # Enable experimental nix command and flakes
  # nix.package = pkgs.nixUnstable;
  # nix.extraOptions = ''
  #   auto-optimise-store = true
  # '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
  #   extra-platforms = x86_64-darwin aarch64-darwin
  # '';

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # # Apps
  # # `home-manager` currently has issues adding them to `~/Applications`
  # # Issue: https://github.com/nix-community/home-manager/issues/1341
  # environment.systemPackages = with pkgs; [
  #   kitty
  #   terminal-notifier
  # ];

  # # https://github.com/nix-community/home-manager/issues/423
  # environment.variables = {
  #   TERMINFO_DIRS = "${pkgs.kitty.terminfo.outPath}/share/terminfo";
  # };
  programs.nix-index.enable = true;

  # # Fonts
  # fonts.enableFontDir = true;
  # fonts.fonts = with pkgs; [
  #    recursive
  #    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  #  ];

      # Auto upgrade nix package and the daemon service.
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Set Git commit hash for darwin-version.
      # system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

##############

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "x86_64-darwin";

#https://github.com/LnL7/nix-darwin/blob/master/modules/examples/lnl.nix

  system.defaults.NSGlobalDomain.AppleKeyboardUIMode = 3;
  system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 10;
  system.defaults.NSGlobalDomain.KeyRepeat = 1;
  system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
  system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
  system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;
  system.defaults.NSGlobalDomain._HIHideMenuBar = true;

  system.defaults.dock.autohide = true;
  system.defaults.dock.mru-spaces = false;
  system.defaults.dock.orientation = "left";
  system.defaults.dock.showhidden = true;

  system.defaults.finder.AppleShowAllExtensions = true;
  system.defaults.finder.QuitMenuItem = true;
  system.defaults.finder.FXEnableExtensionChangeWarning = false;

  system.defaults.trackpad.Clicking = true;
  system.defaults.trackpad.TrackpadThreeFingerDrag = true;

  system.keyboard.enableKeyMapping = true;
  # system.keyboard.remapCapsLockToControl = true;


######################################
# packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs;
    [
      # emacs
      iterm2
      #firefox
      # wezterm
      #config.programs.vim.package
      #pkgs.awscli
      #pkgs.brotli
      #pkgs.ctags
      pkgs.curl
      pkgs.direnv
      pkgs.entr
      pkgs.fzf
      #pkgs.gettext
      pkgs.git
      pkgs.gnupg
      pkgs.htop
      pkgs.jq
      #pkgs.mosh
      pkgs.ripgrep
      #pkgs.shellcheck
      #pkgs.vault

      #pkgs.qes
      #pkgs.darwin-zsh-completions
    ];



      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      programs.fish.enable = true;
      programs.bash.enableCompletion = true;



######################################
homebrew = {
  enable = true;
  # can make darwin-rebuild much slower
  onActivation.autoUpdate = true;
  # onActivation.upgrade = true;

  casks = [
    "rectangle"
    "wezterm"
    # "hammerspoon"
    # "amethyst"
    # "alfred"
    # "logseq"
    # "discord"
    # "iina"
  ];
};


}