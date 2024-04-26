{ config, lib, pkgs, ... }:
{
  options = {
    setup_docker.enable = lib.mkEnableOption "Docker";
  };

  config = lib.mkIf config.setup_docker.enable {
    virtualisation.docker = {
      enableNvidia = config.nvidia.enable;
      enable = true;
      daemon.settings.insecure-registries = [ "docker-registry.podwriter:5000" ];
    };
  };
}
