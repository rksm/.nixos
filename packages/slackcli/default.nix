{
  lib,
  stdenvNoCC,
  fetchurl,
  fetchFromGitHub,
  autoPatchelfHook,
}:

let
  source =
    {
      x86_64-linux = {
        platform = "linux";
        hash = "sha256-f1NuoRgT/lBhOm+Ai3jRiLaM3L54CJLFxTKwXeIvp9A=";
      };
      aarch64-darwin = {
        platform = "macos-arm64";
        hash = "sha256-CmYRqyQzEjd9jNXI0AiBwcyY9DwXB8ItzBU+fGDrAhs=";
      };
    }
    .${stdenvNoCC.hostPlatform.system};

in
stdenvNoCC.mkDerivation rec {
  pname = "slackcli";
  version = "0.12.0";

  src = fetchurl {
    url = "https://github.com/shaharia-lab/slackcli/releases/download/v${version}/slackcli-${source.platform}";
    inherit (source) hash;
  };
  skillSource = fetchFromGitHub {
    owner = "shaharia-lab";
    repo = "slackcli";
    tag = "v${version}";
    hash = "sha256-EXnYrmEdK/8PRK0JRizHc7Y8qtwlPrX0LgXBuWr6TDI=";
  };

  nativeBuildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [ autoPatchelfHook ];
  dontUnpack = true;
  dontBuild = true;
  # Preserve the JavaScript payload embedded in the Bun executable.
  dontStrip = true;
  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/slackcli
    mkdir -p $out/share/slackcli/skills
    cp -r $skillSource/plugins/slackcli/skills/slackcli $out/share/slackcli/skills/
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    test "$($out/bin/slackcli --version)" = "${version}"
    test -f $out/share/slackcli/skills/slackcli/SKILL.md
    test -f $out/share/slackcli/skills/slackcli/references/commands.md
    runHook postInstallCheck
  '';

  meta = {
    description = "CLI for reading, searching, and sending Slack messages";
    homepage = "https://github.com/shaharia-lab/slackcli";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    mainProgram = "slackcli";
  };
}
