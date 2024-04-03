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

    # low priority so that we can to use trace from elsewhere
    (pkgs.lowPrio config.boot.kernelPackages.perf)
    config.boot.kernelPackages.tmon # thermal monitoring
    config.boot.kernelPackages.cpupower

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
    enableSSHSupport = false;
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
    hack-font
    fira-code
    fira-code-symbols
    ubuntu_font_family
    monaspace
    jetbrains-mono
    etBook
    montserrat
    (iosevka-bin.override { variant = "Aile"; })
  ];


  # To build rust packages that in turn pull in / build binaries
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
  ];
}
