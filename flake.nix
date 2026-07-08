{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-latest.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-ai.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-rksm.url = "github:rksm/nixpkgs-rksm";
    nixpkgs-rksm.inputs.nixpkgs.follows = "nixpkgs";

    tuxedo-nixos.url = "github:blitz/tuxedo-nixos";

    rtk-nix.url = "github:hypervideo/rtk-nix";
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
    inputs@{ self
    , home-manager
    , nixpkgs
    , nixpkgs-latest
    , nixpkgs-ai
    , nixpkgs-rksm
    , tuxedo-nixos
    , codex-cli-nix
    , rtk-nix
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

      nixosConfigurations =
        let
          system = "x86_64-linux";
          machines = [ "titan-linux" "storm" "tuxedo" ];
          user = "robert";
          overlays-nixpkgs = final: prev: {
            latest = import nixpkgs-latest { inherit system; config.allowUnfree = true; };
            ai = import nixpkgs-ai { inherit system; config.allowUnfree = true; };
            rksm = import nixpkgs-rksm { inherit system nixpkgs; };
            tuxedo-control-center = tuxedo-nixos.packages.${system}.default;

            codex-cli = codex-cli-nix.packages.${system}.default;
            ast-outline = ast-outline.packages.${system}.default;
            magpie = magpie-nix.packages.${system}.default;
            google-antigravity = antigravity-nix.packages.${system}.google-antigravity;
            google-antigravity-cli = antigravity-nix.packages.${system}.google-antigravity-cli;
            flux-reconciler = flux-reconciler.packages.${system}.default;
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
                      rtk-nix.overlays.default
                      skillshare-nix.overlays.default
                      llm-agents.overlays.default
                      herdr-nix.overlays.default
                    ];
                  })
                ];
              };
            })
            machines);

      devShells =
        let
          system = "x86_64-linux";
          pkgs = import nixpkgs-ai {
            inherit system;
            config = {
              allowUnfree = true;
              cudaSupport = true;
              nvidia.acceptLicense = true;
            };
          };
        in
        {
          ${system}.cuda = pkgs.mkShell {
            packages = [
              (pkgs.python3.withPackages (ps: [
                ps.torch-bin
                ps.torchvision-bin
                ps.tensorflow-bin
              ]))
            ];
            shellHook = ''
              echo "CUDA dev shell ready. Run: python scripts/check-cuda.py"
            '';
          };
        };

    in
    {
      inherit nixosConfigurations devShells;
    };

}
