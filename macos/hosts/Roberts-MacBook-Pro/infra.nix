{ config, pkgs, ... }:
{
  # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # Tailscale
  environment.systemPackages = with pkgs; [
    tailscale
  ];

  services.tailscale = {
    enable = true;
  };
}
