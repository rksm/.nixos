# The Herdr dashboard: the user service, its config, the programs it runs, the
# Chrome app that opens it, and its address on the tailnet. It reads the Herdr
# session that shared/linux/herdr.nix runs.
{
  inputs,
  pkgs,
  user,
  ...
}:

{
  # Serves the Herdr dashboard to the tailnet at https://storm.taileff843.ts.net.
  # The dashboard takes these requests only from robert's login; see
  # services.herdr-dashboard.tailnet below.
  systemd.services.tailscale-serve-herdr-dashboard = {
    description = "Expose the Herdr dashboard to the tailnet";
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
    };

    # A switch that restarts tailscaled starts this unit before the backend runs.
    script = ''
      ${pkgs.tailscale}/bin/tailscale wait --timeout=60s
      ${pkgs.tailscale}/bin/tailscale serve --bg --yes 4780
    '';
    preStop = "${pkgs.tailscale}/bin/tailscale serve --https=443 off";
  };

  home-manager.users.${user} =
    { config, ... }:
    let
      fromConfigs = path: config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/${path};
    in
    {
      imports = [ inputs.herdr-dashboard.homeManagerModules.default ];

      services.herdr-dashboard = {
        enable = true;
        session = "storm";
        # tailscale-serve-herdr-dashboard above forwards this name.
        tailnet = {
          host = "storm.taileff843.ts.net";
          user = "robert@hyper.video";
        };
      };

      systemd.user.services.herdr-dashboard.Unit = {
        Requires = [ "herdr.service" ];
        After = [ "herdr.service" ];
      };

      home.file.".config/herdr-dashboard/config.yaml".source =
        fromConfigs "herdr-dashboard/config.linux.yaml";
      home.file.".config/herdr-dashboard/snippets".source = fromConfigs "herdr-dashboard/snippets";

      home.packages = [
        # The dashboard's completion.copilot-command: GitHub's Copilot language
        # server, for the suggestions in the prompt box. The service finds it on
        # PATH. It uses the login that Emacs's copilot-login made.
        pkgs.copilot-language-server
        # The dashboard's focus-hook in its config.yaml: after f, it brings the
        # WezTerm tab with the Herdr client to the front. wezterm comes from PATH.
        (pkgs.writeShellApplication {
          name = "herdr-raise-terminal";
          runtimeInputs = [
            pkgs.coreutils
            pkgs.gnugrep
            pkgs.jq
            pkgs.procps
            pkgs.systemd
          ];
          text = builtins.readFile ./herdr-raise-terminal.sh;
        })
        # Opens the dashboard's Chrome app. The ID is that of Robert's install
        # from Chrome's Install button. google-chrome-stable comes from PATH,
        # with the flags of shared/linux/packages.nix.
        (pkgs.writeShellScriptBin "herdr-dashboard-app" ''
          exec google-chrome-stable --profile-directory=Default --app-id=cecmnpaehipjmeaddffmcbgdcehodjga "$@"
        '')
      ];
    };
}
