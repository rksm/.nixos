{ user, ... }:

{
  hardware.uinput.enable = true;
  users.users.${user}.extraGroups = [ "uinput" ];
  services.gnome.at-spi2-core.enable = true;
}
