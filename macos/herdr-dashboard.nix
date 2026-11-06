{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [ inputs.herdr-dashboard.homeManagerModules.default ];

  services.herdr-dashboard = {
    enable = true;
    # This flake's stable nixpkgs still supports the Intel Mac.
    package = pkgs.callPackage "${inputs.herdr-dashboard}/nix/package.nix" { };
  };

  home.packages = [
    pkgs.herdr
    (pkgs.writeShellScriptBin "herdr-dashboard-app" ''
      exec "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
        --profile-directory=Default \
        --enable-features=DesktopPWAsTabStrip \
        --blink-settings=allowScriptsToCloseWindows=true \
        --app=http://127.0.0.1:4780 "$@"
    '')
  ]
  ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [ pkgs.codex ];
}
