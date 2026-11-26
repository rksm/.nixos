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
  nodejs,
  procps,
  python3,
  wmctrl,
  xdotool,
  xprop,
  ydotool,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "computer-use-linux";
  version = "0.7.64";

  src = fetchFromGitHub {
    owner = "agent-sh";
    repo = "computer-use-linux";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1V3x4YhBtVqq5ehWubKt6d7WbsT1FSL7TvL7ctGlov8=";
  };
  cargoHash = "sha256-GnO1cb9o8rlsBVIMDcb9FJ44nbnKEkDPinY4GUUGe54=";

  patches = [ ./bound-app-discovery.patch ];

  nativeBuildInputs = [ makeWrapper ];
  nativeCheckInputs = [
    dbus
    nodejs
    python3
  ];
  env.LD_LIBRARY_PATH = lib.makeLibraryPath [ libxkbcommon ];
  # Executable fixtures and process-wide environment changes need serial tests.
  checkFlags = [
    "--test-threads=1"
    # These fixtures run /usr/bin/python3 or set PATH=/usr/bin:/bin. Most
    # also need real display servers such as Xvfb, sway, GNOME, or KWin.
    "--skip=gnome_indicator_capture_regressions"
    "--skip=gnome_fractional_pointer_reaches_full_eis_region"
    "--skip=app_state_refuses_unfocused_target_before_capture"
    "--skip=hyprland_background_mode_never_focuses_the_target"
    "--skip=x11_agent_master_types_and_clicks_without_moving_the_user_focus"
    "--skip=sway_transient_seat_types_and_clicks_without_moving_seat0"
    "--skip=background_text_and_keys_reach_"
    "--skip=_pen_clicks_drags_and_scrolls_without_moving_the_user_pointer"
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
    substituteInPlace src/test_sockets.rs \
      --replace-fail 'Command::new("dbus-daemon")' 'Command::new("${dbus}/bin/dbus-daemon")'
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
          # The js REPL runs its scripts in a Node.js worker.
          nodejs
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
