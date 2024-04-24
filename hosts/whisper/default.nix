{ inputs, config, pkgs, options, user, machine, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../shared/linux
  ];

  ssh-password-auth.enable = false;
  mount_k8s.enable = false;
  nvidia.enable = true;
  fhs.enable = false;
  setup_docker.enable = false;
  syncthing.enable = false;
  tailscale.enable = false;
  mullvad.enable = false;
}
