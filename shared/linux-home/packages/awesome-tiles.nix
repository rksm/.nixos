{ pkgs
, lib
, stdenv
, fetchgit
, nixosTests
,
}:

let

  buildGnomeExtension =
    {
      # Every gnome extension has a UUID. It's the name of the extension folder once unpacked
      # and can always be found in the metadata.json of every extension.
      uuid
    , name
    , pname
    , description
    , # extensions.gnome.org extension URL
      link
    , # Extension version numbers are integers
      version
    , # Hex-encoded string of JSON bytes
      metadata
    ,
    }:

    stdenv.mkDerivation {
      pname = "gnome-shell-extension-${pname}";
      version = builtins.toString version;
      src = fetchgit {
        url = "https://github.com/velitasali/gnome-shell-extension-awesome-tiles";
        rev = "231aaa99844a7101c54fb1444564e40e863fdc47";
        sha256 = "sha256-4PyxlK3qIQOKVjcoch+ifLSZLJ2BdcXhwSA26s2sevs=";

        # The download URL may change content over time. This is because the
        # metadata.json is automatically generated, and parts of it can be changed
        # without making a new release. We simply substitute the possibly changed fields
        # with their content from when we last updated, and thus get a deterministic output
        # hash.
        postFetch = ''
          echo "${metadata}" | base64 --decode > $out/metadata.json
        '';
      };
      nativeBuildInputs = with pkgs; [ buildPackages.glib ];
      buildPhase = ''
        runHook preBuild
        if [ -d schemas ]; then
          glib-compile-schemas --strict schemas
        fi
        runHook postBuild
      '';
      installPhase = ''
        runHook preInstall
        mkdir -p $out/share/gnome-shell/extensions/
        cp -r -T . $out/share/gnome-shell/extensions/${uuid}
        runHook postInstall
      '';
      meta = {
        description = builtins.head (lib.splitString "\n" description);
        longDescription = description;
        homepage = link;
        license = lib.licenses.gpl2Plus; # https://gjs.guide/extensions/review-guidelines/review-guidelines.html#licensing
        platforms = lib.platforms.linux;
        maintainers = [ lib.maintainers.honnip ];
      };
      passthru = {
        extensionPortalSlug = pname;
        # Store the extension's UUID, because we might need it at some places
        extensionUuid = uuid;

        tests = {
          gnome-extensions = nixosTests.gnome-extensions;
        };
      };
    };

  uuid = "awesome-tiles@velitasali.com";
  name = "Awesome Tiles";
  pname = "awesome-tiles";
  description = "Tile windows using keyboard shortcuts.";
  link = "https://extensions.gnome.org/extension/4702/awesome-tiles/";
  version = 15;
  metadata = "ewogICJfZ2VuZXJhdGVkIjogIkdlbmVyYXRlZCBieSBTd2VldFRvb3RoLCBkbyBub3QgZWRpdCIsCiAgImRlc2NyaXB0aW9uIjogIlRpbGUgd2luZG93cyB1c2luZyBrZXlib2FyZCBzaG9ydGN1dHMuIiwKICAiZ2V0dGV4dC1kb21haW4iOiAiYXdlc29tZS10aWxlc0B2ZWxpdGFzYWxpLmNvbSIsCiAgIm5hbWUiOiAiQXdlc29tZSBUaWxlcyIsCiAgInNldHRpbmdzLXNjaGVtYSI6ICJvcmcuZ25vbWUuc2hlbGwuZXh0ZW5zaW9ucy5hd2Vzb21lLXRpbGVzIiwKICAic2hlbGwtdmVyc2lvbiI6IFsKICAgICI0NSIsCiAgICAiNDYiLAogICAgIjQ3IiwKICAgICI0OCIKICBdLAogICJ1cmwiOiAiaHR0cHM6Ly9naXRodWIuY29tL3ZlbGl0YXNhbGkvZ25vbWUtYXdlc29tZS10aWxlcy1leHRlbnNpb24iLAogICJ1dWlkIjogImF3ZXNvbWUtdGlsZXNAdmVsaXRhc2FsaS5jb20iLAogICJ2ZXJzaW9uIjogMTUKfQo=";

in
buildGnomeExtension {
  inherit uuid name pname description link version metadata;
}
