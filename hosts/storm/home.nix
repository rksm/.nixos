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

  # `just switch` evaluates as root, and root cannot fetch this private input
  # over SSH. Nix uses the locked source when it is in the store, so keep it
  # there: otherwise the weekly garbage collection removes it.
  # A newly locked source is safe only after the next switch. If the garbage
  # collection removes it before then, run `nix flake archive` as robert in
  # /etc/nixos, then switch again.
  home.extraDependencies = [ inputs.herdr-dashboard.outPath ];

  home.stateVersion = "24.05";
}
