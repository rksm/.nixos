{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
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
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "agent-sh";
    repo = "computer-use-linux";
    tag = "v${finalAttrs.version}";
    hash = "sha256-D4UF1gdPcfBmgVdVquQXo8i5WGutquXgXa41Du8Pq0Q=";
  };
  cargoHash = "sha256-+Eum9F6jBsLSlqSr8E8QL1dnlCyjPe8ekPhKZqc5/+A=";

  patches = [ ./bound-app-discovery.patch ];

  nativeBuildInputs = [ makeWrapper ];
  nativeCheckInputs = [ dbus ];
  # Executable fixtures and process-wide environment changes need serial tests.
  checkFlags = [ "--test-threads=1" ];

  postPatch = ''
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
