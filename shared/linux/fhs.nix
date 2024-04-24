{ config, pkgs, lib, ... }:

{
  options = {
    fhs.enable = lib.mkEnableOption "Enable FHS environment";
  };

  config = lib.mkIf config.fhs.enable {
    environment.systemPackages = with pkgs; [
      # ......omit many packages

      # Create an FHS environment using the command `fhs`, enabling the execution of non-NixOS packages in NixOS!
      (
        let base = pkgs.appimageTools.defaultFhsEnvArgs; in
        pkgs.buildFHSUserEnv (base // {
          name = "fhs";
          targetPkgs = pkgs: (
            # pkgs.buildFHSUserEnv provides only a minimal FHS environment,
            # lacking many basic packages needed by most software.
            # Therefore, we need to add them manually.
            #
            # pkgs.appimageTools provides basic packages required by most software.
            (base.targetPkgs pkgs) ++ (with pkgs; [
              pkg-config
              ncurses
              # Feel free to add more packages here if needed.
            ])
          );
          profile = "export FHS=1";
          runScript = "fish";
          extraOutputsToInstall = [ "dev" ];
        })
      )
    ];
  };
}
