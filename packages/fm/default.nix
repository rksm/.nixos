{
  lib,
  stdenvNoCC,
  fetchurl,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation rec {
  pname = "fastmail-cli";
  version = "0.3.0";

  src = fetchurl {
    url = "https://github.com/cboone/fm/releases/download/v${version}/fm_${version}_linux_amd64.tar.gz";
    hash = "sha256-xJIRXuBe5la3UWKbobFxDj8ZqNzfO8wmAKDzibWpMsI=";
  };
  skillSource = fetchFromGitHub {
    owner = "cboone";
    repo = "fm";
    tag = "v${version}";
    hash = "sha256-PusKfrO1dD9/OQ00UuK9XYl+P6Pz97tlP3E3SNutreY=";
  };

  sourceRoot = ".";
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    install -Dm755 fm $out/bin/fm
    mkdir -p $out/share/fm/skills
    cp -r $skillSource/skills/review-email $out/share/fm/skills/
    chmod -R u+w $out/share/fm/skills
    # These upstream references point one directory above their target.
    substituteInPlace $out/share/fm/skills/review-email/references/{runbook,triage-phases}.md \
      --replace-fail '../flag-semantics.md' './flag-semantics.md'
    runHook postInstall
  '';

  meta = {
    description = "Fastmail CLI using JMAP";
    homepage = "https://github.com/cboone/fm";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "fm";
  };
}
