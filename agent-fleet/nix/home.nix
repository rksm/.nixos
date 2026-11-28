{
  lib,
  machine,
  pkgs,
  ...
}:
{
  imports = [
    ../../shared/home/agent-files.nix
    ../../shared/linux-home/command-line.nix
    ../../shared/home/cli-proxy-api.nix
    ../../shared/home/pi.nix
    # The reviews run as agents in Herdr panes.
    ../../shared/home/pi-herdr.nix
  ];

  services.agent-files = {
    enable = true;
    bucket = "agent-files";
    environmentFile = "/etc/nixos/shared/secrets/agent-files-r2.env";
    directory = "/home/robert/projects/ai/.agent-files";
  };

  home = {
    username = "robert";
    homeDirectory = "/home/robert";
    stateVersion = "26.05";
    sessionVariables = {
      EDITOR = "emacs";
    }
    // lib.optionalAttrs (machine == "agent-2") {
      CARGO_HOME = "/mnt/agent-2-data/cargo-cache";
    };

    file.".emacs.d/init.el".source = ./emacs/init.el;
  };

  programs = {
    gh.settings.aliases.co = "pr checkout";

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."agent-2 agent-2.taileff843.ts.net" = {
        User = "robert";
        IdentityFile = "/etc/nixos/shared/secrets/agent-fleet-ssh.key";
        IdentitiesOnly = true;
        StrictHostKeyChecking = "accept-new";
      };
    };
  };

  home.packages = with pkgs; [
    emacs-nox
    kondor
    kubectl
    latest.cargo-clean-all
  ];
}
