{ inputs, user, ... }:

# HEX local voice dictation, from my fork github:rksm/hex, checked out at
# ~/projects/ai/hex (see the `hex` input in flake.nix).
# HEX runs as the systemd user service hex.service, which only its Home
# Manager module installs. Its NixOS module only installs the package.
# Start it with `hex start`, or open Settings with `hex app`.
# On GNOME it finds the focused window through the FocusBridge extension
# that gnome.nix enables.
{
  home-manager.users.${user} = {
    imports = [ inputs.hex.homeManagerModules.hex ];
    programs.hex.enable = true;
  };

  # HEX reads every /dev/input/event* device for its global hotkey, and sends
  # paste keys through a /dev/uinput keyboard. freestyle.nix and
  # computer-use.nix grant the same groups; each module declares them so any
  # can be removed independently.
  hardware.uinput.enable = true;
  users.users.${user}.extraGroups = [
    "input"
    "uinput"
  ];
}
