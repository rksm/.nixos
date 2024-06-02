{ config, pkgs, lib, ... }:
let
  podwriter-hosts = ''
    # linuxmini
    # 100.80.30.54 alertmanager.podwriter
    # 100.80.30.54 prometheus.podwriter
    # 100.80.30.54 grafana.podwriter
    # 100.80.30.54 traefik.podwriter
    # 100.80.30.54 dashboard.podwriter
    # 100.92.70.42 grafana.kra.hn

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
  '';

  greenesy-hosts = ''
    2a01:4f9:c011:bb54::1 greenesy01
    2a01:4f8:c0c:5a50::1 greenesy02
    2a01:4f8:c2c:aed8::1 greenesy03
    2a01:4f8:1c1c:8d25::1 greenesy04
  '';
in
{
  networking.extraHosts = podwriter-hosts + "\n" + greenesy-hosts;
}
