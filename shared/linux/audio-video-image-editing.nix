{ config, lib, pkgs, modulesPath, ... }:

{
  options = {
    audio-video-image-editing.enable = lib.mkEnableOption "Enable Nvidia";
  };

  config = lib.mkIf config.audio-video-image-editing.enable
    (let
      # NVENC support is built into OBS independently of this flag. Enabling
      # cudaSupport here misses the binary cache and currently trips GCC 15 ICEs.
      obsPackage = pkgs.obs-studio.override { cudaSupport = false; };
    in
    {
      environment.systemPackages = with pkgs; [
        # The base media packages inherit global cudaSupport through dependencies,
        # forcing large local builds. The latest set has the same app versions
        # here without CUDA-enabled deps and substitutes from cache.
        pkgs.latest.krita
        pkgs.latest.darktable
        inkscape
        # for video editing
        latest.kdePackages.kdenlive
        audacity

        simplescreenrecorder
        latest.yt-dlp
      ];

      programs.obs-studio = {
        enable = true;
        enableVirtualCamera = true;
        package = obsPackage;
        plugins = [
          # obs-backgroundremoval
          (pkgs.obs-studio-plugins.obs-source-record.override { obs-studio = obsPackage; })
          (pkgs.obs-studio-plugins.obs-pipewire-audio-capture.override { obs-studio = obsPackage; })
        ];
      };
    });
}
