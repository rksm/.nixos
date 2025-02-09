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
  tailscale.enable = true;
  k3s.enable = true;
  firewall.enable = false;

  mount_k8s.enable = true;
  mount_linux_data.enable = true;

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
    enable-media = true;
  };
}
