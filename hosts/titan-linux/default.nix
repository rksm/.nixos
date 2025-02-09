{ inputs, config, pkgs, options, user, machine, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../shared/linux
  ];

  system.stateVersion = "24.05";
  networking.wireless.enable = false;

  # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

  ssh-password-auth.enable = false;
  nvidia.enable = true;
  setup_docker.enable = false;
  virt-manager.enable = false;
  syncthing.enable = false;
  tailscale.enable = true;
  k3s.enable = true;
  firewall.enable = false;

  mount_k8s.enable = true;
  mount_linux_data.enable = true;
}
