{ lib, pkgs, user, ... }:

let
  # Stable install path, refreshed with `just install-appimage` in the repo
  # after `just release`. Kept outside the Nix store so rebuilding the app
  # does not require a system switch.
  freestyleAppImage = "/home/${user}/projects/ai/freestyle/Freestyle.AppImage";

  freestyle = pkgs.writeShellScriptBin "freestyle" ''
    set -euo pipefail

    appimage=${lib.escapeShellArg freestyleAppImage}

    if [ ! -e "$appimage" ]; then
      echo "Freestyle AppImage does not exist: $appimage" >&2
      echo "Build and install it: just release && just install-appimage" >&2
      exit 1
    fi

    if [ ! -x "$appimage" ]; then
      echo "Freestyle AppImage is not executable: $appimage" >&2
      echo "Run: chmod +x $appimage" >&2
      exit 1
    fi

    exec "$appimage" "$@"
  '';

  freestyleDesktopItem = pkgs.makeDesktopItem {
    name = "freestyle";
    desktopName = "Freestyle";
    comment = "Voice dictation with desktop context";
    exec = "${freestyle}/bin/freestyle %U";
    icon = ../../packages/freestyle/icon.png;
    terminal = false;
    categories = [ "Utility" ];
    startupWMClass = "Freestyle";
  };
in
{
  config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    programs.appimage = {
      enable = true;
      binfmt = true;
    };

    # Freestyle uses evdev for the dictation hotkey, uinput for synthetic
    # keyboard input (paste), and wl-copy for clipboard insertion on Wayland.
    # Same requirements as vibetyper.nix; both modules declare them so either
    # can be removed independently.
    hardware.uinput.enable = true;

    environment.systemPackages = with pkgs; [
      wl-clipboard
    ] ++ [
      freestyle
      freestyleDesktopItem
    ];

    users.users.${user}.extraGroups = [ "input" "uinput" ];
  };
}
