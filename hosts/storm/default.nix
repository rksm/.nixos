{ inputs, config, pkgs, options, user, machine, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../shared/linux
  ];

  ssh-password-auth.enable = false;
  mount_k8s.enable = true;
  nvidia.enable = true;
  setup_docker.enable = true;
  virt-manager.enable = false;
  syncthing.enable = true;
  tailscale.enable = true;
  mullvad.enable = true;
  gaming.enable = true;
  printing.enable = true;
  postgres.enable = true;
}
