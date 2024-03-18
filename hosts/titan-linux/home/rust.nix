{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # rust / dev
    rustup
    cargo-whatfeatures
    cargo-feature
    cargo-release
    dprint
  ];

  # # To build rust packages that in turn pull in / build binaries
  # programs.nix-ld.enable = true;
  # programs.nix-ld.libraries = with pkgs; [
  #   # Add any missing dynamic libraries for unpackaged programs
  #   # here, NOT in environment.systemPackages
  # ];

  home.file.".cargo/config.toml".text = ''
    [target.x86_64-unknown-linux-gnu]
    linker = "clang"
    rustflags = ["-C", "link-arg=--ld-path=${pkgs.mold-wrapped}/bin/mold"]

    # [build]
    # rustc-wrapper = "sccache"

    [registries]
    krahn = { index = "sparse+https://crates.kra.hn/api/v1/crates/", token = "OAZuEQBTDexae5pVbWZYgfXwFCuNbMia" }
  '';

  # dprint mostly used for formatting toml files
  home.file.".local/share/dprint/dprint.json".text = ''
    {
      "incremental": true,
      "json": {
      },
      "markdown": {
      },
      "toml": {
      },
      "dockerfile": {
      },
      "includes": ["**/*.{json,md,toml,dockerfile}"],
      "excludes": [
        "**/*-lock.json"
      ],
      "plugins": [
        "https://plugins.dprint.dev/json-0.19.2.wasm",
        "https://plugins.dprint.dev/markdown-0.16.4.wasm",
        "https://plugins.dprint.dev/toml-0.6.1.wasm",
        "https://plugins.dprint.dev/dockerfile-0.3.0.wasm"
      ]
    }
  '';

}