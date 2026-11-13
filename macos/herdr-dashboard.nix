{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [ inputs.herdr-dashboard.homeManagerModules.default ];

  services.herdr-dashboard = {
    enable = true;
    # This flake's stable nixpkgs still supports the Intel Mac.
    package = pkgs.callPackage "${inputs.herdr-dashboard}/nix/package.nix" { };
  };

  home.file.".config/herdr-dashboard/config.yaml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/configs/herdr-dashboard/config.macos.yaml";
  home.file.".config/herdr-dashboard/snippets".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/configs/herdr-dashboard/snippets";

  home.packages = [
    pkgs.herdr
  ]
  ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [ pkgs.codex ];
}
