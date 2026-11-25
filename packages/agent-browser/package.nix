{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  chromium,
}:

let
  # Upstream ships the binary for each system in its own npm package.
  # `just update-agent-browser` updates these hashes.
  natives = {
    x86_64-linux = {
      package = "cli-linux-x64-gnu";
      hash = "sha256-vSfANv6ziEc5fRlXqbWJz47jxyZ29Bs9GZA6G3o8GJA=";
    };
    aarch64-darwin = {
      package = "cli-darwin-arm64";
      hash = "sha256-41V44ZPoOo/Yetbkg8ZlUco/34z1lmC/taxCCzW1Jpg=";
    };
  };
  native = natives.${stdenvNoCC.hostPlatform.system};
  browser =
    if stdenvNoCC.hostPlatform.isDarwin then
      "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    else
      "${chromium}/bin/chromium";
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "agent-browser";
  # `just update-agent-browser` pins the browser recommended by this extension.
  version = "0.44.0";
  passthru.piAgentBrowserNativeVersion = "0.9.42";

  src = fetchurl {
    url = "https://registry.npmjs.org/agent-browser/-/agent-browser-${finalAttrs.version}.tgz";
    hash = "sha256-XCZSLkh21VF6EqqHjzV92lNTlngrQlOAvCMUnlyFzAw=";
  };

  nativeSrc = fetchurl {
    url = "https://registry.npmjs.org/@agent-browser/${native.package}/-/${native.package}-${finalAttrs.version}.tgz";
    inherit (native) hash;
  };

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [ autoPatchelfHook ];
  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    tar -xzf "$src" package/skill-data package/skills
    tar -xzf "$nativeSrc" package/bin/agent-browser
    install -Dm755 package/bin/agent-browser $out/bin/agent-browser
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
    platforms = lib.attrNames natives;
  };
})
