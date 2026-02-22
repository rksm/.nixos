{
  description = "Nix for macOS configuration";

  # the nixConfig here only affects the flake itself, not the system configuration!
  nixConfig = {
    substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
    ];
  };

  inputs = {
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";
    nixpkgs-latest.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-ai.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    attic.url = "github:zhaofengli/attic";
    attic.inputs.nixpkgs.follows = "nixpkgs-darwin";
  };

  outputs =
    inputs @ { self
    , nixpkgs-darwin
    , nixpkgs-latest
    , nixpkgs-ai
    , darwin
    , home-manager
    , attic
    , ...
    }:

    let
      user = "robert";
      machines = [
        {
          name = "Roberts-MacBook-Pro";
          system = "x86_64-darwin";
        }
        {
          name = "airy";
          system = "aarch64-darwin";
        }
      ];

      darwinConfigurations = builtins.listToAttrs
        (map
          (machine:
            let
              overlays-nixpkgs = final: prev: {
                inherit (inputs.attic.packages.${machine.system}) attic attic-client attic-server;
                latest = import nixpkgs-latest { inherit (machine) system; config.allowUnfree = true; };
                ai = import nixpkgs-ai { inherit (machine) system; config.allowUnfree = true; };
              };
            in
            {
              name = machine.name;
              value = darwin.lib.darwinSystem {
                system = machine.system;
                specialArgs = { inherit inputs user; };
                modules = [
                  ./hosts/${machine.name}

                  home-manager.darwinModules.home-manager
                  {
                    home-manager.useGlobalPkgs = true;
                    home-manager.useUserPackages = true;
                    home-manager.extraSpecialArgs = { inherit user; };
                    home-manager.users.${user} = import ./hosts/${machine.name}/home;
                  }

                  ({ ... }: { nixpkgs.overlays = [ overlays-nixpkgs ]; })
                ];
              };

            })
          machines);
    in

    {
      inherit darwinConfigurations;

      devShells.aarch64-darwin.default = {
        packages = [
          nixpkgs-darwin.pkgs.hello
        ];
      };
    };
}
