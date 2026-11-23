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
    # This flake's stable nixpkgs still supports the Intel Mac. Its bun is too
    # old for the dashboard's bun.lock, so take bun from the latest nixpkgs.
    # lessismore: the Intel Mac gets stable bun and cannot build the dashboard.
    # Revisit when stable nixpkgs ships bun 1.4.
    package = pkgs.callPackage "${inputs.herdr-dashboard}/nix/package.nix" {
      bun = pkgs.latest.bun;
    };
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
