# Freestyle Focus Bridge

This GNOME Shell extension exposes the focused window to Freestyle over the
session D-Bus.

## Install

Copy or symlink this directory to the extension UUID:

```sh
mkdir -p ~/.local/share/gnome-shell/extensions
ln -s /path/to/freestyle/integrations/gnome-focus-bridge \
  ~/.local/share/gnome-shell/extensions/freestyle-focus-bridge@freestyle-voice.dev
```

Log out and back in. GNOME Shell cannot be reloaded in place on Wayland. Then
enable the extension:

```sh
gnome-extensions enable freestyle-focus-bridge@freestyle-voice.dev
```

Verify the bridge:

```sh
gdbus call --session \
  --dest com.freestyle.FocusBridge \
  --object-path /com/freestyle/FocusBridge \
  --method com.freestyle.FocusBridge.GetActiveWindow
```

The result is a tuple containing a JSON string for the focused window, or
`('{}',)` when no window is focused.

On NixOS, no nixpkgs packaging is required. Home Manager users can link this
directory into the same extension path.
