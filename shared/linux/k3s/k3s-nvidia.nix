{ config, lib, pkgs, ... }:

{
  # needs tailscale!
  config = lib.mkIf (config.k3s.enable && config.nvidia.enable) {
    # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # convincing k3s to use the nvidia-container-runtime was a painful day...
    # Trying the cdi:
    #
    #   https://github.com/OlfillasOdikno/generic-cdi-plugin?tab=readme-ov-file
    #   https://github.com/NixOS/nixpkgs/issues/288037
    #
    # didn't help. I kept running into:
    #
    #   failed to "StartContainer" for "torch-tester" with RunContainerError:
    #   "failed to create containerd task: failed to create shim task: OCI
    #   runtime create failed: runc create failed: unable to start container
    #   process: error during container init: error running hook #0: error
    #   running hook
    #
    # Essentially the k3s containerd engine was not able to find the nvidia-container-runtime.
    # The funny thing was that docker and podman were able to access the gpu
    # (since hey have enableNvidia options that internally handle the wiring) but trying with containerd directly
    #   sudo ctr run --rm --gpus 1 docker-registry.podwriter:5000/torch-tester:0.1.0 torch-tester
    # didn't work.
    #
    # So in the end, it is the configuration of containerd and keeping the
    # right binaries in the necessary paths. For containerd directly something
    # like
    #
    #   virtualisation.containerd = {
    #     enable = true;
    #     settings = {
    #       plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia = {
    #         privileged_without_host_devices = false;
    #         runtime_engine = "";
    #         runtime_root = "";
    #         runtime_type = "io.containerd.runc.v2";
    #       };
    #       plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia.options = {
    #         BinaryName = "/run/current-system/sw/bin/nvidia-container-runtime";
    #       };
    #     };
    #   };
    #
    # works. For k3s, /var/lib/rancher/k3s/agent/etc/containerd/config.toml.tmpl is needed right now.
    #
    # So follow the nvidia / k3s instructions in the wiki and make sure you have nvidia-container-toolkit installed!
    #
    # https://nixos.wiki/wiki/K3s#Nvidia_support
    # https://docs.k3s.io/advanced#nvidia-container-runtime-support
    #
    # Also needed:
    #
    # runtime-class-nvidia.yaml:
    # ---
    #  apiVersion: node.k8s.io/v1
    #  handler: nvidia
    #  kind: RuntimeClass
    #  metadata:
    #    labels:
    #      app.kubernetes.io/component: gpu-operator
    #    name: nvidia
    # ---
    #
    #  kubectl apply -f runtime-class-nvidia.yaml
    #  helm upgrade -i nvdp nvdp/nvidia-device-plugin \
    #    --namespace nvidia-device-plugin \
    #    --create-namespace \
    #    --version 0.15.0 \
    #    --set runtimeClassName=nvidia


    hardware.nvidia-container-toolkit.enable = true;

    # environment.etc."k3s/containerd/config.toml.tmpl".text = ''
    #     {{ template "base" . }}

    #     [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia]
    #       privileged_without_host_devices = false
    #       runtime_engine = ""
    #       runtime_root = ""
    #       runtime_type = "io.containerd.runc.v2"

    #     [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia.options]
    #       BinaryName = "/run/current-system/sw/bin/nvidia-container-runtime"
    #   '';

    # system.activationScripts.script.text = ''
    #     ln -sf /etc/k3s/containerd/config.toml.tmpl /var/lib/rancher/k3s/agent/etc/containerd/config.toml.tmpl
    #   '';


    environment.systemPackages = with pkgs; [
      nvidia-container-toolkit
      libnvidia-container
      # cudaPackages.fabricmanager
    ];

    systemd.services.k3s.path = with pkgs; [
      # cudaPackages.fabricmanager
      nvidia-container-toolkit
      libnvidia-container
    ];

    systemd.services.containerd.path = with pkgs; [
      containerd
      runc
      # cudaPackages.fabricmanager
      nvidia-container-toolkit
      libnvidia-container
    ];
  };
}
