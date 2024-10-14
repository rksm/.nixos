{ config, lib, pkgs, ... }:

{
  # needs tailscale!
  config = lib.mkIf (config.k3s.enable && config.nvidia.enable) {
    hardware.nvidia-container-toolkit.enable = true;

    environment.systemPackages = with pkgs; [
      nvidia-container-toolkit
      libnvidia-container
    ];

    systemd.services.k3s.path = with pkgs; [
      nvidia-container-toolkit
      libnvidia-container
    ];

    systemd.services.containerd.path = with pkgs; [
      containerd
      runc
      nvidia-container-toolkit
      libnvidia-container
    ];
  };
}
