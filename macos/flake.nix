{
  description = "Nix for macOS configuration";

  # the nixConfig here only affects the flake itself, not the system configuration!
  nixConfig = {
    substituters = [
      # Query the mirror of USTC first, and then the official cache.
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
  };

  inputs = {
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.11-darwin";
    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    attic.url = "github:zhaofengli/attic";
    attic.inputs.nixpkgs.follows = "nixpkgs-darwin";
  };

  outputs =
    inputs @ { self
    , nixpkgs-darwin
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
          (machine: {
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
