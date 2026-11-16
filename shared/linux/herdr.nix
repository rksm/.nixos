# Herdr, the terminal multiplexer for coding agents: the package, its config,
# its skill, and the server of this machine's session. pkgs.herdr comes from
# the herdr-nix overlay in flake.nix.
{
  pkgs,
  user,
  machine,
  ...
}:

{
  home-manager.users.${user} =
    { config, ... }:
    let
      fromConfigs = path: config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/${path};
    in
    {
      imports = [ ../../macos/herdr-skill.nix ];

      home.packages = [ pkgs.herdr ];

      home.file.".config/herdr".source = fromConfigs "herdr";

      systemd.user.services.herdr = {
        Unit = {
          Description = "Herdr ${machine} session";
          # A Home Manager switch must not stop the server and its running panes.
          X-SwitchMethod = "keep-old";
        };
        Service = {
          # Pane shells need the same login environment as interactive shells.
          Environment = [ "HERDR_SESSION=${machine}" ];
          # A user unit cannot order itself after the system's tailscaled.service.
          ExecStartPre = "${pkgs.tailscale}/bin/tailscale wait --timeout=60s";
          ExecStart = "${pkgs.bash}/bin/bash -lc 'exec ${pkgs.herdr}/bin/herdr server'";
          Restart = "on-failure";
          RestartSec = 5;
        };
        Install.WantedBy = [ "default.target" ];
      };
    };
}
