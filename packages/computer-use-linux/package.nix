{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  coreutils,
  dbus,
  glib,
  gnome-screenshot,
  libxkbcommon,
  procps,
  python3,
  wmctrl,
  xdotool,
  xprop,
  ydotool,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "computer-use-linux";
  version = "0.7.46";

  src = fetchFromGitHub {
    owner = "agent-sh";
    repo = "computer-use-linux";
    tag = "v${finalAttrs.version}";
    hash = "sha256-m6jg21QnX9ET0IHjdSuZtQopWZbslrM/ZBemytU1p2k=";
  };
  cargoHash = "sha256-i+B5SOWge0WYVsqgnPmvkHCXbWFBks8NniiLJLwCGis=";

  patches = [ ./bound-app-discovery.patch ];

  nativeBuildInputs = [ makeWrapper ];
  nativeCheckInputs = [
    dbus
    python3
  ];
  env.LD_LIBRARY_PATH = lib.makeLibraryPath [ libxkbcommon ];
  # Executable fixtures and process-wide environment changes need serial tests.
  checkFlags = [
    "--test-threads=1"
    # These fixtures run /usr/bin/python3 or set PATH=/usr/bin:/bin.
    "--skip=gnome_indicator_capture_regressions"
    "--skip=gnome_fractional_pointer_reaches_full_eis_region"
    "--skip=app_state_refuses_unfocused_target_before_capture"
    "--skip=hyprland_background_mode_never_focuses_the_target"
  ];

  preCheck = ''
    export HOME="$TMPDIR"
    export XDG_CACHE_HOME="$TMPDIR/.cache"
  '';

  postPatch = ''
    # Test helpers need executable paths that exist in the Nix sandbox.
    substituteInPlace src/server.rs \
      --replace-fail '/bin/cat' '${coreutils}/bin/cat' \
      --replace-fail '/bin/cp' '${coreutils}/bin/cp' \
      --replace-fail '/bin/true' '${coreutils}/bin/true' \
      --replace-fail '/bin/false' '${coreutils}/bin/false'
    substituteInPlace src/diagnostics.rs \
      --replace-fail '/bin/sleep' '${coreutils}/bin/sleep'
    # The pointer test child clears TMPDIR, so its ydotool probe socket lands in
    # the harness directory. Keep that path below AF_UNIX's limit under /build.
    substituteInPlace src/server.rs \
      --replace-fail '"{prefix}-{}-{}"' '"cu-p-{}-{}"'
    # These tests clear PATH before they start their private bus.
    substituteInPlace src/gnome_extension.rs tests/window_targeting_setup.rs \
      --replace-fail 'Command::new("dbus-daemon")' 'Command::new("${dbus}/bin/dbus-daemon")'
    substituteInPlace src/windowing/backends/kwin.rs src/atspi_tree.rs \
      --replace-fail '"--session", "--nofork"' '"--config-file=${dbus}/share/dbus-1/session.conf", "--nofork"'
  '';

  postInstall = ''
    mkdir -p $out/share/gnome-shell/extensions
    cp -r gnome-shell-extension/${finalAttrs.passthru.extensionUuid} \
      $out/share/gnome-shell/extensions/
    wrapProgram $out/bin/computer-use-linux \
      --prefix LD_LIBRARY_PATH : ${finalAttrs.env.LD_LIBRARY_PATH} \
      --prefix PATH : ${
        lib.makeBinPath [
          glib
          gnome-screenshot
          procps
          wmctrl
          xdotool
          xprop
          ydotool
        ]
      }
  '';

  passthru.extensionUuid = "computer-use-linux@avifenesh.dev";

  meta = {
    description = "Linux desktop control through MCP and accessibility APIs";
    homepage = "https://github.com/agent-sh/computer-use-linux";
    license = lib.licenses.mit;
    mainProgram = "computer-use-linux";
    platforms = lib.platforms.linux;
  };
})
