{
  lib,
  stdenvNoCC,
  makeWrapper,
  computer-use-linux,
  bash,
  bubblewrap,
  coreutils,
  dbus,
  dconf,
  glib,
  gnome-shell,
  gnome-console,
  gnome-text-editor,
  gnomeExtensions,
  pipewire,
  util-linux,
  at-spi2-core,
  xdg-desktop-portal,
  xdg-desktop-portal-gnome,
  xdg-desktop-portal-gtk,
}:

let
  extensions = [
    computer-use-linux
    gnomeExtensions.allow-gnome-screenshot
  ];
in
stdenvNoCC.mkDerivation {
  pname = "computer-use-desktop";
  inherit (computer-use-linux) version;
  src = ./.;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin $out/libexec
    substitute separate.sh $out/bin/computer-use-separate \
      --subst-var-by computerUse ${computer-use-linux}/bin/computer-use-linux \
      --subst-var-by session $out/libexec/session
    substitute session.sh $out/libexec/session \
      --subst-var-by extensionUuids '${
        builtins.toJSON (map (extension: extension.extensionUuid) extensions)
      }'
    chmod +x $out/bin/computer-use-separate $out/libexec/session
    wrapProgram $out/bin/computer-use-separate \
      --prefix GIO_EXTRA_MODULES : ${lib.getLib dconf}/lib/gio/modules \
      --prefix PATH : ${
        lib.makeBinPath [
          bash
          bubblewrap
          computer-use-linux
          coreutils
          dbus
          glib
          gnome-shell
          gnome-console
          gnome-text-editor
          pipewire
          util-linux
        ]
      } \
      --prefix XDG_DATA_DIRS : ${
        lib.makeSearchPath "share" (
          extensions
          ++ [
            at-spi2-core
            gnome-shell
            gnome-console
            gnome-text-editor
            xdg-desktop-portal
            xdg-desktop-portal-gnome
            xdg-desktop-portal-gtk
          ]
        )
      }
    makeWrapper ${computer-use-linux}/bin/computer-use-linux $out/bin/computer-use-live \
      --prefix GIO_EXTRA_MODULES : ${lib.getLib dconf}/lib/gio/modules \
      --set-default COMPUTER_USE_LINUX_FORCE_PORTAL_KEYBOARD 1 \
      --set-default COMPUTER_USE_LINUX_SCREENSHOT_BACKEND gnome-screenshot
    for mode in live separate; do
      cat > $out/bin/codex-desktop-$mode <<EOF
    #!${bash}/bin/bash
    exec codex \\
      -c 'mcp_servers.desktop.command="$out/bin/computer-use-$mode"' \\
      -c 'mcp_servers.desktop.args=["mcp"]' \\
      -c 'mcp_servers.desktop.env_vars=["DISPLAY","WAYLAND_DISPLAY","XAUTHORITY","DBUS_SESSION_BUS_ADDRESS","AT_SPI_BUS_ADDRESS","XDG_RUNTIME_DIR","XDG_CURRENT_DESKTOP","XDG_SESSION_TYPE","XDG_DATA_DIRS","XDG_CONFIG_DIRS","XDG_CONFIG_HOME","XDG_DATA_HOME","XDG_STATE_HOME","YDOTOOL_SOCKET"]' \\
      -c 'mcp_servers.desktop.startup_timeout_sec=180' \\
      "\$@"
    EOF
      chmod +x $out/bin/codex-desktop-$mode
    done
  '';

  passthru.gnomeExtensions = extensions;

  meta = {
    description = "MCP desktop control for the current or a separate GNOME session";
    inherit (computer-use-linux.meta) homepage license platforms;
    mainProgram = "computer-use-separate";
  };
}
