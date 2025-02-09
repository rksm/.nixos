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
  services.thermald.enable = true;
  hardware.tuxedo-rs = {
    enable = true;
    tailor-gui.enable = true;
  };
  hardware.tuxedo-drivers.enable = true;
  # boot.kernelParams = [
  #   "tuxedo_keyboard.mode=0"
  #   "tuxedo_keyboard.brightness=25"
  #   "tuxedo_keyboard.color_left=0x0000ff"
  # ];

  hardware.tuxedo-control-center.enable = true;
  hardware.tuxedo-control-center.package = pkgs.tuxedo-control-center;

  # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

  audio-video-image-editing.enable = true;
  firewall.enable = false;
  gaming.enable = false;
  local-nix-cache.enable = false;
  mullvad.enable = false;
  nvidia-laptop.enable = true;
  postgres.enable = false;
  printing.enable = false;
  setup_docker.enable = false;
  ssh-password-auth.enable = true;
  syncthing.enable = false;
  tailscale.enable = false;
  virt-manager.enable = false;
}
