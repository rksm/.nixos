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
  version = "0.1.0-unstable-2026-11-01";

  src = fetchFromGitHub {
    owner = "gblach";
    repo = "kondor";
    rev = "adfc5a0de3b10f8faac78b11a6ef6e0105d46e2b";
    hash = "sha256-HzfJmQO82lZM4hNHsKLmxeulEOX8re4kbd5a6hliiI8=";
  };

  cargoHash = "sha256-nQ1Otkb8JYv9S/agqo1BTehVEJdu1oj0TV4UJ6MmsYA=";

  meta = {
    description = "Clean build artifacts from software projects, including nested projects";
    homepage = "https://github.com/gblach/kondor";
    license = lib.licenses.gpl3Plus;
    mainProgram = "kondor";
  };
})
