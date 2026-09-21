{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  coreutils,
  dbus,
  glib,
  gnome-screenshot,
  procps,
  wmctrl,
  xdotool,
  xprop,
  ydotool,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "computer-use-linux";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "agent-sh";
    repo = "computer-use-linux";
    tag = "v${finalAttrs.version}";
    hash = "sha256-L+5/2NQ7urS/TvlOEZn+A3b88gGV4tLUDDQMEZ7kLCQ=";
  };
  cargoHash = "sha256-ckkjnf0oIfpWjuUA7zVT6ardq5n3UdHOqgFVG93pAFA=";

  patches = [ ./bound-app-discovery.patch ];

  nativeBuildInputs = [ makeWrapper ];
  nativeCheckInputs = [ dbus ];
  # Executable fixtures and process-wide environment changes need serial tests.
  checkFlags = [ "--test-threads=1" ];

  postPatch = ''
    # Notification tests need executable paths that exist in the Nix sandbox.
    substituteInPlace src/server.rs \
      --replace-fail '/bin/true' '${coreutils}/bin/true' \
      --replace-fail '/bin/false' '${coreutils}/bin/false'
    # Keep test socket paths below AF_UNIX's limit inside the Nix build directory.
    substituteInPlace src/ydotool.rs \
      --replace-fail 'computer-use-linux-ydotool-{label}-{}-{}' 'cu-{label}-{}-{}'
    substituteInPlace src/windowing/backends/kwin.rs \
      --replace-fail '"--session", "--nofork"' '"--config-file=${dbus}/share/dbus-1/session.conf", "--nofork"'
  '';

  postInstall = ''
    mkdir -p $out/share/gnome-shell/extensions
    cp -r gnome-shell-extension/${finalAttrs.passthru.extensionUuid} \
      $out/share/gnome-shell/extensions/
    wrapProgram $out/bin/computer-use-linux \
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
