{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # darwin specific
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-firefox-darwin = {
      url = "github:bandithedoge/nixpkgs-firefox-darwin";
      #inputs.nixpkgs.follows = "nixpkgs";
    };
    attic.url = "github:zhaofengli/attic";
    attic.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, home-manager, nixpkgs, nixpkgs-stable, attic, ... }:
    let

      nixosConfigurations =
        let
          system = "x86_64-linux";
          machines = [ "titan-linux" "storm" ];
          user = "robert";
          overlays-nixpkgs = final: prev: {
            stable = import nixpkgs-stable {
              inherit system;
              config.allowUnfree = true;
            };

            attic = inputs.attic.packages.${system}.attic;
            attic-client = inputs.attic.packages.${system}.attic-client;
            attic-server = inputs.attic.packages.${system}.attic-server;
          };

        in
        builtins.listToAttrs
          (map
            (machine: {
              name = machine;
              value = nixpkgs.lib.nixosSystem {
                inherit system;
                specialArgs = { inherit inputs user machine; };
                modules = [
                  ./hosts/${machine}

                  home-manager.nixosModules.home-manager
                  {
                    home-manager.useGlobalPkgs = true;
                    home-manager.useUserPackages = true;
                    home-manager.extraSpecialArgs = {
                      inherit user machine;
                      nixosConfig = self.nixosConfigurations.${machine}.config;
                    };
                    home-manager.users.${user} = import ./hosts/${machine}/home.nix;
                  }

                  ({ ... }: { nixpkgs.overlays = [ overlays-nixpkgs ]; })
                ];
              };
            })
            machines);


      # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      # macos / darwin
      darwinConfigurations =
        let
          machine = "Roberts-MacBook-Pro";
          user = "robert";
        in
        {
          ${machine} = nix-darwin.lib.darwinSystem {
            specialArgs = { inherit inputs user; };
            modules = [
              ./hosts/${machine}

              home-manager.darwinModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = { inherit user; };
                home-manager.users.${user} = import ./hosts/${machine}/home;
              }
            ];
          };

        };
    in

    {
      inherit nixosConfigurations darwinConfigurations;
    };

}
