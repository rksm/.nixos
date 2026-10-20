# firefox-cli built from its latest GitHub release. Firefox only keeps signed
# extensions, and upstream signs the extension only for releases. Main can
# speak a protocol that no signed extension supports yet. `just update-ai`
# runs nix-update --use-github-releases on this file, which rewrites version,
# hash, and the node_modules hash.
{
  lib,
  stdenvNoCC,
  bun,
  fetchFromGitHub,
  jq,
  writableTmpDirAsHomeHook,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "firefox-cli";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "respawn-llc";
    repo = "firefox-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9D+C5u0qVTKJZ1PKlLikx6r5Yo0waE8Y5MAHnGrDRk4=";
  };

  node_modules = stdenvNoCC.mkDerivation {
    pname = "${finalAttrs.pname}-node_modules";
    inherit (finalAttrs) version src;

    impureEnvVars = lib.fetchers.proxyImpureEnvVars;
    nativeBuildInputs = [
      bun
      writableTmpDirAsHomeHook
    ];

    dontConfigure = true;
    # The build only bundles TypeScript and runs no package binaries. So pin
    # the platform of the optional native packages, which gives one hash for
    # every system. Bun links the .bin entries and its hidden fallback
    # .bun/node_modules nondeterministically. The build uses neither, so drop
    # them.
    buildPhase = ''
      runHook preBuild
      bun install \
        --frozen-lockfile \
        --ignore-scripts \
        --no-progress \
        --os=linux \
        --cpu=x64
      find . -type d -name .bin -prune -exec rm -rf {} +
      rm -rf node_modules/.bun/node_modules
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      find . -type d -name node_modules -prune -exec cp -R --parents {} $out \;
      runHook postInstall
    '';
    dontFixup = true;

    outputHash = "sha256-VhqgCTbiOSKB3ZUGGCNtbSh+djHnTaM4BSdT+ZkYw6M=";
    outputHashMode = "recursive";
  };

  nativeBuildInputs = [
    bun
    jq
    writableTmpDirAsHomeHook
  ];

  configurePhase = ''
    runHook preConfigure
    cp -R ${finalAttrs.node_modules}/. .
    runHook postConfigure
  '';

  # One executable serves as both the CLI and the Firefox native messaging host.
  buildPhase = ''
    runHook preBuild
    bun build packages/cli/src/entrypoint.ts --compile --outfile firefox-cli
    runHook postBuild
  '';

  # Let the CLI write its own native messaging manifest, so the manifest
  # matches what `firefox-cli doctor` expects for this store path.
  installPhase = ''
    runHook preInstall
    install -Dm755 firefox-cli $out/bin/firefox-cli
    mkdir -p $out/lib/mozilla/native-messaging-hosts
    $out/bin/firefox-cli setup native-host --dry-run --json \
      | jq .manifest > $out/lib/mozilla/native-messaging-hosts/firefox_cli.json
    mkdir -p $out/share/firefox-cli/skills
    cp -r skills/firefox-cli $out/share/firefox-cli/skills/
    runHook postInstall
  '';

  # strip removes the JavaScript bundle from the executable.
  dontStrip = true;

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/firefox-cli --version
    test -f $out/share/firefox-cli/skills/firefox-cli/SKILL.md
    runHook postInstallCheck
  '';

  meta = {
    description = "Let AI agents control your real Firefox browser from a terminal";
    homepage = "https://github.com/respawn-llc/firefox-cli";
    license = lib.licenses.agpl3Only;
    mainProgram = "firefox-cli";
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
  };
})
