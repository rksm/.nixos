{ config, pkgs, lib, ... }:

let
  # Path to the openclaw installation from the project directory
  openclawPath = "/home/robert/projects/shuttle/ai-bots-infra/node_modules/openclaw/dist/index.js";
  nodePath = "${pkgs.nodejs_22}/bin/node";
in
{
  systemd.services.openclaw-gateway = {
    description = "OpenClaw Gateway";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "simple";
      User = "robert";
      WorkingDirectory = "/home/robert";

      ExecStart = "${nodePath} ${openclawPath} gateway --port 18789";
      Restart = "always";
      RestartSec = 5;
      KillMode = "process";

      # Environment variables
      Environment = [
        "HOME=/home/robert"
        "OPENCLAW_GATEWAY_PORT=18789"
        "OPENCLAW_SERVICE_MARKER=openclaw"
        "OPENCLAW_SERVICE_KIND=gateway"
      ];

      # Optional: Load additional environment variables from file
      # Create /home/robert/.openclaw/.env if you need to store secrets
      # EnvironmentFile = lib.mkIf (builtins.pathExists "/home/robert/.openclaw/.env") "/home/robert/.openclaw/.env";
    };
  };
}
