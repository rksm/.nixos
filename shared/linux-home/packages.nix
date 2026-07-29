{ pkgs, lib, nixosConfig, ... }:
let
  accessibleSlack = pkgs.symlinkJoin {
    name = "slack-accessible";
    paths = [ pkgs.slack ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/slack \
        --set GTK_MODULES "gail:atk-bridge" \
        --add-flags "--force-renderer-accessibility"
      cp --remove-destination ${pkgs.slack}/share/applications/slack.desktop \
        $out/share/applications/slack.desktop
      substituteInPlace $out/share/applications/slack.desktop \
        --replace-fail "${pkgs.slack}/bin/slack" "$out/bin/slack"
    '';
  };
in {

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
    # calibre # temporarily disabled - onnxruntime CUDA build failure

    # markdown
    pandoc
    mermaid-filter
    mermaid-cli

    texlive.combined.scheme-small # for pandoc pdf support: https://discourse.nixos.org/t/what-are-the-best-practices-regarding-pandoc-when-one-simply-wants-a-conversion-to-pdf/11889/2
    zettlr # markdown editor
    typora # markdown editor
    normcap # ocr from screenshots
    pavucontrol
    flare-signal
    parsec-bin # remote control
    rksm.uniclip # share clipboard over network
    rksm.unsure # calculator for uncertain numbers
    accessibleSlack

    telegram-desktop
  ] ++ (lib.optionals nixosConfig.mullvad.enable [
    qbittorrent
    mullvad-vpn
  ]);

  xdg.mimeApps = {
    enable = true;
    associations.added = {
      "application/pdf" = [ "org.gnome.Evince.desktop" ];
      "text/html" = [ "firefox.desktop" ];
      "application/xhtml+xml" = [ "firefox.desktop" ];
      "image/png" = [ "org.gnome.Loupe.desktop" ];
      "video/webm" = [ "audacity.desktop" "vlc.desktop" ];
      "video/mp4" = [ "vlc.desktop" ];
      # "application/json" = ["emacsclient.desktop"];
      "video/x-matroska" = [ "vlc.desktop" ];
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [ "writer.desktop" ];
      "image/heif" = [ "org.darktable.darktable.desktop" ];
    };
    defaultApplications = {
      "application/pdf" = [ "org.gnome.Evince.desktop" ];
      "text/html" = [ "firefox.desktop" ];
      "application/xhtml+xml" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/about" = [ "firefox.desktop" ];
      "x-scheme-handler/unknown" = [ "firefox.desktop" ];
      "image/png" = [ "org.gnome.Loupe.desktop" ];
      "video/webm" = [ "vlc.desktop" ];
      "video/mp4" = [ "vlc.desktop" ];
      "application/json" = [ "emacsclient.desktop" ];
      "video/x-matroska" = [ "vlc.desktop" ];
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [ "writer.desktop" ];
      "image/heif" = [ "org.darktable.darktable.desktop" ];
    };
  };

}
