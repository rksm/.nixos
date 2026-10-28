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
  version = "0.7.31";

  src = fetchFromGitHub {
    owner = "agent-sh";
    repo = "computer-use-linux";
    tag = "v${finalAttrs.version}";
    hash = "sha256-I7OxwCNSHEj4rgpsQKtxGxPIqu9qS7VVdve59nGSEb0=";
  };
  cargoHash = "sha256-u9up/X7eV1PvNonG9uUw4oV0z7ELAHeB00sd1gkzw9s=";

  patches = [ ./bound-app-discovery.patch ];

  nativeBuildInputs = [ makeWrapper ];
  nativeCheckInputs = [
    dbus
    python3
  ];
  env.LD_LIBRARY_PATH = lib.makeLibraryPath [ libxkbcommon ];
  # Executable fixtures and process-wide environment changes need serial tests.
  checkFlags = [ "--test-threads=1" ];

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
    # Keep test socket paths below AF_UNIX's limit inside the Nix build directory.
    substituteInPlace src/server.rs \
      --replace-fail 'cul-pointer-safety-{}-{}' 'cu-p-{}-{}'
    substituteInPlace src/windowing/backends/kwin.rs src/gnome_extension.rs src/atspi_tree.rs \
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
