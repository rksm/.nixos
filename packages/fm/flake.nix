{
  description = "Fastmail CLI and email review skill";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
      };
    in
    {
      overlays.default = final: _prev: {
        fastmail-cli = final.callPackage ./default.nix { };
      };
      packages.${system}.default = pkgs.fastmail-cli;
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          fastmail-cli
          curl
          jq
          nixfmt
          shellcheck
          vale
        ];
      };
    };
}
