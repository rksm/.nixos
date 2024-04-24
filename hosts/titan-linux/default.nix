{ inputs, config, pkgs, options, user, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../shared/linux
  ];

  mount_linux_data.enable = true;
  mount_k8s.enable = true;
  nvidia.enable = false;
  fhs.enable = false;
  setup_docker.enable = true;
  mullvad.enable = true;
}
