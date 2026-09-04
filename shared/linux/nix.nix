{
  config,
  lib,
  user,
  ...
}:
{
  options = {
    more-nix-substituters = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    more-nix-trusted-public-keys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = {
    nixpkgs.config.allowUnfree = true;

    nix.settings = {
      trusted-users = [
        "root"
        user
      ];
      auto-optimise-store = true;
      experimental-features = [
        "flakes"
        "nix-command"
      ];
      netrc-file = "/etc/nixos/shared/secrets/hyper-video-cachix-netrc.key";
      substituters = [
        "https://nix-community.cachix.org"
      ]
      ++ config.more-nix-substituters
      ++ [ "https://hyper-video.cachix.org" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ]
      ++ config.more-nix-trusted-public-keys
      ++ [ "hyper-video.cachix.org-1:47YSCAg+fJBEH3oAhSzlcZAbjTMgnHTmQ6gI1la0Su4=" ];
    };
  };
}
