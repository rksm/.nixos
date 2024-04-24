{ config, pkgs, lib, ... }:
{
  options = {
    ssh-password-auth.enable = lib.mkEnableOption "ssh-password-auth";
  };

  config = {
    programs.gnupg.agent.enableSSHSupport = false;

    services.openssh = {
      enable = true;
      settings = {
        X11Forwarding = true;
        PermitRootLogin = "no";
        PasswordAuthentication = config.ssh-password-auth.enable;
      };
      # openFirewall = true;
    };
  };
}
