{ pkgs, ... }:
{
  imports = [
    ../../shared/home/agent-files.nix
    ../../shared/linux-home/command-line.nix
    ../../shared/linux-home/cli-proxy-api.nix
    ../../shared/linux-home/pi.nix
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
    sessionVariables.EDITOR = "emacs";

    file.".emacs.d/init.el".source = ./emacs/init.el;
  };

  programs.gh.settings.aliases.co = "pr checkout";

  home.packages = with pkgs; [
    emacs-nox
    kubectl
  ];
}
