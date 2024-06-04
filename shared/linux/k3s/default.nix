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

    services.k3s = {
      enable = true;
      role = "agent";
      serverAddr = "https://linuxmini.tail2787e.ts.net:6443";
      tokenFile = ../../../shared/secrets/k3s-token.key;
    };

    virtualisation.containers = {
      enable = true;
    };

    virtualisation.containerd = {
      enable = true;
    };
  };
}
