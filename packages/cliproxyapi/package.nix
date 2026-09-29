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
  version = "8.0.4-unstable-2026-09-29";

  src = fetchFromGitHub {
    owner = "router-for-me";
    repo = "CLIProxyAPI";
    rev = "93b683cc53fabcade6046a4bf9164facf6cf0c7d";
    hash = "sha256-Qd4gNu85Z4x6Ut3wpitpPbvh3y8u/+h601nNXPgHWvI=";
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
