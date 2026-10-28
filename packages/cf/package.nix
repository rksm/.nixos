# `just update-cf` pins the latest npm release and regenerates package-lock.json.
# It also pins the last commit that changed the cf-cli agent skill.
{
  lib,
  stdenv,
  buildNpmPackage,
  fetchurl,
  fetchFromGitHub,
  autoPatchelfHook,
  jq,
}:

buildNpmPackage (finalAttrs: {
  pname = "cf";
  version = "1.0.0-beta.24";

  src = fetchurl {
    url = "https://registry.npmjs.org/cf/-/cf-${finalAttrs.version}.tgz";
    hash = "sha256-8x6Yk6FkIA76xWXMbLeesGEvUbny63GyJloJAILk4Lc=";
  };

  # Cloudflare publishes the agent skill for cf in a separate repository.
  skillSource = fetchFromGitHub {
    owner = "cloudflare";
    repo = "skills";
    rev = "d7de3907f8ed32b23a6a71beeb2a0c774dfef4e1";
    hash = "sha256-KKSX4ieBKZ6xFN/ydZegR+Nd/jvnhoV+TKhrm/dU30A=";
  };

  # The npm tarball ships no lockfile. Its devDependencies only built the
  # bundled dist/ and point at files outside the tarball. The npm-deps fetcher
  # also runs this hook, so call jq by its store path.
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
    ${lib.getExe jq} 'del(.devDependencies)' package.json > package.json.new
    mv package.json.new package.json
  '';
  npmDepsHash = "sha256-T2Rlh5y5dPC0AsJFLaQ48irf9532sIqSUGO8l7rqxmU=";

  dontNpmBuild = true;
  # workerd's install script runs its binary before autoPatchelf can fix it.
  npmRebuildFlags = [ "--ignore-scripts" ];

  # miniflare's workerd and sharp's libvips are prebuilt binaries.
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  postInstall = ''
    mkdir -p $out/share/cf/skills
    cp -r $skillSource/skills/cf-cli $out/share/cf/skills/
  '';

  meta = {
    description = "The Cloudflare CLI";
    homepage = "https://github.com/cloudflare/cf";
    license = with lib.licenses; [
      mit
      asl20
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    mainProgram = "cf";
  };
})
