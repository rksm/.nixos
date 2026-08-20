# Mirror a local publish directory to a Cloudflare R2 bucket.
#
# watchexec watches the directory and triggers `rclone sync` on changes.
# Every run reconciles the full tree, so deletions propagate and missed
# events heal on the next change. Disabled by default; enable with:
#
#   services.agent-files = {
#     enable = true;
#     bucket = "agent-files";
#     environmentFile = "/path/to/agent-files-r2.env";
#   };
{ config, lib, pkgs, ... }:

let
  cfg = config.services.agent-files;

  sync = pkgs.writeShellApplication {
    name = "agent-files-sync";
    runtimeInputs = [ pkgs.watchexec pkgs.rclone ];
    text = ''
      set -a
      # shellcheck disable=SC1090,SC1091
      source ${lib.escapeShellArg cfg.environmentFile}
      set +a

      export RCLONE_CONFIG_R2_TYPE=s3
      export RCLONE_CONFIG_R2_PROVIDER=Cloudflare
      export RCLONE_CONFIG_R2_REGION=auto
      # Scoped R2 tokens cannot probe the bucket; skip the check.
      export RCLONE_CONFIG_R2_NO_CHECK_BUCKET=true

      mkdir -p ${lib.escapeShellArg cfg.directory}

      # --ignore-nothing: watchexec must not filter events through gitignore files.
      # --on-busy-update queue: changes during a running sync cause one follow-up run.
      # --use-server-modtime --update: compare against upload time, saves one HEAD per object.
      exec watchexec \
        --watch ${lib.escapeShellArg cfg.directory} \
        --debounce 2s \
        --on-busy-update queue \
        --ignore-nothing \
        -- rclone sync ${lib.escapeShellArg cfg.directory} ${lib.escapeShellArg "r2:${cfg.bucket}"} \
        --use-server-modtime --update
    '';
  };
in
{
  options.services.agent-files = {
    enable = lib.mkEnableOption "mirroring the agent-files directory to a Cloudflare R2 bucket";

    directory = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/agent-files";
      description = "Directory to watch. Local deletions delete the bucket objects.";
    };

    bucket = lib.mkOption {
      type = lib.types.str;
      description = "Name of the R2 bucket.";
    };

    environmentFile = lib.mkOption {
      type = lib.types.str;
      description = ''
        Path to a file with the R2 credentials, sourced at start. Keep this a
        string, not a nix path, so the secrets stay out of the nix store.
        Expected variables: RCLONE_CONFIG_R2_ACCESS_KEY_ID,
        RCLONE_CONFIG_R2_SECRET_ACCESS_KEY and RCLONE_CONFIG_R2_ENDPOINT
        (https://<account-id>.r2.cloudflarestorage.com).
      '';
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      systemd.user.services.agent-files = {
        Unit.Description = "Mirror ${cfg.directory} to R2 bucket ${cfg.bucket}";
        Service = {
          ExecStart = lib.getExe sync;
          Restart = "on-failure";
          RestartSec = 5;
        };
        Install.WantedBy = [ "default.target" ];
      };
    })

    (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      launchd.agents.agent-files = {
        enable = true;
        config = {
          ProgramArguments = [ (lib.getExe sync) ];
          RunAtLoad = true;
          KeepAlive = true;
          StandardOutPath = "${config.home.homeDirectory}/Library/Logs/agent-files.log";
          StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/agent-files.log";
        };
      };
    })
  ]);
}
