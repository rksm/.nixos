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
  codex = inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
  fluxReconciler = inputs.flux-reconciler.packages.${pkgs.stdenv.hostPlatform.system}.default;
  herdr = inputs.herdr-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
  skillshare = inputs.skillshare-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
  worktrunk = inputs.worktrunk-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
  sshKey = lib.removeSuffix "\n" (builtins.readFile ./ssh-key.pub);
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./syncthing.nix
  ];

  nixpkgs.config.allowUnfree = true;

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
    agents.claude-code
    agents.cli-proxy-api
    astOutline
    codex
    fluxReconciler
    herdr
    agents.hermes-agent
    agents.openclaw
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
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      netrc-file = "/etc/nixos/shared/secrets/hyper-video-cachix-netrc.key";
      substituters = [
        "https://nix-community.cachix.org"
        "https://hyper-video.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyper-video.cachix.org-1:47YSCAg+fJBEH3oAhSzlcZAbjTMgnHTmQ6gI1la0Su4="
      ];
      trusted-substituters = [
        "https://nix-community.cachix.org"
        "https://hyper-video.cachix.org"
      ];
      trusted-users = [
        "root"
        "robert"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /home/robert/configs 0700 robert users -"
    "d /home/robert/projects 0755 robert users -"
    "d /home/robert/projects/hyper 0755 robert users -"
  ];

  system.stateVersion = "26.05";
}
