{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-latest.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-ai.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    attic.url = "github:zhaofengli/attic";

    nixpkgs-rksm.url = "github:rksm/nixpkgs-rksm";
    nixpkgs-rksm.inputs.nixpkgs.follows = "nixpkgs";

    tuxedo-nixos.url = "github:blitz/tuxedo-nixos";


    gnome-voice-input = {
      url = "github:rksm/gnome-voice-input/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    podwriter.url = "path:/home/robert/projects/biz/podwriter-nix";
  };

  outputs =
    inputs@{ self
    , home-manager
    , nixpkgs
    , nixpkgs-stable
    , nixpkgs-latest
    , nixpkgs-ai
    , nixpkgs-rksm
    , attic
    , tuxedo-nixos
    , gnome-voice-input
    , podwriter
    , ...
    }:
    let

      nixosConfigurations =
        let
          system = "x86_64-linux";
          machines = [ "titan-linux" "storm" "tuxedo" ];
          user = "robert";
          overlays-nixpkgs = final: prev: {
            stable = import nixpkgs-stable { inherit system; config.allowUnfree = true; };
            latest = import nixpkgs-latest { inherit system; config.allowUnfree = true; };
            ai = import nixpkgs-ai { inherit system; config.allowUnfree = true; };
            rksm = import nixpkgs-rksm { inherit system nixpkgs; };
            inherit (inputs.attic.packages.${system}) attic attic-client attic-server;
            tuxedo-control-center = tuxedo-nixos.packages.${system}.default;
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

                  tuxedo-nixos.nixosModules.default

                  # Add podwriter-controller module
                  podwriter.nixosModules.podwriter-controller

                  ({ ... }: {
                    nixpkgs.overlays = [
                      overlays-nixpkgs
                      podwriter.overlays.default
                      gnome-voice-input.overlays.default
                    ];
                  })
                ];
              };
            })
            machines);

    in
    {
      inherit nixosConfigurations;
    };

}
