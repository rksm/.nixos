{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-latest.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-ai.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    attic.url = "github:zhaofengli/attic";

    nixpkgs-rksm.url = "github:rksm/nixpkgs-rksm";
    nixpkgs-rksm.inputs.nixpkgs.follows = "nixpkgs";

    tuxedo-nixos.url = "github:blitz/tuxedo-nixos";

    claude-code.url = "github:sadjow/claude-code-nix";
    codex-cli-nix.url = "github:sadjow/codex-cli-nix";
  };

  outputs =
    inputs@{ self
    , home-manager
    , nixpkgs
    , nixpkgs-latest
    , nixpkgs-ai
    , nixpkgs-rksm
    , attic
    , tuxedo-nixos
    , claude-code
    , codex-cli-nix
    , ...
    }:
    let

      nixosConfigurations =
        let
          system = "x86_64-linux";
          machines = [ "titan-linux" "storm" "tuxedo" ];
          user = "robert";
          overlays-nixpkgs = final: prev: {
            latest = import nixpkgs-latest { inherit system; config.allowUnfree = true; };
            ai = import nixpkgs-ai { inherit system; config.allowUnfree = true; };
            rksm = import nixpkgs-rksm { inherit system nixpkgs; };
            inherit (inputs.attic.packages.${system}) attic attic-client attic-server;
            tuxedo-control-center = tuxedo-nixos.packages.${system}.default;
            codex-cli = codex-cli-nix.packages.${system}.default;
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

                  ({ ... }: {
                    nixpkgs.overlays = [
                      overlays-nixpkgs
                      claude-code.overlays.default
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
