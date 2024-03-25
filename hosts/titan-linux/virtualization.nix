{ inputs, config, pkgs, options, ... }: {
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
}
