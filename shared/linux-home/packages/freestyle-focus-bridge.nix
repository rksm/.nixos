{ lib
, stdenvNoCC
}:

# GNOME Shell extension exposing the focused window over D-Bus
# (com.freestyle.FocusBridge) for the Freestyle dictation app.
#
# Source of truth: ~/projects/ai/freestyle/integrations/gnome-focus-bridge,
# synced here with `just sync-gnome-extension` in that repo.

let
  uuid = "freestyle-focus-bridge@freestyle-voice.dev";
in
stdenvNoCC.mkDerivation {
  pname = "gnome-shell-extension-freestyle-focus-bridge";
  version = "1";
  src = ../../../packages/freestyle-focus-bridge;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/gnome-shell/extensions/${uuid}
    cp extension.js metadata.json $out/share/gnome-shell/extensions/${uuid}/
    runHook postInstall
  '';

  meta = {
    description = "Expose the focused GNOME window to Freestyle over D-Bus";
    platforms = lib.platforms.linux;
  };

  passthru.extensionUuid = uuid;
}
