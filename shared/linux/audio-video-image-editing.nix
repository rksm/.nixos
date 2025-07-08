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
        kdePackages.kdenlive
        audacity

        simplescreenrecorder

        # obs-studio
        (pkgs.latest.wrapOBS {
          plugins = with pkgs.latest.obs-studio-plugins; [
            obs-backgroundremoval
            obs-source-record
            obs-pipewire-audio-capture
          ];
        })
      ];

      # obs virtual camera support
      # https://github.com/NixOS/nixpkgs/issues/251655
      boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
      boot.kernelModules = [ "v4l2loopback" ];
      boot.extraModprobeConfig = ''
        options v4l2loopback devices=1 video_nr=1 card_label="My OBS Virt Cam" exclusive_caps=1
      '';
      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
            if (action.id == "org.freedesktop.policykit.exec" &&
                action.lookup("program") == "/run/current-system/sw/bin/modprobe" &&
                subject.isInGroup("users")) {
                return polkit.Result.YES;
            }
        });
      '';
    };
}
