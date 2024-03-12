let nixos = builtins.getFlake "/etc/nixos";
in rec {
  inherit nixos;
  inherit (nixos) inputs nixosConfigurations;
  mylib = nixos.lib;
  lib = mylib.extend  (_: _:  inputs.nixpkgs.lib );
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  config = nixosConfigurations.titan-linux.config;
  options = nixosConfigurations.titan-linux.options;
  # test = nixos.nixosModules.dev.test {inherit lib pkgs config options;};
}
