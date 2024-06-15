{ config, lib, pkgs, modulesPath, ... }:

{
  options = {
    audio-video-image-editing.enable = lib.mkEnableOption "Enable Nvidia";
  };

  config = lib.mkIf config.audio-video-image-editing.enable
    {
      environment.systemPackages = with pkgs; [
        krita
        inkscape
        # for video editing
        kdenlive
        obs-studio
        audacity
      ];

    };
}
