{ fetchurl
, lib
, stdenvNoCC
,
}:

let
  release = import ./version.nix;
  source =
    release.sources.${stdenvNoCC.hostPlatform.system}
      or (throw "moshi-hook: unsupported system ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "moshi-hook";
  inherit (release) version;

  src = fetchurl {
    url = "https://cdn.getmoshi.app/hook/v${release.version}/${source.asset}";
    inherit (source) hash;
  };

  sourceRoot = ".";
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 moshi-hook "$out/bin/moshi-hook"

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/moshi-hook version | grep -F "moshi-hook ${release.version}"

    runHook postInstallCheck
  '';

  meta = {
    description = "Daemon and CLI that connects AI coding agents to Moshi";
    homepage = "https://getmoshi.app";
    license = lib.licenses.unfree;
    mainProgram = "moshi-hook";
    platforms = builtins.attrNames release.sources;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
