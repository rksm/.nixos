# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  options = {
    mount_k8s.enable = lib.mkEnableOption "Mount k8s nfs disk";
  };

  config = {

    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" =
      {
        device = "/dev/disk/by-uuid/bf100d5f-a11c-46b3-830f-77d8aff11217";
        fsType = "ext4";
      };

    fileSystems."/boot" =
      {
        device = "/dev/disk/by-uuid/52B9-549F";
        fsType = "vfat";
      };

    # littlelinux
    fileSystems."/mnt/k8s" = lib.mkIf config.mount_k8s.enable
      {
        device = "100.81.249.52:/mnt/DB_DISK/podwriter_k8s_nfs";
        fsType = "nfs";
        options = [ "x-systemd.automount" "noauto" ];
        # options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
      };

    swapDevices =
      [{ device = "/dev/disk/by-uuid/27dd2751-e2e7-44a7-ab08-44ea012a4dd1"; }];

    networking.useDHCP = lib.mkDefault true;
    networking.interfaces.enp5s0.wakeOnLan.enable = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    # Bootloader.
    boot.loader.systemd-boot.enable = false;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.grub.enable = true;
    boot.loader.grub.efiSupport = true;
    boot.loader.grub.devices = [ "nodev" ];
    boot.loader.grub.useOSProber = true;
  };
}
