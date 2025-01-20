{ inputs, config, pkgs, lib, options, user, machine, ... }: {
  options = {
    virt-manager.enable = lib.mkEnableOption "Enable virt-manager";
  };

  config = lib.mkIf config.virt-manager.enable {
    programs.virt-manager.enable = true;

    environment.systemPackages = with pkgs; [
      qemu
      spice
      spice-gtk
      spice-protocol
      virt-manager
      virt-viewer
      virtio-win
      virtiofsd
      win-spice
      win-virtio

      # wineWowPackages.staging
      wineWow64Packages.unstableFull
      virtualbox
    ];

    services.spice-vdagentd.enable = true;

    virtualisation = {
      # sharedDirectories = {
      #   my-share = {
      #     source = "/home/robert/Downloads";
      #     target = "/mnt/shared";
      #   };
      # };
      libvirtd = {
        enable = true;
        allowedBridges = [ "br0" ];
        qemu = {
          package = pkgs.qemu_kvm;
          swtpm.enable = true;
          ovmf.enable = true;
          ovmf.packages = [ pkgs.OVMFFull.fd ];
        };
      };
      spiceUSBRedirection.enable = true;
    };

    users.users.${user}.extraGroups = [ "libvirtd" ];
  };
}
