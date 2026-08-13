{
  description = "NixOS configuration for the AI agent fleet";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    codex-cli-nix.url = "github:sadjow/codex-cli-nix";
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      disko,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";
      fleet = builtins.fromJSON (builtins.readFile ./fleet.json);
      mkHost =
        hostName:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            disko.nixosModules.disko
            home-manager.nixosModules.home-manager
            ./disk-config.nix
            ./configuration.nix
            {
              networking.hostName = hostName;

              home-manager = {
                backupFileExtension = "hm-backup";
                useGlobalPkgs = true;
                useUserPackages = true;
                users.robert = import ./home.nix;
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = builtins.mapAttrs (hostName: _: mkHost hostName) fleet;

      devShells.${system}.default = nixpkgs.legacyPackages.${system}.mkShell {
        packages = with nixpkgs.legacyPackages.${system}; [
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
          if [ -f "$PWD/ssh/id_ed25519" ]; then
            chmod 600 "$PWD/ssh/id_ed25519"
          fi
        '';
      };

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
