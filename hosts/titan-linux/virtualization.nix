{ inputs, config, pkgs, options, ... }: {
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  environment.systemPackages = with pkgs; [
    virtio-win
    virtiofsd
  ];
}