{ config, pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    tailscale
  ];

  networking.extraHosts = ''
    # linuxmini
    100.80.30.54 alertmanager.podwriter
    100.80.30.54 prometheus.podwriter
    100.80.30.54 grafana.podwriter
    100.80.30.54 traefik.podwriter
    100.80.30.54 dashboard.podwriter
    100.92.70.42 grafana.kra.hn

    # AUTOGENERATED
    # 192.168.137.1 podwriter-1.podwriter
    100.92.70.42 podwriter-1.podwriter
    # 192.168.137.2 titan.podwriter
    # 192.168.137.3 littlelinux.podwriter
    # 192.168.137.4 littlelinux2.podwriter
    # # 192.168.137.5 linuxmini.podwriter
    # 192.168.137.6 ubuntu-p50.podwriter
    # 192.168.137.7 website.krahn
    # 192.168.137.8 littlelinux-ff-1.podwriter
    # 192.168.137.9 t430.podwriter
    # 192.168.137.100 iphone
    100.109.127.110 docker-registry.podwriter # tailscale ubuntu-p50

    2a01:4f9:c011:bb54::1 greenesy01
    2a01:4f8:c0c:5a50::1 greenesy02
    2a01:4f8:c2c:aed8::1 greenesy03
  '';

  # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # Tailscale
  services.tailscale = {
    enable = true;
    authKeyFile = "/etc/tailscale/tailscale.key";
  };
  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script =
      let key = builtins.readFile ../../shared/secrets/tailscale-auth.key;
      in
      with pkgs; ''
        # wait for tailscaled to settle
        sleep 2

        # check if we are already authenticated to tailscale
        status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
        if [ $status = "Running" ]; then # if so, then do nothing
          exit 0
        fi

        # otherwise authenticate with tailscale
        ${tailscale}/bin/tailscale up -authkey ${key}
      '';
  };
}
