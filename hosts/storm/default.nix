{ inputs, config, pkgs, options, user, machine, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../shared/linux
  ];

  ssh-password-auth.enable = false;
  nvidia.enable = true;
  setup_docker.enable = true;
  virt-manager.enable = true;
  syncthing.enable = true;
  tailscale.enable = true;
  mullvad.enable = true;
  gaming.enable = true;
  printing.enable = true;
  postgres.enable = false;
  audio-video-image-editing.enable = true;

  firewall.enable = false;
  mount_k8s.enable = true;
  mount_nas_nfs.enable = true;
}
