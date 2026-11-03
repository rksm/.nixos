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
  version = "0.1.0-unstable-2026-11-02";

  src = fetchFromGitHub {
    owner = "gblach";
    repo = "kondor";
    rev = "e7355fd686614fff8359e8e62b30e103c417a838";
    hash = "sha256-Plx6Udl+r8rX1gXlUPSkwJ5ypj/aB+OmL/pNPs0gwDI=";
  };

  cargoHash = "sha256-nQ1Otkb8JYv9S/agqo1BTehVEJdu1oj0TV4UJ6MmsYA=";

  meta = {
    description = "Clean build artifacts from software projects, including nested projects";
    homepage = "https://github.com/gblach/kondor";
    license = lib.licenses.gpl3Plus;
    mainProgram = "kondor";
  };
})
