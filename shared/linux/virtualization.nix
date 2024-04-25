{ inputs, config, pkgs, lib, options, user, ... }: {
  options = {
    virt-manager.enable = lib.mkEnableOption "Enable virt-manager";
  };

  config = {
    programs.virt-manager.enable = true;

    environment.systemPackages = with pkgs; [
      spice
      spice-gtk
      spice-protocol
      virt-viewer
      virtio-win
      virtiofsd
      win-spice
      win-virtio
    ];

    services.spice-vdagentd.enable = true;

    virtualisation = {
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

    networking.interfaces.br0.useDHCP = true;
    networking.bridges = {
      "br0" = {
        interfaces = [ "eno2" ];
      };
    };

    users.users.${user}.extraGroups = [ "libvirtd" ];
  };
}
