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
    libreoffice
    calibre
    pandoc
    normcap # ocr from screenshots
    pavucontrol
    kdenlive
  ] ++ (lib.optionals nixosConfig.mullvad.enable [
    qbittorrent
    mullvad-vpn
  ]);

  xdg.mimeApps = {
    enable = true;
    associations.added = {
      "application/pdf" = ["org.gnome.Evince.desktop"];
      "text/html" = ["firefox.desktop"];
      "application/xhtml+xml" = ["firefox.desktop"];
      "image/png" = ["org.gnome.Loupe.desktop"];
    };
    defaultApplications = {
      "application/pdf" = ["org.gnome.Evince.desktop"];
      "text/html" = ["firefox.desktop"];
      "application/xhtml+xml" = ["firefox.desktop"];
      "image/png" = ["org.gnome.Loupe.desktop"];
    };
  };

}
