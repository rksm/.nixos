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
      hash = "sha256-qgCxTugpTt/rG8AbxkGM9LflDXWwRqmrSXwQOEIHOD8=";
    };
    aarch64-darwin = {
      package = "cli-darwin-arm64";
      hash = "sha256-yLlFfIUJVqQNxaSJVQX78/Ii4xsq0+7JzmtDvQSEL8I=";
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
  version = "0.43.0";
  passthru.piAgentBrowserNativeVersion = "0.9.30";

  src = fetchurl {
    url = "https://registry.npmjs.org/agent-browser/-/agent-browser-${finalAttrs.version}.tgz";
    hash = "sha256-5F07lcES2ghY+KfINtVdvAt4WPrEffFQnXQK3/ZeCrs=";
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
