{ config, pkgs, lib, user, machine, ... }:
{
  options =
    {
      syncthing.enable = lib.mkEnableOption "syncthing";

      syncthing.enable-org = lib.mkEnableOption "syncthing ~/org/";
      syncthing.enable-documents = lib.mkEnableOption "syncthing ~/Documents/";
      syncthing.enable-configs = lib.mkEnableOption "syncthing ~/configs/";
      syncthing.enable-emacs = lib.mkEnableOption "syncthing ~/.emacs.d/";
      syncthing.enable-projects-biz = lib.mkEnableOption "syncthing ~/projects/biz/";
      syncthing.enable-projects-infra = lib.mkEnableOption "syncthing ~/projects/infra/";
      syncthing.enable-projects-python = lib.mkEnableOption "syncthing ~/projects/python/";
      syncthing.enable-projects-rust = lib.mkEnableOption "syncthing ~/projects/rust/";
      syncthing.enable-projects-typescript = lib.mkEnableOption "syncthing ~/projects/typescript/";
      syncthing.enable-projects-website = lib.mkEnableOption "syncthing ~/projects/website/";
      syncthing.enable-projects-shuttle = lib.mkEnableOption "syncthing ~/projects/shuttle/";
      syncthing.enable-media = lib.mkEnableOption "syncthing /media/robert/LINUX_DATA/media/";
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
          "tuxedo" = {
            id = "ZBIN2HO-EGA5WIN-UVJES3W-VMQJWSR-YKCZ5LS-ZZLZHHK-NTR75Z3-SDMGXA4";
            autoAcceptFolders = false;
          };
          "airy" = {
            id = "3RES5O5-HOBSBFM-WGADO2O-ODCAW7Y-PRP3FGS-POM2OTY-XUP5WZG-SVJUYAW";
            autoAcceptFolders = false;
          };
        };

        folders = { }
          // (lib.optionalAttrs config.syncthing.enable-org {
          "org" = {
            id = "org";
            path = "/home/${user}/org";
            devices = [ "titan-linux" "storm" "mbp" "nas" "tuxedo" "airy" ];
          };
        })
          // (lib.optionalAttrs config.syncthing.enable-documents {
          "Documents" = {
            id = "Documents";
            path = "/home/${user}/Documents";
            devices = [ "titan-linux" "storm" "mbp" "nas" "tuxedo" "airy" ];
          };
        })
          // (lib.optionalAttrs config.syncthing.enable-configs {
          "configs" = {
            id = "configs";
            path = "/home/${user}/configs";
            devices = [ "titan-linux" "storm" "mbp" "nas" "tuxedo" "airy" ];
          };
        })
          // (lib.optionalAttrs config.syncthing.enable-emacs {
          ".emacs.d" = {
            id = ".emacs.d";
            path = "/home/${user}/.emacs.d";
            devices = [ "titan-linux" "storm" "mbp" "nas" "tuxedo" "airy" ];
          };
        })

          # "projects/ai" = {
          #   path = "/home/${user}/projects/biz";
          #   devices = [ "titan-linux" "storm" "mbp" "nas" "tuxedo" "airy" ];
          # };

          // (lib.optionalAttrs config.syncthing.enable-projects-biz {
          "projects/biz" = {
            id = "projects/biz";
            path = "/home/${user}/projects/biz";
            devices = [ "titan-linux" "storm" "mbp" "nas" "tuxedo" "airy" ];
          };
        })
          # "projects/clojure" = {
          #   path = "/home/${user}/projects/clojure";
          #   devices = [ "titan-linux" "storm" "mbp" "nas" "tuxedo" "airy" ];
          # };
          # "projects/common-lisp" = {
          #   path = "/home/${user}/projects/common-lisp";
          #   devices = [ "titan-linux" "storm" "mbp" "nas" "tuxedo" "airy" ];
          # };
          # "projects/coscreen" = {
          #   path = "/home/${user}/projects/coscreen";
          #   devices = [ "titan-linux" "storm" "mbp" "nas" "tuxedo" "airy" ];
          # };
          # "projects/coscreen-win" = {
          #   path = "/home/${user}/projects/coscreen-win";
          #   devices = [ "titan-linux" "storm" "mbp" "nas" "tuxedo" "airy" ];
          # };
          # "projects/gamedev" = {
          #   path = "/home/${user}/projects/gamedev";
          #   devices = [ "titan-linux" "storm" "mbp" "nas" "tuxedo" "airy" ];
          # };
          // (lib.optionalAttrs config.syncthing.enable-projects-infra {
          "projects/infra" = {
            id = "projects/infra";
            path = "/home/${user}/projects/infra";
            devices = [ "titan-linux" "storm" "mbp" "nas" "tuxedo" "airy" ];
          };
        })
          // (lib.optionalAttrs config.syncthing.enable-projects-python {
          "projects/python" = {
            id = "projects/python";
            path = "/home/${user}/projects/python";
            devices = [ "titan-linux" "storm" "mbp" "nas" "tuxedo" "airy" ];
          };
        })
          // (lib.optionalAttrs config.syncthing.enable-projects-rust {
          "projects/rust" = {
            id = "projects/rust";
            path = "/home/${user}/projects/rust";
            devices = [ "titan-linux" "storm" "mbp" "nas" "tuxedo" "airy" ];
          };
        })
          // (lib.optionalAttrs config.syncthing.enable-projects-typescript {
          "projects/typescript" = {
            id = "projects/typescript";
            path = "/home/${user}/projects/typescript";
            devices = [ "titan-linux" "storm" "mbp" "nas" "tuxedo" "airy" ];
          };
        })
          // (lib.optionalAttrs config.syncthing.enable-projects-website {
          "projects/website" = {
            id = "projects/website";
            path = "/home/${user}/projects/website";
            devices = [ "titan-linux" "storm" "mbp" "nas" "tuxedo" "airy" ];
          };
        })
          // (lib.optionalAttrs config.syncthing.enable-projects-shuttle {
          "projects/shuttle" = {
            id = "projects/shuttle";
            path = "/home/${user}/projects/shuttle";
            devices = [ "storm" "nas" "tuxedo" ];
          };
        })
          // (lib.optionalAttrs config.syncthing.enable-media {
          "media" = {
            id = "media";
            path = "/media/robert/LINUX_DATA/media";
            devices = [ "titan-linux" "nas" ];
          };
        })
          // { };

        options = {
          urAccepted = 1;
        };
      };
    };
  };
}
