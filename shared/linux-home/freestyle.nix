{ ... }:

# Freestyle dictation app integrations.
#
# The desktop-context plugin is a single self-contained ESM bundle that
# Freestyle's plugin loader picks up as a loose file from its plugins dir.
# Source of truth: ~/projects/ai/freestyle/plugins/desktop-context, synced
# here with `just sync-desktop-context-plugin` in that repo.
# The matching GNOME extension lives in ./packages/freestyle-focus-bridge.nix.
{
  home.file.".config/Freestyle/plugins/desktop-context.mjs".source =
    ../../packages/freestyle-desktop-context/desktop-context.mjs;
}
