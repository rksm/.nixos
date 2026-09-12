{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  chromium,
}:

let
  platform =
    {
      x86_64-linux = "linux-x64";
      aarch64-darwin = "darwin-arm64";
    }
    .${stdenvNoCC.hostPlatform.system};
  browser =
    if stdenvNoCC.hostPlatform.isDarwin then
      "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    else
      "${chromium}/bin/chromium";
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "agent-browser";
  # `just update-agent-browser` pins the browser recommended by this extension.
  version = "0.38.1";
  passthru.piAgentBrowserNativeVersion = "0.7.1";

  src = fetchurl {
    url = "https://registry.npmjs.org/agent-browser/-/agent-browser-${finalAttrs.version}.tgz";
    hash = "sha256-iaffR2H/M15N1TZ+TPBM7Lm6TizBMKAiD3mNGIQU3Gw=";
  };

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [ autoPatchelfHook ];
  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    tar -xzf "$src" \
      package/bin/agent-browser-${platform} \
      package/skill-data \
      package/skills
    install -Dm755 package/bin/agent-browser-${platform} $out/bin/agent-browser
    cp -r package/skill-data package/skills $out/
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/agent-browser \
      --set AGENT_BROWSER_EXECUTABLE_PATH "${browser}"
  '';

  meta = {
    description = "Headless browser automation CLI for AI agents";
    homepage = "https://github.com/vercel-labs/agent-browser";
    license = lib.licenses.asl20;
    mainProgram = "agent-browser";
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
  };
})
