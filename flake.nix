{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
  };

  outputs = inputs@{ self, nix-darwin, home-manager, nixpkgs, ... }:
    let

      nixosConfigurations =
        let
          machines = [ "titan-linux" "storm" ];
          user = "robert";
        in
        builtins.listToAttrs
          (map
            (machine: {
              name = machine;
              value = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
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
