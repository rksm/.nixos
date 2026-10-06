# Adapted from the archived https://github.com/tfausak/linear-nix.
# `just update-linear-cli` pins the latest release.
{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  fetchFromGitHub,
  makeWrapper,
}:

let
  source =
    {
      x86_64-linux = {
        target = "x86_64-unknown-linux-gnu";
        hash = "sha256-UGSmOn5qi1iTpVDhOMCnujc6rWXUJd3msrZrUKbBAok=";
      };
      aarch64-darwin = {
        target = "aarch64-apple-darwin";
        hash = "sha256-heuE55VUSld63Be5b4sAdxvOyU840mRC/X1WHNgjNvI=";
      };
    }
    .${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "linear-cli";
  version = "3.0.0";

  src = fetchurl {
    url = "https://github.com/schpet/linear-cli/releases/download/v${finalAttrs.version}/linear-${source.target}.tar.xz";
    inherit (source) hash;
  };
  sourceRoot = "linear-${source.target}";
  skillSource = fetchFromGitHub {
    owner = "schpet";
    repo = "linear-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jTQeOx78GuclgLiXccOy6smdrGTEfydm4HD+/luOlFM=";
  };

  nativeBuildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [ makeWrapper ];

  # The Deno executable carries its JavaScript payload at the end of the file.
  # patchelf corrupts that payload, and starting it through ld.so breaks the
  # /proc/self/exe lookup that finds it. So keep the binary untouched and point
  # it at libstdc++ with LD_LIBRARY_PATH.
  dontFixup = true;
  installPhase = ''
    runHook preInstall
  ''
  + (
    if stdenvNoCC.hostPlatform.isLinux then
      ''
        install -Dm755 linear $out/libexec/linear
        makeWrapper $out/libexec/linear $out/bin/linear \
          --set LD_LIBRARY_PATH "${lib.makeLibraryPath [ stdenv.cc.cc.lib ]}"
      ''
    else
      ''
        install -Dm755 linear $out/bin/linear
      ''
  )
  + ''
    mkdir -p $out/share/linear-cli/skills/linear-cli
    cp -r $skillSource/skills/linear-cli/SKILL.md $skillSource/skills/linear-cli/references \
      $out/share/linear-cli/skills/linear-cli/
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    test -f $out/share/linear-cli/skills/linear-cli/SKILL.md
    test -d $out/share/linear-cli/skills/linear-cli/references
    runHook postInstallCheck
  '';

  meta = {
    description = "Linear issue tracker CLI";
    homepage = "https://github.com/schpet/linear-cli";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    mainProgram = "linear";
  };
})
