#!/usr/bin/env bash
set -euo pipefail

if [[ ${1:-} == --help || ${1:-} == -h ]]; then
    cat <<'EOF'
Usage: computer-use-separate [mcp|doctor|apps|windows|screenshot]
       computer-use-separate --run COMMAND [ARG...]

Open a separate GNOME desktop in a window. Defaults to the MCP stdio server.
The desktop closes when the command exits or you close its viewer window.
Save work before ending the MCP session. Application profiles persist.
The current directory is available in the desktop at ~/workspace.
EOF
    exit 0
fi

: "${XDG_RUNTIME_DIR:?Run this command from your Wayland desktop session}"
: "${WAYLAND_DISPLAY:?Run this command from your Wayland desktop session}"
parent_display=$WAYLAND_DISPLAY
[[ $parent_display == /* ]] || parent_display="$XDG_RUNTIME_DIR/$parent_display"
if [[ ! -S $parent_display ]]; then
    echo "Wayland socket not found: $parent_display" >&2
    exit 1
fi

profile="${XDG_STATE_HOME:-$HOME/.local/state}/computer-use-desktop"
mkdir -p "$profile/home/workspace"
chmod 700 "$profile" "$profile/home"
exec 9>"$profile/lock"
if ! flock -n 9; then
    echo "The separate desktop is already running. Close it before starting another." >&2
    exit 75
fi
runtime=$(mktemp -d "$XDG_RUNTIME_DIR/computer-use.XXXXXX")
trap 'rm -rf -- "$runtime"' EXIT

if [[ ${1:-} == --run ]]; then
    shift
    if (( $# == 0 )); then
        echo "--run requires a command." >&2
        exit 1
    fi
else
    if (( $# == 0 )); then
        set -- mcp
    fi
    set -- @computerUse@ "$@"
fi

# A private /dev and runtime directory prevent input fallbacks reaching the host.
# Mount the profile over the existing home path; HOME itself stays unchanged.
gpu_devices=(--dev-bind-try /dev/dri /dev/dri)
for device in /dev/nvidia*; do
    if [[ -c $device && -r $device && -w $device ]]; then
        gpu_devices+=(--dev-bind "$device" "$device")
    fi
done
bwrap --die-with-parent --new-session --unshare-pid --unshare-ipc --unshare-uts \
    --bind / / --dev /dev --proc /proc --tmpfs /tmp \
    "${gpu_devices[@]}" \
    --bind "$profile/home" "$HOME" \
    --bind "$runtime" "$XDG_RUNTIME_DIR" \
    --ro-bind "$parent_display" "$XDG_RUNTIME_DIR/parent-wayland" \
    --bind "$PWD" "$HOME/workspace" --chdir "$HOME/workspace" \
    --unsetenv DBUS_SESSION_BUS_ADDRESS --unsetenv AT_SPI_BUS_ADDRESS \
    --unsetenv DISPLAY --unsetenv XAUTHORITY --unsetenv SESSION_MANAGER \
    --setenv XDG_CONFIG_HOME "$HOME/.config" \
    --setenv XDG_DATA_HOME "$HOME/.local/share" \
    --setenv XDG_CACHE_HOME "$HOME/.cache" \
    --setenv XDG_STATE_HOME "$HOME/.local/state" \
    --setenv TMPDIR /tmp \
    --setenv XDG_CURRENT_DESKTOP GNOME --setenv XDG_SESSION_TYPE wayland \
    --setenv WAYLAND_DISPLAY "$XDG_RUNTIME_DIR/parent-wayland" \
    --setenv ATSPI_DBUS_IMPLEMENTATION dbus-daemon \
    --setenv CU_DISABLE_ABS_POINTER 1 \
    --setenv COMPUTER_USE_LINUX_FORCE_PORTAL_POINTER 1 \
    --setenv COMPUTER_USE_LINUX_FORCE_PORTAL_KEYBOARD 1 \
    --setenv COMPUTER_USE_LINUX_SCREENSHOT_BACKEND gnome-screenshot \
    --setenv YDOTOOL_SOCKET "$XDG_RUNTIME_DIR/no-host-input" \
    @session@ "$@"
