{
  description = "Nix for macOS configuration";

  # the nixConfig here only affects the flake itself, not the system configuration!
  nixConfig = {
    substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
    ];
    # extra-substituters = [ "https://cache.numtide.com" ];
    # extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
  };

  inputs = {
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-latest.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    attic.url = "github:zhaofengli/attic";
    attic.inputs.nixpkgs.follows = "nixpkgs-darwin";

    codex-cli-nix.url = "github:sadjow/codex-cli-nix";
    skillshare-nix.url = "github:hypervideo/skillshare-nix";
    ast-outline.url = "github:aeroxy/ast-outline";
    magpie-nix.url = "github:hypervideo/magpie-nix";
    antigravity-nix.url = "github:jacopone/antigravity-nix";
    llm-agents.url = "github:numtide/llm-agents.nix";
    herdr-nix.url = "github:rksm/herdr";
    flux-reconciler.url = "github:rksm/flux-reconciler";
  };

  outputs =
    inputs @ { self
    , nixpkgs-darwin
    , nixpkgs-latest
    , darwin
    , home-manager
    , attic
    , codex-cli-nix
    , skillshare-nix
    , ast-outline
    , magpie-nix
    , antigravity-nix
    , llm-agents
    , herdr-nix
    , flux-reconciler
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
                codex-cli = codex-cli-nix.packages.${machine.system}.default;
                ast-outline = ast-outline.packages.${machine.system}.default;
                magpie = magpie-nix.packages.${machine.system}.default;
                google-antigravity = antigravity-nix.packages.${machine.system}.google-antigravity;
                google-antigravity-cli = antigravity-nix.packages.${machine.system}.google-antigravity-cli;
                llm-agents = llm-agents.packages.${machine.system};
                flux-reconciler = flux-reconciler.packages.${machine.system}.default;
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

                  ({ ... }: {
                    nixpkgs.overlays = [
                      overlays-nixpkgs
                      skillshare-nix.overlays.default
                      herdr-nix.overlays.default
                    ];
                  })
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
