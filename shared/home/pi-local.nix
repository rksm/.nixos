{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Keep this as a string. A Nix path would copy the mutable checkout into the store.
  piRoot = "${config.home.homeDirectory}/projects/ai/pi";
in
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "pi";

      runtimeInputs = with pkgs; [
        bash
        coreutils
        fd
        nodejs_22
        ripgrep
        which
      ];

      text = ''
        launcher=${lib.escapeShellArg "${piRoot}/pi-test.sh"}

        if [[ ! -x "$launcher" ]]; then
          printf 'Local Pi launcher is missing or not executable: %s\n' "$launcher" >&2
          exit 1
        fi

        exec "$launcher" "$@"
      '';
    })
  ];
}
