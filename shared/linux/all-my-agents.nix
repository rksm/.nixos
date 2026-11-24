# all-my-agents: the dashboard that runs coding agents itself, without Herdr. It
# runs as a user service, with its config, the programs for its prompt box's
# suggestions, its address on the tailnet, and the Chrome app that opens it.
# Its package also puts `ama` on the PATH, which starts and drives the agents.
{
  inputs,
  lib,
  pkgs,
  user,
  machine,
  ...
}:
let
  # The ID of the dashboard's Chrome app, from Chrome's Install button on that
  # machine. A machine without one gets no all-my-agents-app.
  chromeAppIds = {
    storm = "aknnjneghhffoemkollojblhcnplmkdb";
  };

  # The machines that serve local models for the dashboard's ghost text. They
  # need an NVIDIA GPU with about 9 GB free.
  llamaMachines = [ "storm" ];

  # The local models for the dashboard's ghost text, by the name that
  # completion.copilot-model in its config.yaml uses. Both are fill-in-the-middle
  # models, which the dashboard asks through llama-server's /infill. A replay
  # of Robert's prompts picked them: ~/projects/ai/completion-eval/report.org.
  copilotModels = {
    "qwen2.5-coder-7b" = pkgs.fetchurl {
      url = "https://huggingface.co/QuantFactory/Qwen2.5-Coder-7B-GGUF/resolve/16ba6b11abac189c8f28fa0ddfa5619c4243a0db/Qwen2.5-Coder-7B.Q5_K_M.gguf";
      sha256 = "ac6fc5e4c07c7cc72d00fc4dce5316df8f1d2bbc5dca83c05f43a670b43b94c1";
    };
    "mellum2-12b" = pkgs.fetchurl {
      url = "https://huggingface.co/mradermacher/Mellum2-12B-A2.5B-Base-GGUF/resolve/da61ee532d542e264a5e340d5669b96c30b2c3dd/Mellum2-12B-A2.5B-Base.Q4_K_M.gguf";
      sha256 = "f30c7d928a39f5278b01f9c4a7d74ee2a88a24f887bb196a3033abe625a8381b";
    };
  };
in
{
  # llama-server for the dashboard's local models, at http://127.0.0.1:8012 (the
  # dashboard's completion.copilot-llama-server). It runs as a router: it loads
  # a model on the first request that names it, and keeps one loaded at a time,
  # so switching models in the dashboard's config needs no restart here. A
  # model takes 6-8.5 GB of GPU memory from its first suggestion on.
  services.llama-cpp = lib.mkIf (lib.elem machine llamaMachines) {
    enable = true;
    # nixos-26.05 has llama.cpp build 8864, which does not know Mellum2.
    # Unstable has build 11429; cache.flox.dev has its CUDA build.
    package = pkgs.ai.llama-cpp.override { cudaSupport = true; };
    port = 8012;
    modelsPreset = lib.mapAttrs (_: file: { model = "${file}"; }) copilotModels;
    extraFlags = [
      "--models-max"
      "1"
      "--n-gpu-layers"
      "99"
      "--flash-attn"
      "on"
      # The dashboard's document is up to 12,000 characters, which reached
      # 5.8k tokens on dense text.
      "--ctx-size"
      "8192"
      "--parallel"
      "1"
      # /infill keeps at most 3/4 of the batch for the text before the cursor.
      "--batch-size"
      "8192"
      "--ubatch-size"
      "1024"
      "--no-webui"
    ];
  };

  # The session of `ama agent start` in a shell, so that the new agent shows
  # in this machine's dashboard. Without it, the session is "default".
  environment.sessionVariables.AMA_SESSION = machine;

  # Serves the dashboard to the tailnet at https://${machine}.taileff843.ts.net:8443.
  # The dashboard takes these requests only from robert's login; see
  # services.all-my-agents.tailnet below.
  systemd.services.tailscale-serve-all-my-agents = {
    description = "Expose all-my-agents to the tailnet";
    after = [
      "network-online.target"
      "tailscaled.service"
    ];
    requires = [ "tailscaled.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = "5s";
    };

    # A switch that restarts tailscaled starts this unit before the backend runs.
    script = ''
      ${pkgs.tailscale}/bin/tailscale wait --timeout=60s
      ${pkgs.tailscale}/bin/tailscale serve --bg --yes --https=8443 4781
    '';
    preStop = "${pkgs.tailscale}/bin/tailscale serve --https=8443 off";
  };

  home-manager.users.${user} =
    { config, ... }:
    let
      fromConfigs = path: config.lib.file.mkOutOfStoreSymlink /home/${user}/configs/${path};
    in
    {
      imports = [ inputs.all-my-agents.homeManagerModules.default ];

      services.all-my-agents = {
        enable = true;
        session = machine;
        # tailscale-serve-all-my-agents above forwards this name.
        tailnet = {
          host = "${machine}.taileff843.ts.net:8443";
          user = "robert@hyper.video";
        };
      };

      home.file.".config/all-my-agents/config.yaml".source =
        fromConfigs "all-my-agents/config.linux.yaml";
      # The folder keeps the name of the Herdr dashboard, which the snippets came from.
      home.file.".config/all-my-agents/snippets".source = fromConfigs "all-my-agents/snippets";

      home.packages = [
        # The dashboard's completion.copilot-command: GitHub's Copilot language
        # server, for the suggestions in the prompt box. The service finds it on
        # PATH. It uses the login that Emacs's copilot-login made.
        pkgs.copilot-language-server
      ]
      # Opens the dashboard's Chrome app. google-chrome-stable comes from PATH,
      # with the flags of ./packages.nix.
      ++ lib.optional (chromeAppIds ? ${machine}) (
        pkgs.writeShellScriptBin "all-my-agents-app" ''
          exec google-chrome-stable --profile-directory=Default --app-id=${chromeAppIds.${machine}} "$@"
        ''
      );
    };
}
