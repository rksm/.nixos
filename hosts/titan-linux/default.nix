{ inputs, config, pkgs, options, user, machine, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../shared/linux
  ];

  mount_linux_data.enable = true;

  ssh-password-auth.enable = true;
  mount_k8s.enable = true;
  nvidia.enable = false;
  fhs.enable = false;
  setup_docker.enable = true;
  syncthing.enable = true;
  tailscale.enable = true;
  mullvad.enable = true;
}
