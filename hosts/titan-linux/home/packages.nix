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
    zoom-us
    libreoffice
    calibre
  ] ++ (lib.optionals nixosConfig.mullvad.enable [
    transmission_4-qt
    mullvad-vpn
  ]);

  xdg.mimeApps = {
    enable = true;
    associations.added = {
      "application/pdf" = ["org.gnome.Evince.desktop"];
    };
    defaultApplications = {
      "application/pdf" = ["org.gnome.Evince.desktop"];
    };
  };

}
