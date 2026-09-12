{
  config,
  pkgs,
  ...
}:
let
  moshiHook = pkgs.callPackage ../custom/moshi-hook { };
  service = pkgs.writeShellApplication {
    name = "moshi-service";
    runtimeInputs = with pkgs; [
      moshiHook
      herdr
      git
      lsof
      sqlite
      coreutils
      jq
      bash
    ];
    text = ''
      mkdir -p "$HOME/.grok"
      moshi-hook install
      ${builtins.readFile ../scripts/herdr-install}
      exec moshi-hook serve
    '';
  };
in
{
  home.packages = [ moshiHook ];
  launchd.agents.moshi-hook = {
    enable = true;
    config = {
      ProgramArguments = [ "${service}/bin/moshi-service" ];
      RunAtLoad = true;
      KeepAlive = true;
      ThrottleInterval = 5;
      WorkingDirectory = config.home.homeDirectory;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/moshi-hook.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/moshi-hook.log";
    };
  };
}
