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
  codex = inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
  herdr = inputs.herdr-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
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
    };
  };

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    btop
    curl
    direnv
    fd
    fd
    fish
    gh
    git
    git-filter-repo
    git-lfs
    htop
    iftop
    iotop
    jq
    just
    killall
    lsof # list open files
    ltrace # library call monitoring
    nix-output-monitor
    nixfmt
    nmap
    nodejs_24
    openssh
    (lib.lowPrio perf) # low priority so that we can to use trace from elsewhere
    pandoc
    ripgrep
    rsync
    strace # system call monitoring
    tree
    vale
    wget

    google-chrome

    agents.antigravity-cli
    agents.ccusage
    agents.claude-code
    agents.cli-proxy-api
    codex
    herdr
    agents.hermes-agent
    agents.openclaw
    agents.rtk
  ];

  programs = {
    fish.enable = true;
    _1password.enable = true;
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      netrc-file = "/etc/nixos/shared/secrets/hyper-video-cachix-netrc.key";
      substituters = [ "https://hyper-video.cachix.org" ];
      trusted-public-keys = [
        "hyper-video.cachix.org-1:47YSCAg+fJBEH3oAhSzlcZAbjTMgnHTmQ6gI1la0Su4="
      ];
      trusted-substituters = [ "https://hyper-video.cachix.org" ];
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
