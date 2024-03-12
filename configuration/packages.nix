{ config, pkgs, ... }:
{

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
    iotop
    iftop
    nmap

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    ripgrep
    fd

    # misc
    nodejs
    gnomeExtensions.awesome-tiles
    nil
    nixpkgs-fmt # nix language server
    kubectl
    kubernetes-helm
  ];

  programs.dconf.enable = true;
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "robert" ];
  };

  # some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # ssh
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
    # openFirewall = true;
  };
}
