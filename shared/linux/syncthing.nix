{ config, pkgs, lib, user, machine, ... }:
{
  options =
    {
      syncthing.enable = lib.mkEnableOption "syncthing";
    };

  config = lib.mkIf config.syncthing.enable {
    services.syncthing = {
      enable = true;
      user = "robert";
      dataDir = "/home/${user}/syncthing-data";
      configDir = "/home/${user}/.config/syncthing";
      guiAddress = "127.0.0.1:8384";
      overrideDevices = true; # overrides any devices added or deleted through the WebUI
      overrideFolders = true; # overrides any folders added or deleted through the WebUI
      settings = {
        gui = let password = builtins.readFile ../secrets/syncthing-password.key; in {
          inherit user password;
        };

        devices = {
          "storm" = {
            id = "CLPXG4D-HFUVBBU-UVFTOKW-K6RTSPB-4SRS3V2-FAEOK5Y-W577FYA-LG4PTAQ";
            autoAcceptFolders = false;
          };
          "titan-linux" = {
            id = "RYQZGHF-73GMHMW-UC6U4U7-FR5AXRH-MOIM7VY-DWVVYCH-JENHYTW-4LBYKAN";
            autoAcceptFolders = false;
          };
          "mbp" = {
            id = "ESRECEY-LRO4O4F-W6T4MCD-JJEUB23-UEMKLC6-3CAPFXO-B75BGCG-V2SIQA6";
            autoAcceptFolders = false;
          };
          "nas" = {
            id = "5WBWSJB-OUNGDKD-HMT7CDM-TTMOZ7J-3F7CJMA-ED6RHAQ-P2LYPKR-ISZ5JQY";
            autoAcceptFolders = false;
          };
        };

        folders = {
          "org" = {
            path = "/home/${user}/org";
            devices = [ "titan-linux" "storm" "mbp" "nas" ];
          };
          "Documents" = {
            path = "/home/${user}/Documents";
            devices = [ "titan-linux" "storm" "mbp" "nas" ];
          };
          "configs" = {
            path = "/home/${user}/configs";
            devices = [ "titan-linux" "storm" "mbp" "nas" ];
          };
          ".emacs.d" = {
            path = "/home/${user}/.emacs.d";
            devices = [ "titan-linux" "storm" "mbp" "nas" ];
          };
          # "projects/ai" = {
          #   path = "/home/${user}/projects/biz";
          #   devices = [ "titan-linux" "storm" "mbp" "nas" ];
          # };
          "projects/biz" = {
            path = "/home/${user}/projects/biz";
            devices = [ "titan-linux" "storm" "mbp" "nas" ];
          };
          # "projects/clojure" = {
          #   path = "/home/${user}/projects/clojure";
          #   devices = [ "titan-linux" "storm" "mbp" "nas" ];
          # };
          # "projects/common-lisp" = {
          #   path = "/home/${user}/projects/common-lisp";
          #   devices = [ "titan-linux" "storm" "mbp" "nas" ];
          # };
          # "projects/coscreen" = {
          #   path = "/home/${user}/projects/coscreen";
          #   devices = [ "titan-linux" "storm" "mbp" "nas" ];
          # };
          # "projects/coscreen-win" = {
          #   path = "/home/${user}/projects/coscreen-win";
          #   devices = [ "titan-linux" "storm" "mbp" "nas" ];
          # };
          # "projects/gamedev" = {
          #   path = "/home/${user}/projects/gamedev";
          #   devices = [ "titan-linux" "storm" "mbp" "nas" ];
          # };
          "projects/infra" = {
            path = "/home/${user}/projects/infra";
            devices = [ "titan-linux" "storm" "mbp" "nas" ];
          };
          "projects/python" = {
            path = "/home/${user}/projects/python";
            devices = [ "titan-linux" "storm" "mbp" "nas" ];
          };
          "projects/rust" = {
            path = "/home/${user}/projects/rust";
            devices = [ "titan-linux" "storm" "mbp" "nas" ];
          };
          "projects/typescript" = {
            path = "/home/${user}/projects/typescript";
            devices = [ "titan-linux" "storm" "mbp" "nas" ];
          };
          "projects/website" = {
            path = "/home/${user}/projects/website";
            devices = [ "titan-linux" "storm" "mbp" "nas" ];
          };
        } // (if machine == "titan-linux" then {
          "media" = {
            path = "/media/robert/LINUX_DATA/media";
            devices = [ "titan-linux" "nas" ];
          };
        } else { });


        options = {
          urAccepted = 1;
        };

      };
    };
  };
}
