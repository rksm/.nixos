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
  config = nixosConfigurations.storm.config;
  options = nixosConfigurations.storm.options;
  # test = nixos.nixosModules.dev.test {inherit lib pkgs config options;};
}


pkgs = import (builtins.getFlake "nixpkgs") { system = builtins.currentSystem; };


builtins.map (m: m.name) x.nixosConfigurations.storm.config.environment.systemPackages;

x.nixosConfigurations.storm.config.fileSystems

x.nixosConfigurations.storm.config.fileSystems

x = builtins.getFlake "/etc/nixos/";
x.nixosConfigurations.storm.config.home-manager.users.robert.home
