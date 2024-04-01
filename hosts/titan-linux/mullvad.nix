{ config, pkgs, lib, ... }:
{
  options =
    {
      mullvad.enable = lib.mkEnableOption "mullvad";
    };

  config = lib.mkIf config.mullvad.enable {
    # see also: https://mullvad.net/en/help/how-use-mullvad-cli
    # networking.resolvconf.enable = false; # see https://discourse.nixos.org/t/connected-to-mullvadvpn-but-no-internet-connection/35803/10?u=lion
    networking.resolvconf.enable = lib.mkForce false;
    services.resolved.enable = true;
    networking.wireguard.enable = true;
    services.mullvad-vpn.enable = true;
  };
}
