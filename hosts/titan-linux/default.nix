{ inputs, config, pkgs, options, user, machine, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../shared/linux
  ];

  ssh-password-auth.enable = false;
  mount_k8s.enable = true;
  nvidia.enable = true;
  setup_docker.enable = false;
  virt-manager.enable = false;
  syncthing.enable = false;
  tailscale.enable = true;
  k3s.enable = true;

  mount_linux_data.enable = true;
}
