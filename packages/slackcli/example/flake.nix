{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    slackcli.url = "path:..";
    slackcli.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    { nixpkgs, slackcli, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ slackcli.overlays.default ];
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [ pkgs.slackcli ];
      };
    };
}
