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
  wmctrl,
  xdotool,
  xprop,
  ydotool,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "computer-use-linux";
  version = "0.7.13";

  src = fetchFromGitHub {
    owner = "agent-sh";
    repo = "computer-use-linux";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+xT6rQn38XcjCsRnMsZlZ9rcLf+yEPwTATooe+Aw18s=";
  };
  cargoHash = "sha256-dhbZKZYovSLrWoy73UXFE/d7NLHwwBuLxTfouDQa6zY=";

  patches = [ ./bound-app-discovery.patch ];

  nativeBuildInputs = [ makeWrapper ];
  nativeCheckInputs = [ dbus ];
  env.LD_LIBRARY_PATH = lib.makeLibraryPath [ libxkbcommon ];
  # Executable fixtures and process-wide environment changes need serial tests.
  checkFlags = [ "--test-threads=1" ];

  preCheck = ''
    export XDG_CACHE_HOME="$TMPDIR/.cache"
  '';

  postPatch = ''
    # Notification tests need executable paths that exist in the Nix sandbox.
    substituteInPlace src/server.rs \
      --replace-fail '/bin/true' '${coreutils}/bin/true' \
      --replace-fail '/bin/false' '${coreutils}/bin/false'
    substituteInPlace src/diagnostics.rs \
      --replace-fail '/bin/sleep' '${coreutils}/bin/sleep'
    # Keep test socket paths below AF_UNIX's limit inside the Nix build directory.
    substituteInPlace src/server.rs \
      --replace-fail 'cul-pointer-safety-{}-{}' 'cu-p-{}-{}'
    substituteInPlace src/windowing/backends/kwin.rs src/gnome_extension.rs \
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
