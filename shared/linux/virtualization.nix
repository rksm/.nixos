{ inputs, config, pkgs, lib, options, user, machine, ... }: {
  options = {
    virt-manager.enable = lib.mkEnableOption "Enable virt-manager";
  };

  config = lib.mkIf config.virt-manager.enable {
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
        interfaces = [ (if machine == "titan-linux" then "eno2" else "enp5s0") ];
      };
    };

    users.users.${user}.extraGroups = [ "libvirtd" ];
  };
}
