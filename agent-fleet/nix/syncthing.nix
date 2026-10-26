{ lib, pkgs, ... }:
{
  imports = [ ../../shared/linux/syncthing.nix ];

  syncthing = {
    enable = true;
    enable-configs = true;
    enable-projects-ai = true;
    enable-projects-home = true;
    enable-projects-hyper = true;
  };

  services.syncthing = {
    group = "users";
    dataDir = lib.mkForce "/home/robert/.local/share/syncthing";
    openDefaultPorts = true;
    package = pkgs.latest.syncthing;
  };

  systemd.services.tailscale-serve-syncthing = {
    description = "Expose the Syncthing web UI to the tailnet";
    after = [
      "network-online.target"
      "syncthing.service"
      "tailscaled.service"
      # Concurrent serve config writes fail with an etag mismatch.
      "tailscale-serve-cli-proxy-api.service"
    ];
    requires = [
      "syncthing.service"
      "tailscaled.service"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = "5s";
    };

    # A switch that restarts tailscaled starts this unit before the backend runs.
    script = ''
      ${pkgs.tailscale}/bin/tailscale wait --timeout=60s
      ${pkgs.tailscale}/bin/tailscale serve --bg --yes 8384
    '';
  };
}
