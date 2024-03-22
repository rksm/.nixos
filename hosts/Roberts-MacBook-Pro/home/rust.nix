{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # rust / dev
    cargo
    rustc
    rust-analyzer
    cargo-whatfeatures
    cargo-feature
    cargo-release
    dprint
  ];

  home.file.".cargo/config.toml".text = ''
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