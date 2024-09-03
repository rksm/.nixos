{ config, lib, pkgs, ... }:

{
  imports = [
    ./k3s-nvidia.nix
  ];

  options = {
    k3s.enable = lib.mkEnableOption "Enable k3s";
  };

  # FIXME: make  tailscale optional!
  config = lib.mkIf config.k3s.enable {

    environment.etc."rancher/k3s/registries.yaml".text = ''
      mirrors:
        "docker-registry.podwriter:5000":
          endpoint:
            - "http://docker-registry.podwriter:5000"
    '';

    # tailscale: ensure that routes are accessible! (should be done by the key
    # but can fail if logged in already... "edit route settings" in the
    # tailscale web interface)
    services.k3s = {
      enable = true;
      role = "agent";
      serverAddr = "https://linuxmini.tail2787e.ts.net:6443";
      tokenFile = ../../../shared/secrets/k3s-token.key;
      extraFlags = let key = builtins.readFile ../../../shared/secrets/tailscale-auth.key; in
        "--vpn-auth=name=tailscale,joinKey=${key}";

      package = pkgs.k3s;
    };


    systemd.services.k3s.path = with pkgs; [ tailscale ];

    virtualisation.containers = {
      enable = true;
    };

    virtualisation.containerd = {
      enable = true;
    };

    ##############################
    # needed for longhorn
    environment.systemPackages = with pkgs; [
      openiscsi
      nfs-ganesha
    ];
    services.rpcbind.enable = true; # needed for NFS
    # as per https://takingnotes.net/kubernetes/longhorn/
    system.activationScripts.usrlocalbin = ''
        mkdir -m 0755 -p /usr/local
        ln -nsf /run/current-system/sw/bin /usr/local/
    '';
    services.openiscsi = {
      enable = true;
      name = "iqn.2016-04.com.open-iscsi:${config.networking.hostName}";
    };
    ##############################
  };
}
