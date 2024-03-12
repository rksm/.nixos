{ config, pkgs, ... }:
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.robert = {
    isNormalUser = true;
    description = "robert";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      firefox
    ];
    # openssh.authorizedKeys.keys = [
    #   "ssh-ed25519 <some-public-key> ryan@ryan-pc"
    # ];
  };
  # password-less sudo
  security.sudo.wheelNeedsPassword = false;
  security.polkit.enable = true;

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "robert";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
}
