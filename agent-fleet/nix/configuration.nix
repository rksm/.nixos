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
    curl
    direnv
    fd
    fish
    git
    gh
    htop
    jq
    just
    nix-output-monitor
    nixfmt
    nodejs_24
    openssh
    pandoc
    ripgrep
    rsync
    tree
    vale

    agents.antigravity-cli
    agents.ccusage
    agents.claude-code
    agents.cli-proxy-api
    codex
    agents.herdr
    agents.hermes-agent
    agents.openclaw
    agents.rtk
  ];

  programs.fish.enable = true;

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
