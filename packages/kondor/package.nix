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
  version = "0.1.0-unstable-2026-10-22";

  src = fetchFromGitHub {
    owner = "gblach";
    repo = "kondor";
    rev = "720b341061966ee64ecb0a1c343f2498b0850f09";
    hash = "sha256-U+eTTzY+tusaN1SYqdI8zkmMgFEFTfadKLKDT+j+xPo=";
  };

  cargoHash = "sha256-bsOrCErIbMFI4eBzXDcazVjAfTg1ge+9jelGeb9W2dc=";

  meta = {
    description = "Clean build artifacts from software projects, including nested projects";
    homepage = "https://github.com/gblach/kondor";
    license = lib.licenses.gpl3Plus;
    mainProgram = "kondor";
  };
})
