{ pkgs, lib, nixosConfig, ... }: {

  home.packages = with pkgs; [
    zip
    unzip
    gnused
    gnutar
    rclone
    killall
    vlc
    drawio
    libreoffice
    # see https://github.com/NixOS/nixpkgs/issues/348845
    stable.calibre
    pandoc
    texlive.combined.scheme-small # for pandoc pdf support: https://discourse.nixos.org/t/what-are-the-best-practices-regarding-pandoc-when-one-simply-wants-a-conversion-to-pdf/11889/2
    stable.zettlr # markdown editor
    typora # markdown editor
    normcap # ocr from screenshots
    pavucontrol
    flare-signal
    whatsie # whatsapp desktop client
    parsec-bin # remote control
    rksm.uniclip # share clipboard over network
    rksm.unsure # calculator for uncertain numbers
    (callPackage ../../packages/dsnote { }) # speech-to-text note taking app
    slack
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
