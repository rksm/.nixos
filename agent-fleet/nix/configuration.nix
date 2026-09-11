{
  config,
  inputs,
  lib,
  modulesPath,
  pkgs,
  ...
}:
let
  agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  aiQuotas = inputs.ai-quotas.packages.${pkgs.stdenv.hostPlatform.system}.default;
  astOutline = inputs.ast-outline.packages.${pkgs.stdenv.hostPlatform.system}.default;
  fluxReconciler = inputs.flux-reconciler.packages.${pkgs.stdenv.hostPlatform.system}.default;
  herdr = inputs.herdr-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
  skillshare = inputs.skillshare-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
  worktrunk = inputs.worktrunk-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
  sshKey = lib.removeSuffix "\n" (builtins.readFile ../ssh/id_ed25519.pub);
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ../../shared/linux/nix.nix
    ./syncthing.nix
  ];

  boot.loader = {
    efi.canTouchEfiVariables = false;
    grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    trustedInterfaces = [ "tailscale0" ];
  };

  services.tailscale.enable = true;

  # Attaching a volume can change the kernel's disk enumeration order.
  disko.devices.disk.main.device = lib.mkIf (
    config.networking.hostName == "agent-1"
  ) "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_125107444";

  fileSystems."/home" = lib.mkIf (config.networking.hostName == "agent-1") {
    device = "/dev/disk/by-id/scsi-0HC_Volume_106845129";
    fsType = "ext4";
    neededForBoot = true;
  };

  # Stop home writers if the volume mount disappears.
  systemd.services = lib.mkIf (config.networking.hostName == "agent-1") {
    syncthing = {
      unitConfig.RequiresMountsFor = [ "/home" ];
      bindsTo = [ "home.mount" ];
      after = [ "home.mount" ];
    };
    "user@1000" = {
      overrideStrategy = "asDropin";
      unitConfig.RequiresMountsFor = [ "/home" ];
      bindsTo = [ "home.mount" ];
      after = [ "home.mount" ];
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  users.users = {
    root.openssh.authorizedKeys.keys = [ sshKey ];
    robert = {
      isNormalUser = true;
      description = "Robert";
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [ sshKey ];
      shell = pkgs.fish;
      # Start user services (agent-files sync) at boot, without a login session.
      linger = true;
    };
  };

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    btop
    curl
    difftastic
    direnv
    dnsutils
    fd
    fish
    git
    git-filter-repo
    git-lfs
    graphviz
    htop
    iftop
    iperf3
    iotop
    jq
    just
    k9s
    killall
    kubernetes-helm
    lsof # list open files
    ltrace # library call monitoring
    mermaid-cli
    mtr
    nix-output-monitor
    nix-tree
    nixfmt
    nmap
    nodejs_24
    oha
    openssh
    (lib.lowPrio perf) # low priority so that we can to use trace from elsewhere
    pandoc
    ripgrep
    rsync
    socat
    strace # system call monitoring
    sysstat
    tokei
    traceroute
    tree
    unzip
    vale
    wget
    zip

    google-chrome

    aiQuotas
    agents.antigravity-cli
    agents.ccusage
    astOutline
    fluxReconciler
    herdr
    agents.hermes-agent
    agents.rtk
    skillshare
    worktrunk
  ];

  programs = {
    fish.enable = true;
    mosh.enable = true;
    _1password.enable = true;
  };

  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 1d";
    };
    settings.trusted-substituters = [
      "https://nix-community.cachix.org"
      "https://hyper-video.cachix.org"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /home/robert/configs 0700 robert users -"
    "d /home/robert/projects 0755 robert users -"
    "d /home/robert/projects/hyper 0755 robert users -"
  ];

  system.stateVersion = "26.05";
}
