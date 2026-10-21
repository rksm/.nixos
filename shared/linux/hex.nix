{ inputs, user, ... }:

# HEX local voice dictation, from the upstream flake.
# HEX runs as the systemd user service hex.service, which only its Home
# Manager module installs. Its NixOS module only installs the package.
# Start it with `hex start`, or open Settings with `hex app`.
{
  home-manager.users.${user} = {
    imports = [ inputs.hex.homeManagerModules.hex ];
    programs.hex.enable = true;
  };

  # HEX reads every /dev/input/event* device for its global hotkey.
  # freestyle.nix grants the same group; both modules declare it so either can
  # be removed independently.
  users.users.${user}.extraGroups = [ "input" ];
}
