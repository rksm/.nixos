{ pkgs, ... }:

{
  home.packages = [ pkgs.computer-use-desktop ] ++ pkgs.computer-use-desktop.gnomeExtensions;

  dconf.settings."org/gnome/shell".enabled-extensions = map (
    extension: extension.extensionUuid
  ) pkgs.computer-use-desktop.gnomeExtensions;

  systemd.user.services.ydotoold = {
    Unit = {
      Description = "Input control for the current desktop";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.ydotool}/bin/ydotoold --socket-path=%t/.ydotool_socket --socket-perm=0600";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
