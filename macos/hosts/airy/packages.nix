{ config, pkgs, user, ... }:
{
  nixpkgs.config.allowUnfree = true;
  programs.fish.enable = true;
  programs.bash.completion.enable = true;

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

    tailscale
  ];

  services.tailscale = {
    enable = true;
  };

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
      # "wakeonlan"
    ];

    casks = [
      "rectangle"
      "wezterm"
      "1password"
      "1password-cli"
      "karabiner-elements"
      "scroll-reverser"
    ];
  };
}
