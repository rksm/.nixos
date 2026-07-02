{ lib, pkgs, user, ... }:

let
  vibetyperAppImage = "/home/${user}/projects/ai/ViberTyper/VibeTyper.AppImage";

  vibetyper = pkgs.writeShellScriptBin "vibetyper" ''
    set -euo pipefail

    appimage=${lib.escapeShellArg vibetyperAppImage}

    if [ ! -e "$appimage" ]; then
      echo "VibeTyper AppImage does not exist: $appimage" >&2
      exit 1
    fi

    if [ ! -x "$appimage" ]; then
      echo "VibeTyper AppImage is not executable: $appimage" >&2
      echo "Run: chmod +x $appimage" >&2
      exit 1
    fi

    exec "$appimage" "$@"
  '';

  vibetyperDesktopItem = pkgs.makeDesktopItem {
    name = "vibetyper";
    desktopName = "VibeTyper";
    comment = "Launch VibeTyper from its self-updating AppImage";
    exec = "${vibetyper}/bin/vibetyper %U";
    terminal = false;
    categories = [ "Utility" ];
  };
in
{
  config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    programs.appimage = {
      enable = true;
      binfmt = true;
    };

    # VibeTyper's Wayland mode uses evdev for global hotkeys and wl-copy for
    # clipboard insertion on native Wayland compositors. The AppImage stays
    # mutable outside the Nix store so upstream self-updates can still work.
    environment.systemPackages = with pkgs; [
      wl-clipboard
    ] ++ [
      vibetyper
      vibetyperDesktopItem
    ];

    users.users.${user}.extraGroups = [ "input" ];
  };
}
