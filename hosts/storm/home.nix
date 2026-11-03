{ config, pkgs, lib, user, nixosConfig, inputs, ... }:

{
  imports = [
    ../../shared/linux-home
    inputs.herdr-dashboard.homeManagerModules.default
  ];

  services.herdr-dashboard = {
    enable = true;
    session = "storm";
    # The checkout's file, so that edits reach the service without a switch.
    configFile = "${config.home.homeDirectory}/projects/ai/herdr-dashboard/config.yaml";
    # tailscale-serve-herdr-dashboard in default.nix forwards this name.
    tailnet = {
      host = "storm.taileff843.ts.net";
      user = "robert@hyper.video";
    };
  };

  home.stateVersion = "24.05";
}
