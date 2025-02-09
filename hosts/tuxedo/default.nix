{ inputs, config, pkgs, options, user, machine, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./nvidia-tuxedo.nix
    ../../shared/linux
  ];

  system.stateVersion = "24.11";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # laptop / tuxedo related

  services.thermald.enable = true;
  hardware.tuxedo-rs = {
    enable = false;
    tailor-gui.enable = false;
  };
  hardware.tuxedo-drivers.enable = true;
  hardware.tuxedo-control-center = {
    enable = true;
    package = pkgs.tuxedo-control-center;
  };

  # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # second disk

  boot.initrd.luks.devices."luks-3cbe84a6-b4d5-41ba-ab16-38c2fafe70f7".device = "/dev/disk/by-uuid/3cbe84a6-b4d5-41ba-ab16-38c2fafe70f7";
  fileSystems."/mnt/DATA" =
    {
      device = "/dev/disk/by-uuid/e3595dfb-a020-4a86-8345-0c641efc7df1";
      fsType = "ext4";
    };

  # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # customizations

  audio-video-image-editing.enable = true;
  firewall.enable = false;
  gaming.enable = false;
  local-nix-cache.enable = false;
  mullvad.enable = true;
  nvidia-laptop.enable = true;
  postgres.enable = false;
  printing.enable = false;
  setup_docker.enable = true;
  ssh-password-auth.enable = false;
  tailscale.enable = true;
  virt-manager.enable = true;

  syncthing = {
    enable = true;
    enable-org = true;
    enable-documents = true;
    enable-configs = true;
    enable-emacs = true;
    enable-projects-biz = true;
    enable-projects-infra = true;
    enable-projects-python = false;
    enable-projects-rust = true;
    enable-projects-typescript = false;
    enable-projects-website = true;
    enable-projects-shuttle = true;
    enable-media = false;
  };
}
