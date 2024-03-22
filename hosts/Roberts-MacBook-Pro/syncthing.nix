{ config, pkgs, lib, ... }:
{

  services.syncthing = {
    enable = true;
    user = "robert";
    dataDir = "/Users/robert/syncthing-data";
    configDir = "/Users/robert/.config/syncthing";
    guiAddress = "0.0.0.0:8384";
    overrideDevices = true; # overrides any devices added or deleted through the WebUI
    overrideFolders = true; # overrides any folders added or deleted through the WebUI
    settings = {
      devices = {
        # "titan-linux" = {
        #   id = "RYQZGHF-73GMHMW-UC6U4U7-FR5AXRH-MOIM7VY-DWVVYCH-JENHYTW-4LBYKAN";
        #   autoAcceptFolders = false;
        # };
      };

      folders = {
        "org" = {
          path = "/Users/robert/org";
          # devices = [ "titan-linux" ];
          devices = [ ];
        };
      };

      options = {
        urAccepted = 1;
      };

    };
  };

}
