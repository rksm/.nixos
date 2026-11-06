{ pkgs }:
# Install the PWA once in Chrome's Default profile (see README.org).
# Its app ID comes from the manifest ID http://127.0.0.1:4780/.
pkgs.writeShellScriptBin "herdr-dashboard-app" ''
  exec "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    --profile-directory=Default \
    --enable-features=DesktopPWAsTabStrip \
    --blink-settings=allowScriptsToCloseWindows=true \
    --app-id=mnhplgoahgfpnbacbmnhgmgbbaglefmm "$@"
''
