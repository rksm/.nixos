{ pkgs, ... }:
{
  services.syncthing = {
    enable = true;
    user = "robert";
    group = "users";
    dataDir = "/home/robert/.local/share/syncthing";
    configDir = "/home/robert/.config/syncthing";
    guiAddress = "127.0.0.1:8384";
    openDefaultPorts = true;
    overrideDevices = true;
    overrideFolders = true;

    settings = {
      gui.insecureSkipHostcheck = true;

      devices = {
        airy.id = "3RES5O5-HOBSBFM-WGADO2O-ODCAW7Y-PRP3FGS-POM2OTY-XUP5WZG-SVJUYAW";
        mbp.id = "ESRECEY-LRO4O4F-W6T4MCD-JJEUB23-UEMKLC6-3CAPFXO-B75BGCG-V2SIQA6";
        nas.id = "5WBWSJB-OUNGDKD-HMT7CDM-TTMOZ7J-3F7CJMA-ED6RHAQ-P2LYPKR-ISZ5JQY";
        storm.id = "CLPXG4D-HFUVBBU-UVFTOKW-K6RTSPB-4SRS3V2-FAEOK5Y-W577FYA-LG4PTAQ";
        titan-linux.id = "RYQZGHF-73GMHMW-UC6U4U7-FR5AXRH-MOIM7VY-DWVVYCH-JENHYTW-4LBYKAN";
        tuxedo.id = "ZBIN2HO-EGA5WIN-UVJES3W-VMQJWSR-YKCZ5LS-ZZLZHHK-NTR75Z3-SDMGXA4";
      };

      folders = {
        configs = {
          id = "configs";
          path = "/home/robert/configs";
          devices = [
            "airy"
            "mbp"
            "nas"
            "storm"
            "titan-linux"
            "tuxedo"
          ];
        };

        "projects/hyper" = {
          id = "projects/hyper";
          path = "/home/robert/projects/hyper";
          devices = [
            "airy"
            "nas"
            "storm"
            "tuxedo"
          ];
        };
      };

      options.urAccepted = 1;
    };
  };

  systemd.services.tailscale-serve-syncthing = {
    description = "Expose the Syncthing web UI to the tailnet";
    after = [
      "network-online.target"
      "syncthing.service"
      "tailscaled.service"
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

    script = ''
      ${pkgs.tailscale}/bin/tailscale serve --bg --yes 8384
    '';
  };
}
