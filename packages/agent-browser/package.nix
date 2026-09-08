{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  chromium,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "agent-browser";
  # `just update-agent-browser` pins the browser recommended by this extension.
  version = "0.36.0";
  passthru.piAgentBrowserNativeVersion = "0.6.9";

  src = fetchurl {
    url = "https://registry.npmjs.org/agent-browser/-/agent-browser-${finalAttrs.version}.tgz";
    hash = "sha256-hYp1N2ADTXPGvBfdiV+RFB7wPD/MqXg0izeOJtLWF+Q=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];
  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    tar -xzf "$src" \
      package/bin/agent-browser-linux-x64 \
      package/skill-data \
      package/skills
    install -Dm755 package/bin/agent-browser-linux-x64 $out/bin/agent-browser
    cp -r package/skill-data package/skills $out/
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/agent-browser \
      --set AGENT_BROWSER_EXECUTABLE_PATH ${chromium}/bin/chromium
  '';

  meta = {
    description = "Headless browser automation CLI for AI agents";
    homepage = "https://github.com/vercel-labs/agent-browser";
    license = lib.licenses.asl20;
    mainProgram = "agent-browser";
    platforms = [ "x86_64-linux" ];
  };
})
