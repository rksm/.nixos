#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$XDG_STATE_HOME/computer-use-desktop"
log="$XDG_STATE_HOME/computer-use-desktop/session.log"
exec 3<&0

# Bubblewrap owns the process lifetime; log D-Bus activations away from MCP stdout.
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
WAYLAND_DISPLAY=computer-use dbus-daemon --session \
    --address="$DBUS_SESSION_BUS_ADDRESS" --fork >"$log" 2>&1

gsettings set org.gnome.desktop.interface toolkit-accessibility true
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.shell enabled-extensions '@extensionUuids@'
gsettings set org.gnome.mutter.devkit launchers "[('desktop', 'org.gnome.Console', 'new-window')]"

# Keep desktop logs off the MCP stdout stream.
pipewire >>"$log" 2>&1 &
gnome-shell --devkit --wayland --wayland-display=computer-use \
    --virtual-monitor=1280x800 >>"$log" 2>&1 &
desktop_pid=$!

for (( attempt = 0; attempt < 150; attempt++ )); do
    if ! kill -0 "$desktop_pid" 2>/dev/null; then
        cat "$log" >&2
        exit 1
    fi
    if gdbus wait --session --timeout 1 dev.avifenesh.ComputerUseLinux.WindowControl 2>/dev/null; then
        break
    fi
done
if (( attempt == 150 )); then
    echo "The separate GNOME desktop did not become ready. See $log." >&2
    exit 1
fi

export WAYLAND_DISPLAY=computer-use
# Mutter publishes the nested Xwayland display and its cookie for child apps.
display_env=$(gdbus call --session --dest org.gnome.Mutter.Devkit \
    --object-path /org/gnome/Mutter/Devkit \
    --method org.freedesktop.DBus.Properties.Get org.gnome.Mutter.Devkit Env)
if [[ $display_env =~ \'DISPLAY\':\ \'([^\']+)\' ]]; then
    export DISPLAY="${BASH_REMATCH[1]}"
fi
if [[ $display_env =~ \'XAUTHORITY\':\ \'([^\']+)\' ]]; then
    export XAUTHORITY="${BASH_REMATCH[1]}"
fi
dbus-update-activation-environment WAYLAND_DISPLAY ${DISPLAY:+DISPLAY} ${XAUTHORITY:+XAUTHORITY}

"$@" <&3 &
command_pid=$!
set +e
wait -n "$desktop_pid" "$command_pid"
exit "$?"
