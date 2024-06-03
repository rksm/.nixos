{ config, lib, ... }:

{
  options = {
    k3s.enable = lib.mkEnableOption "Enable k3s";
  };

  # needs tailscale!
  config = lib.mkIf config.k3s.enable {
    services.k3s = {
      enable = true;
      role = "agent";
      serverAddr = "https://linuxmini.tail2787e.ts.net:6443";
      tokenFile = ../../shared/secrets/k3s-token.key;
    };
  };
}
