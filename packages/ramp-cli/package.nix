# Ramp's official release is a Nuitka standalone directory: one executable
# plus its own Python runtime and shared libraries. We install the directory
# as is and wrap the executable into bin/. Run ./update.sh to bump the version.
{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  zlib,
}:

let
  version = "0.2.83";

  # Nix system -> upstream asset suffix and SRI hash of the release tarball.
  assets = {
    x86_64-linux = {
      name = "linux-amd64";
      hash = "sha256-heMRhwh5Y+kqNEETqX9hgz9j7z6SPBNmxpISZ/Q1HRk=";
    };
    aarch64-linux = {
      name = "linux-arm64";
      hash = "sha256-bsmIgg1JJt7knbv5WAFJNnDIT/zE17UnIETBQLyJh5Y=";
    };
    # Upstream also ships darwin-amd64, but nixpkgs-unstable dropped x86_64-darwin.
    aarch64-darwin = {
      name = "darwin-arm64";
      hash = "sha256-+xZr1wU/qJpQJSM5ZFF8Se1JW8IAt2SdcAJweT9FkNQ=";
    };
  };

  system = stdenvNoCC.hostPlatform.system;
  asset = assets.${system} or (throw "ramp-cli: unsupported system ${system}");
in

stdenvNoCC.mkDerivation {
  pname = "ramp-cli";
  inherit version;

  src = fetchurl {
    url = "https://github.com/ramp-public/ramp-cli/releases/download/v${version}/ramp-${asset.name}.tar.gz";
    inherit (asset) hash;
  };

  # The bundled libraries cover everything except glibc, zlib, and the
  # libgcc_s that ramp-router-agent links.
  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [
    zlib
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/libexec $out/bin
    cp -r . $out/libexec/ramp-cli
    # The CLI names itself after the resolved executable in --help output.
    mv $out/libexec/ramp-cli/ramp-${asset.name} $out/libexec/ramp-cli/ramp
    # Nuitka finds its bundled files next to the resolved executable path,
    # so the wrapper execs the real file in libexec.
    # RAMP_NO_UPDATE_CHECK stops the daily GitHub version check and the
    # "run ramp update" hints. --set forces it even if the caller unsets it.
    # Updates go through ./update.sh, never `ramp update`.
    makeWrapper $out/libexec/ramp-cli/ramp $out/bin/ramp \
      --set RAMP_NO_UPDATE_CHECK 1
    runHook postInstall
  '';

  meta = {
    description = "Ramp Developer CLI: interact with Ramp's API from your terminal";
    homepage = "https://github.com/ramp-public/ramp-cli";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = builtins.attrNames assets;
    mainProgram = "ramp";
  };
}
