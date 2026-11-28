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
  # `ama`: a dashboard on another machine starts and drives this machine's agents with it, over SSH.
  allMyAgents = inputs.all-my-agents.packages.${pkgs.stdenv.hostPlatform.system}.default;
  fluxReconciler = inputs.flux-reconciler.packages.${pkgs.stdenv.hostPlatform.system}.default;
  herdr = inputs.herdr-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
  skillshare = inputs.skillshare-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
  worktrunk = inputs.worktrunk-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
  sshKey = lib.removeSuffix "\n" (builtins.readFile ../ssh/id_ed25519.pub);
  isAgent1 = config.networking.hostName == "agent-1";
  isAgent2 = config.networking.hostName == "agent-2";
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ../../shared/linux/nix.nix
    # Links ~/.config/herdr, where the Herdr session of ./roberts-review-bot.nix has its config and its socket.
    ../../shared/linux/herdr.nix
    ./roberts-review-bot.nix
    ./syncthing.nix
  ];

  # The reviews of ./roberts-review-bot.nix run as agents in Herdr panes. Herdr's hooks report each agent's session, so
  # a Herdr restart can resume them. They go in after the hooks of ../../shared/linux/moshi.nix.
  systemd.user.services.moshi-hook.serviceConfig.ExecStartPre = lib.mkAfter [
    "${herdr}/bin/herdr integration install claude"
    "${herdr}/bin/herdr integration install codex"
    "${pkgs.coreutils}/bin/mkdir -p /home/robert/.grok"
    "${herdr}/bin/herdr integration install grok"
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

  services.resolved.enable = true;
  security.polkit.enable = true;
  services.tailscale.enable = true;
  # Compressed in-RAM swap absorbs short memory spikes before earlyoom kills a build process.
  zramSwap.enable = true;
  # Without earlyoom, the kernel's OOM killer can take 15+ minutes to act while thrashing and
  # dropping SSH and Tailscale. earlyoom kills the largest process before that happens.
  services.earlyoom.enable = true;

  # Attaching a volume can change the kernel's disk enumeration order.
  # On agent-2, disk-config.nix defaults disko.devices.disk.main.device to /dev/sda so /, /nix,
  # and /tmp stay on ccx43's fast local NVMe root disk.
  disko.devices.disk.main.device =
    lib.mkIf isAgent1 "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_125107444";

  fileSystems."/home" = lib.mkIf isAgent1 {
    device = "/dev/disk/by-id/scsi-0HC_Volume_106845129";
    fsType = "ext4";
    neededForBoot = true;
  };

  fileSystems."/mnt/agent-2-data" = lib.mkIf isAgent2 {
    device = "/dev/disk/by-label/agent-2-data";
    fsType = "ext4";
    options = [
      "nofail"
      "x-systemd.device-timeout=15s"
      "noatime"
    ];
  };

  systemd.services = lib.mkMerge [
    (lib.mkIf isAgent1 {
      tailscale-serve-cli-proxy-api =
        lib.mkIf config.home-manager.users.robert.services.cli-proxy-api.enableLocal
          {
            description = "Expose CLI Proxy API to the tailnet";
            after = [
              "network-online.target"
              "tailscaled.service"
            ];
            requires = [ "tailscaled.service" ];
            wants = [ "network-online.target" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
              Restart = "on-failure";
              RestartSec = "5s";
              # A switch that restarts tailscaled starts this unit before the backend runs.
              ExecStartPre = "${pkgs.tailscale}/bin/tailscale wait --timeout=60s";
              ExecStart = "${pkgs.tailscale}/bin/tailscale serve --bg --yes --https=8317 http://127.0.0.1:8317";
              ExecStop = "${pkgs.tailscale}/bin/tailscale serve --https=8317 off";
            };
          };

      # Stop home writers if the volume mount disappears.
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
    })

    (lib.mkIf isAgent2 {
      agent-2-data-layout = {
        description = "Prepare persistent directories and ~/reviews symlink on /mnt/agent-2-data";
        after = [
          "local-fs.target"
          "mnt-agent\\x2d2\\x2ddata.mount"
        ];
        wantedBy = [
          "multi-user.target"
          "mnt-agent\\x2d2\\x2ddata.mount"
        ];
        unitConfig.ConditionPathIsMountPoint = "/mnt/agent-2-data";
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          ${pkgs.coreutils}/bin/install -d -m 0755 -o robert -g users \
            /mnt/agent-2-data/reviews \
            /mnt/agent-2-data/cargo-targets \
            /mnt/agent-2-data/cargo-cache

          if [ -L /home/robert/reviews ] || [ ! -e /home/robert/reviews ]; then
            ${pkgs.coreutils}/bin/ln -sfn /mnt/agent-2-data/reviews /home/robert/reviews
            ${pkgs.coreutils}/bin/chown -h robert:users /home/robert/reviews
          elif [ -d /home/robert/reviews ] && [ -z "$(${pkgs.coreutils}/bin/ls -A /home/robert/reviews)" ]; then
            ${pkgs.coreutils}/bin/rmdir /home/robert/reviews
            ${pkgs.coreutils}/bin/ln -s /mnt/agent-2-data/reviews /home/robert/reviews
            ${pkgs.coreutils}/bin/chown -h robert:users /home/robert/reviews
          else
            echo "Warning: /home/robert/reviews exists and is non-empty; leaving untouched" >&2
          fi
        '';
      };

      # Order user services after the persistent volume layout without blocking SSH if unmounted.
      "user@1000" = {
        overrideStrategy = "asDropin";
        after = [
          "mnt-agent\\x2d2\\x2ddata.mount"
          "agent-2-data-layout.service"
        ];
        wants = [
          "mnt-agent\\x2d2\\x2ddata.mount"
          "agent-2-data-layout.service"
        ];
      };
    })
  ];

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

  # The session of `ama agent start` in a shell here: the one that the
  # dashboards follow on this machine. Without it, the session is "default".
  environment.sessionVariables.AMA_SESSION = config.networking.hostName;

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
    python3 # Herdr's Codex hook needs it to report sessions, so a Herdr restart can resume them
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
    allMyAgents
    agents.ccusage
    ast-outline
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
    settings = {
      trusted-substituters = [
        "https://nix-community.cachix.org"
        "https://hyper-video.cachix.org"
      ];
    }
    // lib.optionalAttrs isAgent2 {
      # Bound Nix daemon parallelism so Nix builds do not starve or OOM active reviews.
      max-jobs = 4;
      cores = 4;
    };
  };

  systemd.tmpfiles.rules = [
    "d /home/robert/configs 0700 robert users -"
    "d /home/robert/projects 0755 robert users -"
    "d /home/robert/projects/hyper 0755 robert users -"
  ];

  system.stateVersion = "26.05";
}
