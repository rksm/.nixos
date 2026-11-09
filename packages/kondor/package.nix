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
  version = "0.1.0-unstable-2026-11-08";

  src = fetchFromGitHub {
    owner = "gblach";
    repo = "kondor";
    rev = "790925fd5ce777cd3e2fc0eb009dd62f9ba82de1";
    hash = "sha256-IWwBq9wTOofaGkRorFdKXrBwIxGVOHRGyLG3NXUivio=";
  };

  cargoHash = "sha256-nQ1Otkb8JYv9S/agqo1BTehVEJdu1oj0TV4UJ6MmsYA=";

  meta = {
    description = "Clean build artifacts from software projects, including nested projects";
    homepage = "https://github.com/gblach/kondor";
    license = lib.licenses.gpl3Plus;
    mainProgram = "kondor";
  };
})
