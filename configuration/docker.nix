{ config, pkgs, ... }:
let
  enableNvidia = config.networking.hostName == "titan-linux";
in
{
  virtualisation.docker = {
    inherit enableNvidia;
    enable = true;
    daemon.settings.insecure-registries = [ "docker-registry.podwriter:5000" ];
  };
}
