# Keep this module in sync with its copy at /home/robert/projects/ai/agent-fleet/nix/moshi.nix.
{
  config,
  inputs,
  lib,
  pkgs,
  user,
  ...
}:

let
  herdr = inputs.herdr-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
  moshiHook = pkgs.callPackage ../../custom/moshi-hook { };
in
{
  environment.systemPackages = [ moshiHook ];

  users.users.${user}.linger = true;

  systemd.user.services.moshi-hook = {
    description = "Moshi hook daemon";
    wantedBy = [ "default.target" ];
    path = [
      pkgs.git
      herdr
      pkgs.iproute2
      pkgs.lsof
      pkgs.procps
      pkgs.sqlite
    ]
    ++ lib.optionals config.virtualisation.docker.enable [ pkgs.docker-client ];

    unitConfig.ConditionUser = user;

    serviceConfig = {
      Type = "simple";
      WorkingDirectory = "%h";
      ExecStartPre = "${moshiHook}/bin/moshi-hook install";
      ExecStart = "${moshiHook}/bin/moshi-hook serve";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
