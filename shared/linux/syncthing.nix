{ config, pkgs, lib, user, machine, ... }:
{
  options =
    {
      syncthing.enable = lib.mkEnableOption "syncthing";

      syncthing.enable-org = lib.mkEnableOption "syncthing ~/org/";
      syncthing.enable-documents = lib.mkEnableOption "syncthing ~/Documents/";
      syncthing.enable-configs = lib.mkEnableOption "syncthing ~/configs/";
      syncthing.enable-emacs = lib.mkEnableOption "syncthing ~/.emacs.d/";
      syncthing.enable-projects-ai = lib.mkEnableOption "syncthing ~/projects/ai/";
      syncthing.enable-projects-biz = lib.mkEnableOption "syncthing ~/projects/biz/";
      syncthing.enable-projects-finances = lib.mkEnableOption "syncthing ~/projects/finances/";
      syncthing.enable-projects-home = lib.mkEnableOption "syncthing ~/projects/home/";
      syncthing.enable-projects-hyper = lib.mkEnableOption "syncthing ~/projects/hyper/";
      syncthing.enable-projects-infra = lib.mkEnableOption "syncthing ~/projects/infra/";
      syncthing.enable-projects-python = lib.mkEnableOption "syncthing ~/projects/python/";
      syncthing.enable-projects-rust = lib.mkEnableOption "syncthing ~/projects/rust/";
      syncthing.enable-projects-security = lib.mkEnableOption "syncthing ~/projects/security/";
      syncthing.enable-projects-shuttle = lib.mkEnableOption "syncthing ~/projects/shuttle/";
      syncthing.enable-projects-typescript = lib.mkEnableOption "syncthing ~/projects/typescript/";
      syncthing.enable-projects-website = lib.mkEnableOption "syncthing ~/projects/website/";
      syncthing.enable-khoone = lib.mkEnableOption "syncthing ~/projects/home/khoone/ (home-ai agent state from khoone-1)";
    };

  ## more projects...
  #
  # (storm)
  # clojure/
  # common-lisp/
  # coscreen/
  # cpp/
  # dart/
  # data/
  # distributions/
  # emacs/
  # finances/
  # gamedev/
  # go/
  # godot/
  # keyboard/
  # lively/
  # lively-new/
  # lua/
  # mobile/
  # nix/
  # socialmedia/
  # third-party/

  # (airy)
  # data/
  # lively-2025-11-04/
  # misc/
  # nix/
  # parastou/
  # scratch/
  # webpage/

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
          "agent-1" = {
            id = "OQTRMZU-SR5253H-TOX724P-7M3Y3HB-VN7SBMC-WUCZD7P-3DPYBMF-NNVGEAB";
            autoAcceptFolders = false;
          };
          "khoone-1" = {
            id = "H5U7PXD-I6IJ7G6-VPIRNSG-LVUX4OY-Q37WSWP-KUVR5OS-HZ7V3US-5YNVJQC";
            autoAcceptFolders = false;
          };
        };

        folders = { }
          // (lib.optionalAttrs config.syncthing.enable-org {
          "org" = {
            id = "org";
            path = "/home/${user}/org";
            devices = [ "storm" "mbp" "nas" "tuxedo" "airy" ];
          };
        })
          // (lib.optionalAttrs config.syncthing.enable-documents {
          "Documents" = {
            id = "Documents";
            path = "/home/${user}/Documents";
            devices = [ "storm" "mbp" "nas" "tuxedo" "airy" ];
          };
        })
          // (lib.optionalAttrs config.syncthing.enable-configs {
          "configs" = {
            id = "configs";
            path = "/home/${user}/configs";
            devices = [ "storm" "mbp" "nas" "tuxedo" "airy" "agent-1" "khoone-1" ];
          };
        })
          // (lib.optionalAttrs config.syncthing.enable-emacs {
          ".emacs.d" = {
            id = ".emacs.d";
            path = "/home/${user}/.emacs.d";
            devices = [ "storm" "mbp" "nas" "tuxedo" "airy" ];
          };
        })

        # --------------------

          // (lib.optionalAttrs config.syncthing.enable-projects-ai {
          "projects/ai" = {
            id = "projects/ai";
            path = "/home/${user}/projects/ai";
            devices = [ "storm" "nas" "tuxedo" "airy" "agent-1" ];
          };
        })

          // (lib.optionalAttrs config.syncthing.enable-projects-biz {
          "projects/biz" = {
            id = "projects/biz";
            path = "/home/${user}/projects/biz";
            devices = [ "storm" "mbp" "nas" "tuxedo" "airy" ];
          };
        })

          // (lib.optionalAttrs config.syncthing.enable-projects-finances {
          "projects/finances" = {
            id = "projects/finances";
            path = "/home/${user}/projects/finances";
            devices = [ "storm" "tuxedo" "airy" ];
          };
        })

          // (lib.optionalAttrs config.syncthing.enable-projects-home {
          "projects/home" = {
            id = "projects/home";
            path = "/home/${user}/projects/home";
            devices = [ "storm" "nas" "tuxedo" "airy" "agent-1" ];
          };
        })

          // (lib.optionalAttrs config.syncthing.enable-projects-hyper {
          "projects/hyper" = {
            id = "projects/hyper";
            path = "/home/${user}/projects/hyper";
            devices = [ "storm" "nas" "tuxedo" "airy" "agent-1" ];
          };
        })

          // (lib.optionalAttrs config.syncthing.enable-projects-infra {
          "projects/infra" = {
            id = "projects/infra";
            path = "/home/${user}/projects/infra";
            devices = [ "storm" "mbp" "nas" "tuxedo" "airy" ];
          };
        })

          // (lib.optionalAttrs config.syncthing.enable-projects-python {
          "projects/python" = {
            id = "projects/python";
            path = "/home/${user}/projects/python";
            devices = [ "storm" "mbp" "nas" "tuxedo" "airy" ];
          };
        })

          // (lib.optionalAttrs config.syncthing.enable-projects-rust {
          "projects/rust" = {
            id = "projects/rust";
            path = "/home/${user}/projects/rust";
            devices = [ "storm" "mbp" "nas" "tuxedo" "airy" ];
          };
        })

          // (lib.optionalAttrs config.syncthing.enable-projects-security {
          "security" = {
            id = "projects/security";
            path = "/home/${user}/projects/security";
            devices = [ "nas" ];
          };
        })

          // (lib.optionalAttrs config.syncthing.enable-projects-shuttle {
          "projects/shuttle" = {
            id = "projects/shuttle";
            path = "/home/${user}/projects/shuttle";
            devices = [ "storm" "nas" "tuxedo" ];
          };
        })

          // (lib.optionalAttrs config.syncthing.enable-projects-typescript {
          "projects/typescript" = {
            id = "projects/typescript";
            path = "/home/${user}/projects/typescript";
            devices = [ "storm" "mbp" "nas" "tuxedo" "airy" ];
          };
        })

          // (lib.optionalAttrs config.syncthing.enable-projects-website {
          "projects/website" = {
            id = "projects/website";
            path = "/home/${user}/projects/website";
            devices = [ "storm" "mbp" "nas" "tuxedo" "airy" ];
          };
        })

          // (lib.optionalAttrs config.syncthing.enable-khoone {
          "khoone" = {
            id = "khoone";
            path = "/home/${user}/projects/home/khoone";
            devices = [ "storm" "khoone-1" ];
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
