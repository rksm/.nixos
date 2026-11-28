# Runs https://github.com/hypervideo/roberts-review-bot across the fleet:
# - agent-1: controller (webhook funnel + bot service) and local fallback Herdr worker.
# - agent-2: burst Herdr worker only, with isolated local Herdr runtime state.
# The bot runs from the Syncthing copy of its repository, so an edit to review.yaml applies at its
# next use. A code change needs `systemctl --user restart roberts-review-bot` on agent-1.
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  herdr = inputs.herdr-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
  repository = "/home/robert/projects/hyper/roberts-review-bot";
  port = 3000;
  webhookPath = "/api/github/webhooks";
  isAgent1 = config.networking.hostName == "agent-1";
  isAgent2 = config.networking.hostName == "agent-2";
in
{
  config = lib.mkMerge [
    (lib.mkIf isAgent1 {
      # GitHub sends webhooks to https://agent-1.taileff843.ts.net:8443/api/github/webhooks, and Funnel publishes only
      # that path. Port 443 is not an option: Funnel on it would also publish the tailnet-only Syncthing UI.
      systemd.services.tailscale-funnel-roberts-review-bot = {
        description = "Expose the roberts-review-bot webhook to the internet";
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
          ExecStartPre = "${pkgs.tailscale}/bin/tailscale wait --timeout=60s";
          ExecStart = "${pkgs.tailscale}/bin/tailscale funnel --bg --yes --https=8443 --set-path=${webhookPath} http://127.0.0.1:${toString port}${webhookPath}";
          ExecStop = "${pkgs.tailscale}/bin/tailscale funnel --https=8443 --set-path=${webhookPath} off";
        };
      };

      systemd.tmpfiles.rules = [
        "d /home/robert/.local/state/roberts-review-bot 0755 robert users -"
      ];

      home-manager.users.robert.systemd.user.services = {
        # Herdr API calls do not start a session server, so this unit keeps the session of the reviews running, also
        # after a reboot. Clients attach to it as usual with `herdr --session roberts-review-bot`.
        herdr-roberts-review-bot = {
          Unit = {
            Description = "Herdr session of roberts-review-bot";
            # Stopping the server ends all running reviews, so a switch leaves it running. A new Herdr version takes
            # effect after a reboot or a manual restart.
            X-SwitchMethod = "keep-old";
          };
          Service = {
            # The reviews get their own Herdr config, synced through ~/configs/herdr like the main one.
            Environment = [ "HERDR_CONFIG_PATH=/home/robert/.config/herdr/config.hyper-robbot.toml" ];
            # A login shell gives the panes the environment of an SSH session. Without it, each pane's shell sets up the
            # NixOS environment again, which replaces PATH and drops the bot's gh wrapper.
            ExecStart = "${pkgs.bash}/bin/bash -lc 'exec ${herdr}/bin/herdr --session roberts-review-bot server'";
            Restart = "on-failure";
            RestartSec = 5;
            # When agent-1 runs out of memory, the kernel kills one process, often a rustc of a review's build. With the
            # default policy, systemd then stops the whole unit and ends every running review. Only the killed process
            # should end.
            OOMPolicy = "continue";
            # Reviews build and test their code, and too many at once ran agent-1 out of memory. Matches the live 11G
            # limit on agent-1, keeping headroom for the system, SSH, Tailscale, and other sessions.
            MemoryMax = "11G";
          };
          Install.WantedBy = [ "default.target" ];
        };

        roberts-review-bot = {
          Unit = {
            Description = "roberts-review-bot";
            Wants = [ "herdr-roberts-review-bot.service" ];
            After = [ "herdr-roberts-review-bot.service" ];
          };
          Service = {
            WorkingDirectory = repository;
            Environment = [
              "REVIEW_BOT_ENV=/etc/nixos/shared/secrets/roberts-review-bot.env"
              "REVIEW_BOT_STATE_DB=/home/robert/.local/state/roberts-review-bot/state.sqlite"
              "REVIEW_BOT_SSH_KEY=/etc/nixos/shared/secrets/agent-fleet-ssh.key"
              "PORT=${toString port}"
            ];
            # Syncthing does not sync node_modules, so each start installs the dependencies from the lock file.
            ExecStartPre = "${pkgs.nodejs_24}/bin/npm ci --omit=dev";
            ExecStart = "${pkgs.nodejs_24}/bin/node src/main.ts";
            Restart = "on-failure";
            RestartSec = 5;
          };
          Install.WantedBy = [ "default.target" ];
        };
      };
    })

    (lib.mkIf isAgent2 {
      home-manager.users.robert =
        hmArgs:
        let
          fromConfigs = path: hmArgs.config.lib.file.mkOutOfStoreSymlink "/home/robert/configs/${path}";
        in
        {
          # shared/linux/herdr.nix symlinks all of ~/.config/herdr to ~/configs/herdr (Syncthing).
          # Override that on agent-2 so only the shared config files are synced, while sessions/,
          # herdr.sock, and logs stay local and never collide with agent-1's roberts-review-bot session.
          home.file = {
            ".config/herdr".enable = lib.mkForce false;
            ".config/herdr/config.toml".source = fromConfigs "herdr/config.toml";
            ".config/herdr/config.hyper-robbot.toml".source = fromConfigs "herdr/config.hyper-robbot.toml";
          };

          systemd.user.services.herdr-roberts-review-bot = {
            Unit = {
              Description = "Herdr session of roberts-review-bot";
              # Stopping the server ends all running reviews, so a switch leaves it running. A new Herdr version takes
              # effect after a reboot or a manual restart.
              X-SwitchMethod = "keep-old";
              RequiresMountsFor = [ "/mnt/agent-2-data" ];
            };
            Service = {
              Environment = [
                "HERDR_CONFIG_PATH=/home/robert/.config/herdr/config.hyper-robbot.toml"
                "CARGO_HOME=/mnt/agent-2-data/cargo-cache"
              ];
              ExecStart = "${pkgs.bash}/bin/bash -lc 'exec ${herdr}/bin/herdr --session roberts-review-bot server'";
              Restart = "on-failure";
              RestartSec = 5;
              OOMPolicy = "continue";
              # Reserve ~12 GB of ccx43's 64 GB RAM for the OS, Syncthing, SSH, Tailscale, and zram.
              MemoryMax = "52G";
            };
            Install.WantedBy = [ "default.target" ];
          };
        };
    })
  ];
}
