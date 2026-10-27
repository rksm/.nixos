# Runs https://github.com/hypervideo/roberts-review-bot on agent-1. The bot runs from the Syncthing copy of its
# repository, so an edit to review-prompt.md applies to the next review. A code change needs
# `systemctl --user restart roberts-review-bot`.
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
in
{
  config = lib.mkIf (config.networking.hostName == "agent-1") {
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
          # A login shell gives the panes the environment of an SSH session. Without it, each pane's shell sets up the
          # NixOS environment again, which replaces PATH and drops the bot's gh wrapper.
          ExecStart = "${pkgs.bash}/bin/bash -lc 'exec ${herdr}/bin/herdr --session roberts-review-bot server'";
          Restart = "on-failure";
          RestartSec = 5;
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
  };
}
