{ config, pkgs, lib, ... }:
{

  services.syncthing = {
    enable = true;
    user = "robert";
    dataDir = "/home/robert/syncthing-data";
    configDir = "/home/robert/.config/syncthing";
    guiAddress = "127.0.0.1:8384";
    overrideDevices = true; # overrides any devices added or deleted through the WebUI
    overrideFolders = true; # overrides any folders added or deleted through the WebUI
    settings = {
      gui = let password = builtins.readFile ../../shared/secrets/syncthing-password.key; in {
        user = "robert";
        password = "${password}";
      };

      devices = {
        "titan-linux" = {
          id = "RYQZGHF-73GMHMW-UC6U4U7-FR5AXRH-MOIM7VY-DWVVYCH-JENHYTW-4LBYKAN";
          autoAcceptFolders = false;
        };
        "mbp" = {
          id = "ESRECEY-LRO4O4F-W6T4MCD-JJEUB23-UEMKLC6-3CAPFXO-B75BGCG-V2SIQA6";
          autoAcceptFolders = false;
        };
      };

      folders = {
        "org" = {
          path = "/home/robert/org";
          devices = [ "titan-linux" "mbp" ];
        };
        "Documents" = {
          path = "/home/robert/Documents";
          devices = [ "titan-linux" "mbp" ];
        };
        "projects/rust" = {
          path = "/home/robert/projects/rust";
          devices = [ "titan-linux" "mbp" ];
        };
        "projects/biz" = {
          path = "/home/robert/projects/biz";
          devices = [ "titan-linux" "mbp" ];
        };
      };

      options = {
        urAccepted = 1;
      };

    };
  };

}
