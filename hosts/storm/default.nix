{ inputs, config, pkgs, options, user, machine, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../shared/linux
  ];

  system.stateVersion = "24.05";

  # more-nix-substituters = [
  #   "http://storm.fritz.box:8180/local"
  # ];
  # more-nix-trusted-public-keys = [
  #   "local:p0ZZsZhdZwWzeJJDuSD/HL5pMmEW+UO7aMAXm25XPCo="
  # ];
  local-nix-cache.enable = false;

  # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

  audio-video-image-editing.enable = true;
  gaming.enable = true;
  networking.wireless.enable = false;
  mullvad.enable = true;
  nvidia.enable = true;
  postgres.enable = false;
  printing.enable = true;
  setup_docker.enable = true;
  ssh-password-auth.enable = false;
  tailscale.enable = true;
  virt-manager.enable = true;

  firewall.enable = false;
  mount_k8s.enable = true;
  mount_nas_nfs.enable = false;

  syncthing = {
    enable = true;
    enable-org = true;
    enable-documents = true;
    enable-configs = true;
    enable-emacs = true;
    enable-projects-biz = true;
    enable-projects-infra = true;
    enable-projects-python = true;
    enable-projects-rust = true;
    enable-projects-typescript = true;
    enable-projects-website = true;
    enable-projects-shuttle = true;
    enable-media = false;
  };

}
