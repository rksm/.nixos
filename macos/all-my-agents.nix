# all-my-agents on a Mac: the dashboard as a launchd agent, its config, the
# program for its prompt box's suggestions, and `ama` on the PATH, which starts
# each agent's runner as a launchd job. Its package builds for Apple silicon
# only, so the hosts with it import this file.
{
  config,
  inputs,
  machine,
  pkgs,
  ...
}:
let
  fromConfigs = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/configs/${path}";
in
{
  imports = [ inputs.all-my-agents.homeManagerModules.default ];

  services.all-my-agents = {
    enable = true;
    session = machine;
  };

  # The session of `ama agent start` in a shell, so that the new agent shows in
  # this machine's dashboard. Without it, the session is "default".
  home.sessionVariables.AMA_SESSION = machine;

  home.file.".config/all-my-agents/config.yaml".source = fromConfigs "all-my-agents/config.macos.yaml";
  # The folder keeps the name of the Herdr dashboard, which the snippets came from.
  home.file.".config/all-my-agents/snippets".source = fromConfigs "herdr-dashboard/snippets";

  # The dashboard's completion.copilot-command: GitHub's Copilot language
  # server, for the suggestions in the prompt box. The service finds it on PATH.
  home.packages = [ pkgs.copilot-language-server ];
}
