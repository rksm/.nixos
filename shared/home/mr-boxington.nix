{
  config,
  inputs,
  machine,
  pkgs,
  ...
}:
let
  mbx = inputs.mr-boxington.packages.${pkgs.stdenv.hostPlatform.system}.mbx;
  # Long-running agents keep this path across mbx upgrades.
  shim = ".local/libexec/mbx";
  shimDir = "${config.home.homeDirectory}/${shim}";
in
{
  home.packages = [ mbx ];
  home.file.${shim}.source = "${mbx}/libexec/mbx";
  home.sessionPath = [ shimDir ];

  # NixOS sets PATH in 50-systemd-path.conf. New agent units inherit it here.
  xdg.configFile."environment.d/60-mbx.conf".text = ''
    PATH=${shimDir}:$PATH
  '';

  # A new login pane may inherit an old Herdr server's Home Manager session guard.
  programs.bash.profileExtra = ''
    case ":$PATH:" in
      *":${shimDir}:"*) ;;
      *) export PATH="${shimDir}:$PATH" ;;
    esac
  '';
  programs.fish.loginShellInit = ''
    fish_add_path --path "${shimDir}"
  '';

  programs.direnv.stdlib = ''
    # nix-direnv defines use_flake before direnv sources this file.
    eval "_mbx_$(declare -f use_flake)"
    use_flake() {
      _mbx_use_flake "$@" || return $?
      if [[ $(type -P cargo) != "${shimDir}/cargo" ]]; then
        PATH_add "${shimDir}"
      fi
    }
  '';

  xdg.configFile."mbx/config.toml".text = ''
    [gc]
    max_total_size = "${if machine == "agent-1" then "100GiB" else "500GiB"}"
  '';
}
