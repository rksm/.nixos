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
  version = "0.2.0-unstable-2026-11-11";

  src = fetchFromGitHub {
    owner = "gblach";
    repo = "kondor";
    rev = "f424ae7102f600875e8b25b85903f9dce766941f";
    hash = "sha256-NKA4uqhyn+trtcj2hPMmIieMaZzmgnwr5gHRD+x2EX8=";
  };

  cargoHash = "sha256-0aMb7yYj+is10qJaw5KtGtEaxJ7WfuOrhVRbAY89q0s=";

  meta = {
    description = "Clean build artifacts from software projects, including nested projects";
    homepage = "https://github.com/gblach/kondor";
    license = lib.licenses.gpl3Plus;
    mainProgram = "kondor";
  };
})
