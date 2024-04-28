{ config, pkgs, lib, ... }:
{
  options =
    {
      gaming.enable = lib.mkEnableOption "gaming";
    };

  config = lib.mkIf config.gaming.enable {
    environment.systemPackages = with pkgs; [
      steam
      lutris
    ];
  };
}
