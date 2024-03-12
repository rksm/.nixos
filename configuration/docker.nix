{ config, pkgs, ... }:
{
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      "runtimes" = {
        "nvidia" = {
          "args" = [];
          "path" = "${pkgs.nvidia-docker}/bin/nvidia-container-runtime";
        };
      };
      "default-runtime" = "nvidia";
      "insecure-registries" = ["docker-registry.podwriter:5000"];
    };
  };
}
