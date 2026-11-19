# all-my-agents: the dashboard that runs coding agents itself, without Herdr. It
# runs as a user service next to the Herdr dashboard (./herdr-dashboard.nix),
# with its own config and its own address on the tailnet. Its package also puts
# `ama` on the PATH, which starts and drives the agents.
#
# The Copilot language server and the llama-server for the prompt box's
# suggestions come from ./herdr-dashboard.nix. Move them here when that file
# goes.
{
  inputs,
  pkgs,
  user,
  machine,
  ...
}:
{
  # The session of `ama agent start` in a shell, so that the new agent shows
  # in this machine's dashboard. Without it, the session is "default".
  environment.sessionVariables.AMA_SESSION = machine;

  # Serves the dashboard to the tailnet at https://${machine}.taileff843.ts.net:8443.
  # Port 443 is the Herdr dashboard's. The dashboard takes these requests only
  # from robert's login; see services.all-my-agents.tailnet below.
  systemd.services.tailscale-serve-all-my-agents = {
    description = "Expose all-my-agents to the tailnet";
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
      ${pkgs.tailscale}/bin/tailscale serve --bg --yes --https=8443 4781
    '';
    preStop = "${pkgs.tailscale}/bin/tailscale serve --https=8443 off";
  };

  home-manager.users.${user} =
    { config, ... }:
    let
      fromConfigs = path: config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/${path};
    in
    {
      imports = [ inputs.all-my-agents.homeManagerModules.default ];

      services.all-my-agents = {
        enable = true;
        session = machine;
        # tailscale-serve-all-my-agents above forwards this name.
        tailnet = {
          host = "${machine}.taileff843.ts.net:8443";
          user = "robert@hyper.video";
        };
      };

      home.file.".config/all-my-agents/config.yaml".source =
        fromConfigs "all-my-agents/config.linux.yaml";
      # The same snippets as the Herdr dashboard's.
      home.file.".config/all-my-agents/snippets".source = fromConfigs "herdr-dashboard/snippets";
    };
}
