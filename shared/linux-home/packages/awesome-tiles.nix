{ pkgs
, lib
, stdenv
, nixosTests
, unzip
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
      src
    ,
    }:

    stdenv.mkDerivation {
      pname = "gnome-shell-extension-${pname}";
      version = builtins.toString version;
      inherit src;
      nativeBuildInputs = with pkgs; [ buildPackages.glib unzip ];
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
  version = 14;
  src = ../../../packages/awesome-tiles;

in
buildGnomeExtension {
  inherit uuid name pname description link version src;
}
