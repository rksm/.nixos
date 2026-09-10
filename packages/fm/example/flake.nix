{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    fm.url = "path:..";
    fm.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    { nixpkgs, fm, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ fm.overlays.default ];
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [ pkgs.fastmail-cli ];
      };
    };
}
