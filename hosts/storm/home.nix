{ config, pkgs, lib, user, nixosConfig, inputs, ... }:

{
  imports = [
    ../../shared/linux-home
    inputs.herdr-dashboard.homeManagerModules.default
  ];

  services.herdr-dashboard = {
    enable = true;
    session = "storm";
    # tailscale-serve-herdr-dashboard in default.nix forwards this name.
    tailnet = {
      host = "storm.taileff843.ts.net";
      user = "robert@hyper.video";
    };
  };

  systemd.user.services.herdr-dashboard.Unit = {
    Requires = [ "herdr.service" ];
    After = [ "herdr.service" ];
  };

  # The dashboard's focus-hook in its config.yaml: after f, it brings the
  # WezTerm tab with the Herdr client to the front. wezterm comes from PATH.
  home.packages = [
    (pkgs.writeShellApplication {
      name = "herdr-raise-terminal";
      runtimeInputs = [ pkgs.coreutils pkgs.gnugrep pkgs.jq pkgs.procps pkgs.systemd ];
      text = builtins.readFile ./herdr-raise-terminal.sh;
    })
    # Opens the dashboard's Chrome app. The ID is that of Robert's install
    # from Chrome's Install button. google-chrome-stable comes from PATH,
    # with the flags of shared/linux/packages.nix.
    (pkgs.writeShellScriptBin "herdr-dashboard-app" ''
      exec google-chrome-stable --profile-directory=Default --app-id=cecmnpaehipjmeaddffmcbgdcehodjga "$@"
    '')
  ];

  home.stateVersion = "24.05";
}
