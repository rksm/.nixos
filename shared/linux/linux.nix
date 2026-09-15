{ config, pkgs, machine, user, ... }:
{
  # pinned to 6.18 because nvidia 580.119.02 doesn't compile against 6.19
  # TODO: switch back to linuxPackages_latest once nvidia 580.126.18 lands in nixos-25.11
  boot.kernelPackages = pkgs.linuxPackages_6_18;
  time.timeZone = "Europe/Berlin";

  # workaround for clickhouse emacs client:
  # https://github.com/ClickHouse/ClickHouse/issues/55998
  boot.kernel.sysctl = { "kernel.task_delayacct" = 1; };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # # wayland
  # services.xserver.enable = true;
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # no wayland
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.desktopManager.gnome.enable = true;
  programs.hyprland.xwayland.enable = false;

  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
  ]) ++ (with pkgs; [
    cheese # webcam tool
    epiphany # web browser
    geary # email reader
    yelp # Help view
    gnome-music
    gnome-characters
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
    gnome-contacts
    gnome-initial-setup
  ]);

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    # Mix the default microphone and output monitor into one input for apps.
    # Keep a physical microphone as the system default and select System + Mic
    # in the app. Capturing a call's output also sends other voices back to it.
    extraConfig.pipewire."90-system-mic" = {
      "context.objects" = [
        {
          factory = "adapter";
          args = {
            "factory.name" = "support.null-audio-sink";
            "node.name" = "system-mic-mix";
            "node.description" = "System + Mic Mix";
            # The mixer accepts both streams but stays hidden from app device lists.
            "media.class" = "Audio/Sink/Internal";
            "audio.position" = [ "FL" "FR" ];
            "node.virtual" = true;
            "node.link-group" = "system-mic-mix";
          };
        }
      ];
      # Mixer inputs must stay active; passive playback links can remain suspended.
      "context.modules" = [
        {
          name = "libpipewire-module-loopback";
          args = {
            "node.description" = "System + Mic: Microphone";
            "capture.props" = {
              # With no target, WirePlumber follows the default microphone.
              "node.name" = "system-mic-microphone";
              # Exclude the combined source when choosing a microphone.
              "node.link-group" = "system-mic-source";
              "node.passive" = true;
            };
            "playback.props" = {
              "target.object" = "system-mic-mix";
              # Never send the microphone to speakers if the mixer is missing.
              "node.dont-fallback" = true;
            };
          };
        }
        {
          name = "libpipewire-module-loopback";
          args = {
            "node.description" = "System + Mic: System Audio";
            "capture.props" = {
              "node.name" = "system-mic-system";
              # Follow the default output and capture its monitor ports.
              "stream.capture.sink" = true;
              # Sharing the mixer's link group prevents it from capturing itself.
              "node.link-group" = "system-mic-mix";
              "node.passive" = true;
            };
            "playback.props" = {
              "target.object" = "system-mic-mix";
              "node.dont-fallback" = true;
            };
          };
        }
        # Expose the mixed monitor as an input that apps can select.
        {
          name = "libpipewire-module-loopback";
          args = {
            "node.description" = "System + Mic";
            "capture.props" = {
              "target.object" = "system-mic-mix";
              "stream.capture.sink" = true;
              "node.dont-fallback" = true;
              "node.passive" = true;
            };
            "playback.props" = {
              "node.name" = "system-mic";
              "media.class" = "Audio/Source";
              "audio.position" = [ "FL" "FR" ];
              "node.link-group" = "system-mic-source";
              # Prefer physical microphones when choosing the system default.
              "priority.session" = 0;
            };
          };
        }
      ];
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
}
