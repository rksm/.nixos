{ config, lib, pkgs, modulesPath, ... }:

{
  options = {
    printing.enable = lib.mkEnableOption "Enable printing support";
  };

  # 2024-05-15: Hmmm needs a
  # lpstat -p -d
  # cupsenable Brother_HL_L2375DW_series
  # ???
  config = lib.mkIf config.printing.enable {
    services.printing.enable = true;
    services.printing.drivers = with pkgs; [
      gutenprint
      brlaser
      # brgenml1lpr
      # brgenml1cupswrapper
    ];
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };

}
