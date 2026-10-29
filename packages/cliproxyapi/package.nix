# CLIProxyAPI built from the dev branch. `just update-ai` runs
# nix-update --version=branch=dev on this file, which rewrites
# version, rev, hash, and vendorHash. Point owner at a fork to use it.
{
  lib,
  buildGoModule,
  fetchFromGitHub,
  fetchurl,
  go,
}:

let
  # Upstream go.mod requires a newer Go patch release than nixpkgs ships.
  # lessismore: pinned Go toolchain must be bumped by hand. Revisit when
  # nixpkgs go reaches the version in upstream go.mod, then drop this override.
  go_1_26_10 = go.overrideAttrs (finalAttrs: _: {
    version = "1.26.10";
    src = fetchurl {
      url = "https://go.dev/dl/go${finalAttrs.version}.src.tar.gz";
      hash = "sha256-/WPog7ovK/ypPBZGsx6+9j4rHk0rMXyXidl2po2B828=";
    };
  });
in
(buildGoModule.override { go = go_1_26_10; }) (finalAttrs: {
  pname = "cliproxyapi";
  version = "8.0.47-unstable-2026-10-29";

  src = fetchFromGitHub {
    owner = "router-for-me";
    repo = "CLIProxyAPI";
    rev = "56efc81fa5246277cda95ca6f9d190719ed166e3";
    hash = "sha256-E/mXyVmCCrG5FvV1kkca1SzjqHuMrjLOsbJ4MbU0CME=";
  };

  vendorHash = "sha256-yMO0DdE0pjtFxWaQXV17enV8u0KA5fIUbE8Gui/RvWU=";

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
