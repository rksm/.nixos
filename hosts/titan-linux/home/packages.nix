{ pkgs, lib, nixosConfig, ... }: {

  home.packages = with pkgs; [
    zip
    unzip
    gnused
    gnutar
    killall
    wineWowPackages.staging
    vlc
    drawio
  ] ++ (lib.optionals nixosConfig.mullvad.enable [
    transmission_4-qt
    mullvad-vpn
  ]);
}
