{ inputs, config, pkgs, options, user, machine, lib, ... }:
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

  # The FK BIOS sets both CPU package power limits to an unsafe 4095 W.
  systemd.services.intel-cpu-power-limits = {
    description = "Set Intel CPU package power limits";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    unitConfig.ConditionPathExists = "/sys/class/powercap/intel-rapl:0";
    serviceConfig.Type = "oneshot";
    script = ''
      echo 253000000 > /sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw
      echo 253000000 > /sys/class/powercap/intel-rapl:0/constraint_1_power_limit_uw
    '';
  };

  # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

  audio-video-image-editing.enable = true;
  gaming.enable = true;
  networking.wireless.enable = lib.mkForce false;
  mullvad.enable = true;
  nvidia.enable = true;
  hardware.nvidia.open = true;
  postgres.enable = false;
  printing.enable = true;
  setup_docker.enable = true;
  ssh-password-auth.enable = false;
  tailscale.enable = true;
  virt-manager.enable = true;

  firewall.enable = false;
  mount_k8s.enable = false;
  mount_nas_nfs.enable = false;

  syncthing = {
    enable = true;
    enable-org = true;
    enable-documents = true;
    enable-configs = true;
    enable-emacs = true;
    enable-projects-ai = true;
    enable-projects-biz = true;
    enable-projects-finances = true;
    enable-projects-home = true;
    enable-projects-hyper = true;
    enable-projects-infra = true;
    enable-projects-python = true;
    enable-projects-rust = true;
    enable-projects-security = false;
    enable-projects-shuttle = true;
    enable-projects-typescript = true;
    enable-projects-website = true;
    enable-khoone = true;
  };

}
