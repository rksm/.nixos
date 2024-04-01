let

  nixos = builtins.getFlake "/etc/nixos";

  :lf .
  config = darwinConfigurations.Roberts-MacBook-Pro.config;
  home = config.home-manager.users.robert;

in
rec {
  inherit nixos;
  inherit (nixos) inputs nixosConfigurations;
  mylib = nixos.lib;
  lib = mylib.extend (_: _: inputs.nixpkgs.lib);
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  config = nixosConfigurations.titan-linux.config;
  options = nixosConfigurations.titan-linux.options;
  # test = nixos.nixosModules.dev.test {inherit lib pkgs config options;};
}


pkgs = import (builtins.getFlake "nixpkgs") { system = builtins.currentSystem; };


builtins.map (m: m.name) x.nixosConfigurations.titan-linux.config.environment.systemPackages;

x.nixosConfigurations.titan-linux.config.fileSystems

x.nixosConfigurations.titan-linux.config.fileSystems

x = builtins.getFlake "/etc/nixos/";
x.nixosConfigurations.titan-linux.config.home-manager.users.robert.home
