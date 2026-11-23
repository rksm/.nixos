# Pi's agent folder, for ./pi.nix and ./pi-herdr.nix.
{ config, pkgs }:
if pkgs.stdenv.hostPlatform.isDarwin then
  "${config.home.homeDirectory}/configs/ai/pi"
else
  "${config.home.homeDirectory}/.pi/agent"
