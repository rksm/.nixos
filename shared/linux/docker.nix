{ config, lib, pkgs, ... }:
{
  options = {
    setup_docker.enable = lib.mkEnableOption "Docker";
  };

  config = lib.mkIf config.setup_docker.enable {
    virtualisation.docker = {
      enable = true;
      enableNvidia = config.nvidia.enable;
      daemon.settings.insecure-registries = [ "docker-registry.podwriter:5000" ];
    };

    hardware.nvidia-container-toolkit.enable = config.nvidia.enable;
    virtualisation.podman = {
      enable = true;
    };

    environment.systemPackages = with pkgs; [
      docker-compose
    ];
  };
}
