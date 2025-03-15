{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

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

    nixpkgs-rksm.url = "github:rksm/nixpkgs-rksm";
    nixpkgs-rksm.inputs.nixpkgs.follows = "nixpkgs";

    tuxedo-nixos.url = "github:blitz/tuxedo-nixos";
  };

  outputs = inputs@{ self, nix-darwin, home-manager, nixpkgs, nixpkgs-stable, nixpkgs-unstable, nixpkgs-rksm, attic, tuxedo-nixos, ... }:
    let

      nixosConfigurations =
        let
          system = "x86_64-linux";
          machines = [ "titan-linux" "storm" "tuxedo" ];
          user = "robert";
          overlays-nixpkgs = final: prev: {
            stable = import nixpkgs-stable { inherit system; config.allowUnfree = true; };
            unstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
            rksm = import nixpkgs-rksm { inherit system nixpkgs; };
            inherit (inputs.attic.packages.${system}) attic attic-client attic-server;
            tuxedo-control-center = tuxedo-nixos.packages.x86_64-linux.default;
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

                  tuxedo-nixos.nixosModules.default

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
