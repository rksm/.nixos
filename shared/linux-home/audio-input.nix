{ config, pkgs, ... }:
{
  # Install the package
  home.packages = [ pkgs.gnome-voice-input ];

  # Create a user systemd service
  systemd.user.services.gnome-voice-input = {
    Unit = {
      Description = "GNOME Voice Input";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.gnome-voice-input}/bin/gnome-voice-input";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
