{ config, pkgs, lib, user, nixosConfig, ... }:

{
  imports = [
    ../../shared/linux-home
  ];
}
