{
  description = "Slack workspace CLI and skill";
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
        slackcli = final.callPackage ./default.nix { };
      };
      packages.${system}.default = pkgs.slackcli;
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          slackcli
          curl
          jq
          nixfmt
          shellcheck
          vale
        ];
      };
    };
}
