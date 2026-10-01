# CLIProxyAPI built from the dev branch. `just update-ai` runs
# nix-update --version=branch=dev on this file, which rewrites
# version, rev, hash, and vendorHash. Point owner at a fork to use it.
{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "cliproxyapi";
  version = "8.0.8-unstable-2026-10-01";

  src = fetchFromGitHub {
    owner = "router-for-me";
    repo = "CLIProxyAPI";
    rev = "fd48ea6840f5572deb53aeb5657740937ac9daaa";
    hash = "sha256-FfkxVBzw3BCVUku4+U6ICC9fgmTOV7DAKUr54Ln90HM=";
  };

  vendorHash = "sha256-r3yWkdMcM40G9jV7MxW/qNv3E9WrHavFilW24quEf+8=";

  subPackages = [ "cmd/server" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
    "-X main.Commit=${finalAttrs.src.rev}"
    "-X main.BuildDate=1970-01-01T00:00:00Z"
  ];

  # Upstream releases ship the cmd/server binary under this name.
  postInstall = ''
    mv $out/bin/server $out/bin/cli-proxy-api
  '';

  meta = {
    description = "Unified proxy providing OpenAI/Gemini/Claude/Codex compatible APIs for AI coding CLI tools";
    homepage = "https://github.com/router-for-me/CLIProxyAPI";
    license = lib.licenses.mit;
    mainProgram = "cli-proxy-api";
  };
})
