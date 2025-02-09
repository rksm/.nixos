{ inputs, config, pkgs, options, user, machine, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../shared/linux
  ];

  system.stateVersion = "24.05";

  more-nix-substituters = [
    "http://storm.fritz.box:8180/local"
  ];
  more-nix-trusted-public-keys = [
    "local:p0ZZsZhdZwWzeJJDuSD/HL5pMmEW+UO7aMAXm25XPCo="
  ];
  networking.wireless.enable = false;

  # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

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

  local-nix-cache.enable = true;
}
