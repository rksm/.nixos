{ config, pkgs, user, ... }:
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
    killall

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    ripgrep
    fd
  ];

  programs.dconf.enable = true;
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "${user}" ];
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


  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    ubuntu_font_family
    monaspace
  ];
}
