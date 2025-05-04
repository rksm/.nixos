{ user, config, pkgs, lib, ... }:

{
  home.file.".kube".source = config.lib.file.mkOutOfStoreSymlink /Users/${user}/configs/.kube;

  programs.k9s = {
    enable = true;
    package = pkgs.unstable.k9s;
  };

  home.packages = with pkgs; [
    # devops
    # ansible
    kubectl
    kubernetes-helm

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc # it is a calculator for the IPv4/v6 addresses
  ];
}
