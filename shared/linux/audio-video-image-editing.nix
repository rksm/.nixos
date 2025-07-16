{ config, lib, pkgs, modulesPath, ... }:

{
  options = {
    audio-video-image-editing.enable = lib.mkEnableOption "Enable Nvidia";
  };

  config = lib.mkIf config.audio-video-image-editing.enable
    {
      environment.systemPackages = with pkgs; [
        stable.krita
        inkscape
        # for video editing
        latest.kdePackages.kdenlive
        audacity

        simplescreenrecorder
      ];

      programs.obs-studio = {
        enable = true;
        enableVirtualCamera = true;
        package = pkgs.obs-studio.override { cudaSupport = config.nvidia.enable; };
        plugins = with pkgs.obs-studio-plugins; [
          # obs-backgroundremoval
          obs-source-record
          obs-pipewire-audio-capture
        ];
      };
    };
}
