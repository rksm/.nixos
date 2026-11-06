{ pkgs }:
let
  launcher = pkgs.writeShellScript "herdr-dashboard-app" ''
    exec "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
      --profile-directory=Default \
      --enable-features=DesktopPWAsTabStrip \
      --blink-settings=allowScriptsToCloseWindows=true \
      --app=http://127.0.0.1:4780 "$@"
  '';
in
pkgs.runCommand "herdr-dashboard-app" { } ''
  app="$out/Applications/Herdr Dashboard.app/Contents"
  mkdir -p "$out/bin" "$app/MacOS"
  cp ${launcher} "$out/bin/herdr-dashboard-app"
  cp ${launcher} "$app/MacOS/herdr-dashboard-app"
  cat > "$app/Info.plist" <<'EOF'
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0">
  <dict>
    <key>CFBundleIdentifier</key><string>video.hyper.herdr-dashboard</string>
    <key>CFBundleName</key><string>Herdr Dashboard</string>
    <key>CFBundleDisplayName</key><string>Herdr Dashboard</string>
    <key>CFBundleExecutable</key><string>herdr-dashboard-app</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>LSUIElement</key><true/>
  </dict>
  </plist>
  EOF
''
