# kondor built from its main branch. `just update-ai` runs
# nix-update --version=branch on this file, which rewrites
# version, rev, hash, and cargoHash.
{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kondor";
  version = "0.1.0-unstable-2026-11-10";

  src = fetchFromGitHub {
    owner = "gblach";
    repo = "kondor";
    rev = "681cea0fc445cd7912581153e07fa83dbdbfec88";
    hash = "sha256-0K4q2BN8+afv5MrobHAWHVOCAKaO8qnHYv91jSmnJqg=";
  };

  cargoHash = "sha256-nQ1Otkb8JYv9S/agqo1BTehVEJdu1oj0TV4UJ6MmsYA=";

  meta = {
    description = "Clean build artifacts from software projects, including nested projects";
    homepage = "https://github.com/gblach/kondor";
    license = lib.licenses.gpl3Plus;
    mainProgram = "kondor";
  };
})
