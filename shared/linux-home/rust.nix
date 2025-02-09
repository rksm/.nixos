{ config, pkgs, lib, ... }:

let
  # fix for https://github.com/museun/cargo-whatfeatures/issues/84
  cargo-whatfeatures = pkgs.rustPlatform.buildRustPackage
    rec {
      pname = "cargo-whatfeatures";
      version = "0.9.13";
      src = pkgs.fetchFromGitHub {
        owner = "museun";
        repo = pname;
        rev = "v${version}";
        sha256 = "sha256-YJ08oBTn9OwovnTOuuc1OuVsQp+/TPO3vcY4ybJ26Ms=";
      };
      cargoHash = "sha256-Zi9FCNBxQ9S4S9k6hoMUOixTs6PJyxmgTB+ArrX8oBE=";
      nativeBuildInputs = [ pkgs.pkg-config ];
      buildInputs = [ pkgs.openssl ];
      meta = with lib; {
        description = "A simple cargo plugin to get a list of features for a specific crate";
        mainProgram = "cargo-whatfeatures";
        homepage = "https://github.com/museun/cargo-whatfeatures";
        license = with licenses; [ mit asl20 ];
        maintainers = with maintainers; [ ivan-babrou matthiasbeyer ];
      };
    };

in

{
  home.packages = with pkgs; [
    # rust / dev
    rustup
    cargo-whatfeatures
    (cargo-feature.overrideAttrs (oldAttrs: { doCheck = false; }))
    cargo-release
    cargo-generate
    dprint
    cargo-features-manager
  ];

  home.file.".cargo/config.toml".text =
    let registry_key = builtins.readFile ../secrets/crates.kra.hn.key; in ''
      [target.x86_64-unknown-linux-gnu]
      linker = "clang"
      rustflags = ["-C", "link-arg=--ld-path=${pkgs.mold-wrapped}/bin/mold"]

      [registries]
      krahn = { index = "sparse+https://crates.kra.hn/api/v1/crates/", token = "${registry_key}" }
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
