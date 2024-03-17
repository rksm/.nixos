{
  description = "...";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-firefox-darwin = {
      url = "github:bandithedoge/nixpkgs-firefox-darwin";
      #inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, home-manager, nixpkgs, nixpkgs-firefox-darwin, ... }:
    let
      user = "robert";
      machine = "Roberts-MacBook-Pro";
    in
    {
      darwinConfigurations.${machine} = nix-darwin.lib.darwinSystem {

        specialArgs = { inherit inputs user nixpkgs-firefox-darwin; };
        modules = [
          ./hosts/${machine}

          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit user;
            };
            home-manager.users.${user} = import ./hosts/${machine}/home;
          }

        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations.${machine}.pkgs;
    };
}
