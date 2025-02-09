{ config, pkgs, lib, user, nixosConfig, ... }:

{
  imports = [
    ../../shared/linux-home
  ];

  home.stateVersion = "24.11";
}
