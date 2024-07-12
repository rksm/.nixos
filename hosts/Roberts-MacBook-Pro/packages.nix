{ config, pkgs, user, ... }:
{
  nixpkgs.config.allowUnfree = true;
  programs.fish.enable = true;
  programs.bash.enableCompletion = true;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina

  # List packages installed in system profile. To search, run:
  # nix search wget
  environment.systemPackages = with pkgs; [
    # utils
    git
    git-lfs
    wget
    curl
    htop
    btop
    iftop
    nmap
    killall
    gnupg
    zip
    unzip
    gnused
    gnutar

    # system call monitoring
    lsof # list open files

    ripgrep
    fd

    # pkgs.shellcheck
    iterm2
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
  };

  homebrew = {
    enable = true;
    # can make darwin-rebuild much slower
    onActivation.autoUpdate = true;
    # onActivation.upgrade = true;

    brews = [
      "coreutils"
      "syncthing"
      "wakeonlan"
    ];

    casks = [
      "rectangle"
      "wezterm"
      "1password"
      "1password-cli"
      "karabiner-elements"
      "google-chrome"
    ];
  };

  system.activationScripts.applications.text = pkgs.lib.mkForce (
    ''
        echo "setting up ~/Applications/Nix..."
        if [[ -d ~/Applications/Nix ]]; then
          rm -rf ~/Applications/Nix/*
          rm -rf ~/Applications/Nix
        fi
        mkdir -p ~/Applications/Nix
        chown ${user} ~/Applications/Nix
        find ${config.system.build.applications}/Applications -maxdepth 1 -type l | while read f; do
          src="$(/usr/bin/stat -f%Y $f)"
          appname="$(basename $src)"
          osascript -e "tell app \"Finder\" to make alias file at POSIX file \"/Users/${user}/Applications/Nix/\" to POSIX file \"$src\" with properties {name: \"$appname\"}" || true;
      done
    ''
  );

}
