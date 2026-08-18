{ lib
, stdenv
, fetchurl
, p7zip
, buildFHSEnv
, makeDesktopItem
, writeShellScript
, alsa-lib
, at-spi2-atk
, at-spi2-core
, atk
, bash
, cairo
, coreutils
, cups
, dbus
, expat
, file
, fontconfig
, freetype
, gdk-pixbuf
, glib
, gnutls
, gst_all_1
, gtk3
, lcms2
, libGL
, libGLU
, libdrm
, libgbm
, libnotify
, libogg
, libsecret
, libvorbis
, libxml2
, libxslt
, libx11
, libxcomposite
, libxcursor
, libxdamage
, libxext
, libxfixes
, libxi
, libxinerama
, libxkbcommon
, libxrandr
, libxrender
, libxscrnsaver
, libxcb
, libxshmfence
, libxxf86vm
, libxtst
, mesa
, mpg123
, nspr
, nss
, openal
, pango
, pipewire
, procps
, pulseaudio
, systemd
, util-linux
, v4l-utils
, vulkan-loader
, wget
, curl
, which
, xdg-utils
, zenity
, zlib
, wine
, xkeyboard_config
, dejavu_fonts
}:

let
  pname = "flakepoint";
  version = "14.0.3";

  flashpointArchive = stdenv.mkDerivation {
    pname = "${pname}-archive";
    inherit version;

    src = fetchurl {
      url = "https://github.com/weshford/flakepoint/releases/download/v14.0.3/flashpoint-14.0.3_linux.7z";
      sha256 = "f393a98c5c35e229a744c102b0cb53270b1b4f1b3ebd40d604f98323444a4b1f";
    };

    nativeBuildInputs = [ p7zip ];

    unpackPhase = ''
      runHook preUnpack
      7z x "$src" -o$PWD/extracted
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/flashpoint
      if [ -d extracted/flashpoint ]; then
        cp -a extracted/flashpoint/. $out/share/flashpoint/
      else
        cp -a extracted/. $out/share/flashpoint/
      fi
      # Remove bundled Ubuntu libraries so Flashpoint uses Nix FHS libraries natively
      rm -rf $out/share/flashpoint/Libraries/lib/x86_64-linux-gnu
      runHook postInstall
    '';
  };

  desktopItem = makeDesktopItem {
    name = "flashpoint-archive";
    exec = "flakepoint";
    icon = "flashpoint";
    comment = "An archive for games and animations from the web";
    desktopName = "Flashpoint Archive";
    categories = [ "Game" "Archiving" ];
    startupWMClass = "flashpoint-launcher";
    singleMainWindow = true;
  };

  fhsRunner = writeShellScript "flakepoint-fhs-wrapper" ''
    set -euo pipefail

    if [ -f "Launcher/flashpoint-launcher" ] || [ -f "start-flashpoint.sh" ]; then
      FLASHPOINT_DIR="$PWD"
    elif [ -f "flashpoint/start-flashpoint.sh" ]; then
      FLASHPOINT_DIR="$PWD/flashpoint"
    else
      XDG_DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}"
      FLASHPOINT_DIR="$XDG_DATA_HOME/flakepoint"
    fi

    if [ ! -d "$FLASHPOINT_DIR" ] || [ ! -f "$FLASHPOINT_DIR/start-flashpoint.sh" ]; then
      echo "Initializing Flashpoint data directory in $FLASHPOINT_DIR..."
      mkdir -p "$FLASHPOINT_DIR"
      cp -rn "${flashpointArchive}/share/flashpoint/." "$FLASHPOINT_DIR/"
      chmod -R u+w "$FLASHPOINT_DIR"
    fi

    # Ensure missing files/dotfiles (e.g. .preferences.defaults.json) are copied into existing data directories
    if [ -d "${flashpointArchive}/share/flashpoint" ]; then
      cp -rn "${flashpointArchive}/share/flashpoint/." "$FLASHPOINT_DIR/" 2>/dev/null || true
    fi

    # If preferences.json exists but was initialized with empty gameDataSources or invalid server, update/fix preferences
    if [ -f "$FLASHPOINT_DIR/preferences.json" ]; then
      if grep -q '"gameDataSources": \[\]' "$FLASHPOINT_DIR/preferences.json" 2>/dev/null && [ -f "$FLASHPOINT_DIR/.preferences.defaults.json" ]; then
        echo "Updating preferences.json with default sources..."
        cp "$FLASHPOINT_DIR/.preferences.defaults.json" "$FLASHPOINT_DIR/preferences.json"
      fi
      sed -i 's/"server": "Apache Webserver"/"server": "PHP Infinity Router"/g' "$FLASHPOINT_DIR/preferences.json"
      sed -i 's/"curateServer": "Apache Webserver"/"curateServer": "Apache Ultimate Webserver"/g' "$FLASHPOINT_DIR/preferences.json"
    fi

    # Remove bundled old libraries if present so Flashpoint uses Nix FHS system libraries
    if [ -d "$FLASHPOINT_DIR/Libraries/lib/x86_64-linux-gnu" ]; then
      rm -rf "$FLASHPOINT_DIR/Libraries/lib/x86_64-linux-gnu"
    fi

    cd "$FLASHPOINT_DIR"
    export WINEPREFIX="$FLASHPOINT_DIR/FPSoftware/Wine"

    cd Launcher
    if [ $# -eq 0 ]; then
      exec ./flashpoint-launcher --no-sandbox --js-flags=--lite_mode --ozone-platform-hint=auto
    else
      exec ./flashpoint-launcher --no-sandbox "$@"
    fi
  '';

in
buildFHSEnv {
  name = "flakepoint";

  targetPkgs = pkgs: [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    bash
    cairo
    coreutils
    cups
    dbus
    expat
    file
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gnutls
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gtk3
    lcms2
    libGL
    libGLU
    libdrm
    libgbm
    libnotify
    libogg
    libsecret
    libvorbis
    libxml2
    libxslt
    libx11
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxinerama
    libxkbcommon
    libxrandr
    libxrender
    libxscrnsaver
    libxcb
    libxshmfence
    libxxf86vm
    libxtst
    mesa
    mpg123
    nspr
    nss
    openal
    pango
    pipewire
    procps
    pulseaudio
    systemd
    util-linux
    v4l-utils
    vulkan-loader
    wget
    curl
    which
    xdg-utils
    zenity
    zlib
    wine
    xkeyboard_config
    dejavu_fonts
  ];

  runScript = fhsRunner;

  extraInstallCommands = ''
    mkdir -p $out/share/applications $out/share/icons/hicolor/scalable/apps
    cp ${desktopItem}/share/applications/* $out/share/applications/
    if [ -f "${flashpointArchive}/share/flashpoint/Launcher/icon.svg" ]; then
      cp "${flashpointArchive}/share/flashpoint/Launcher/icon.svg" $out/share/icons/hicolor/scalable/apps/flashpoint.svg
    fi
  '';
}
