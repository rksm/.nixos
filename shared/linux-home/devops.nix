{ config, pkgs, lib, ... }:

{
  home.file.".kube".source = config.lib.file.mkOutOfStoreSymlink /home/robert/configs/.kube;

  programs.k9s = {
    enable = true;
    package = pkgs.latest.k9s;
  };

  home.packages = with pkgs; [
    # devops
    ansible
    kubectl
    kubernetes-helm

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    gping # A ping tool with a graph
    oha # A load testing tool, parallelized HTTP requests: oha -- -z 2s -w https://latest.dev.hyper.video/assets/hyper_video_web_bg-CMMjGOCS.wasm
    bandwhich # A bandwidth measurement tool
    dnsutils # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc # it is a calculator for the IPv4/v6 addresses
    lychee # link checker
    traceroute
    wireshark-qt

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
  ];
}
