{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-latest.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-ai.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-rksm.url = "github:rksm/nixpkgs-rksm";
    nixpkgs-rksm.inputs.nixpkgs.follows = "nixpkgs";

    tuxedo-nixos.url = "github:blitz/tuxedo-nixos";

    skillshare-nix.url = "github:hypervideo/skillshare-nix";
    ast-outline.url = "github:aeroxy/ast-outline";
    llm-agents.url = "github:numtide/llm-agents.nix";
    herdr-nix.url = "github:rksm/herdr";
    flux-reconciler.url = "github:rksm/flux-reconciler";
    worktrunk-nix.url = "github:max-sixty/worktrunk";
    ai-quotas = {
      url = "github:rksm/ai-quotas";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      ai-quotas,
      ast-outline,
      disko,
      flux-reconciler,
      herdr-nix,
      home-manager,
      llm-agents,
      nixpkgs,
      nixpkgs-ai,
      nixpkgs-latest,
      nixpkgs-rksm,
      skillshare-nix,
      tuxedo-nixos,
      worktrunk-nix,
      ...
    }:
    let
      system = "x86_64-linux";
      user = "robert";
      fleet = builtins.fromJSON (builtins.readFile ./agent-fleet/nix/fleet.json);
      cliproxyapi = nixpkgs.legacyPackages.${system}.callPackage ./packages/cliproxyapi/package.nix { };

      nixpkgsOverlay = _final: _prev: {
        latest = import nixpkgs-latest {
          inherit system;
          config.allowUnfree = true;
        };
        ai = import nixpkgs-ai {
          inherit system;
          config.allowUnfree = true;
        };
        rksm = import nixpkgs-rksm { inherit system nixpkgs; };
        tuxedo-control-center = tuxedo-nixos.packages.${system}.default;

        ast-outline = ast-outline.packages.${system}.default;
        llm-agents = llm-agents.packages.${system};
        flux-reconciler = flux-reconciler.packages.${system}.default;
        worktrunk = worktrunk-nix.packages.${system}.default;
        inherit cliproxyapi;
      };

      sharedModules = machine: homeModule: [
        home-manager.nixosModules.home-manager
        {
          home-manager.backupFileExtension = "hm-backup";
          home-manager.overwriteBackup = true;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit user machine;
            nixosConfig = self.nixosConfigurations.${machine}.config;
          };
          home-manager.users.${user} = import homeModule;
        }
        {
          nixpkgs.overlays = [
            nixpkgsOverlay
            ai-quotas.overlays.default
            skillshare-nix.overlays.default
            herdr-nix.overlays.default
          ];
        }
      ];

      mkSystem =
        {
          machine,
          homeModule,
          modules,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs user machine; };
          modules = modules ++ sharedModules machine homeModule;
        };

      desktopMachines = [
        "storm"
        "tuxedo"
      ];
      desktopConfigurations = builtins.listToAttrs (
        map (machine: {
          name = machine;
          value = mkSystem {
            inherit machine;
            homeModule = ./hosts/${machine}/home.nix;
            modules = [
              ./hosts/${machine}
              tuxedo-nixos.nixosModules.default
            ];
          };
        }) desktopMachines
      );

      fleetConfigurations = builtins.mapAttrs (
        machine: _:
        mkSystem {
          inherit machine;
          homeModule = ./agent-fleet/nix/home.nix;
          modules = [
            disko.nixosModules.disko
            ./agent-fleet/nix/disk-config.nix
            ./agent-fleet/nix/configuration.nix
            ./shared/linux/moshi.nix
            { networking.hostName = machine; }
          ];
        }
      ) fleet;
      agentFleetPackages = nixpkgs.legacyPackages.${system};

      cudaPackages = import nixpkgs-ai {
        inherit system;
        config = {
          allowUnfree = true;
          cudaSupport = true;
          nvidia.acceptLicense = true;
        };
      };
    in
    {
      nixosConfigurations = desktopConfigurations // fleetConfigurations;

      packages.${system} = {
        inherit cliproxyapi;
      };

      devShells.${system} = {
        agent-fleet = agentFleetPackages.mkShell {
          packages = with agentFleetPackages; [
            hcloud
            jq
            just
            nixfmt
            nixos-anywhere
            openssh
            opentofu
            rsync
            vale
          ];

          shellHook = ''
            repository_root="$(${agentFleetPackages.git}/bin/git rev-parse --show-toplevel)"
            umask 077
            for sensitive_file in \
              "$repository_root/shared/secrets/agent-fleet-ssh.key" \
              "$repository_root/agent-fleet/.env" \
              "$repository_root"/agent-fleet/terraform.tfstate*; do
              if [ -f "$sensitive_file" ]; then
                chmod 600 "$sensitive_file"
              fi
            done
          '';
        };

        cuda = cudaPackages.mkShell {
          packages = [
            (cudaPackages.python3.withPackages (pythonPackages: [
              pythonPackages.torch-bin
              pythonPackages.torchvision-bin
              pythonPackages.tensorflow-bin
            ]))
          ];
          shellHook = ''
            echo "CUDA dev shell ready. Run: python scripts/check-cuda.py"
          '';
        };
      };

      formatter.${system} = agentFleetPackages.nixfmt-tree;
    };
}
