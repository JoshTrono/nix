{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, wrapGAppsHook3
, ppp
, openssl
, zlib
, glib
, glib-networking
, gsettings-desktop-schemas
, adwaita-icon-theme
, gtk3
, cairo
, pango
, gdk-pixbuf
, libsoup_3
, webkitgtk_4_1
}:

stdenv.mkDerivation rec {
  pname = "netextender";
  version = "10.3.6-39";

  src = fetchurl {
    url = "https://software.sonicwall.com/NetExtender/NetExtender-linux-amd64-${version}.tar.gz";
    hash = "sha256-wstYzDlALsXgihi1enP/EMoxMBes4G6nvwTZOIwbg1c=";
  };

  # The 10.3 tarball unpacks into a single "netextender/" directory.
  sourceRoot = "netextender";

  nativeBuildInputs = [ autoPatchelfHook makeWrapper wrapGAppsHook3 ];
  buildInputs = [
    stdenv.cc.cc.lib
    openssl
    zlib
    glib
    gtk3
    cairo
    pango
    gdk-pixbuf
    libsoup_3
    webkitgtk_4_1
    # GTK/WebKit runtime pieces: TLS for WebKit, GSettings schemas, icon theme.
    glib-networking
    gsettings-desktop-schemas
    adwaita-icon-theme
  ];

  dontBuild = true;

  # We build the GUI wrapper ourselves in preFixup so it gets both the GTK
  # environment (gappsWrapperArgs) and ppp on PATH.
  dontWrapGApps = true;

  # Mirrors what the vendor install.sh does, minus everything that writes
  # outside the store (that part lives in the NixOS module):
  #  - keep the webkit 4.1 GUI, installed under the name "NetExtender"
  #  - drop the webkit 4.0 variants and the auto-upgrader
  #  - keep the whole tree under $out/opt/netextender, because the daemon
  #    expects wg, wg-quick, wireguard-go etc. next to it
  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/netextender $out/bin $out/share/applications
    cp -r . $out/opt/netextender
    cd $out/opt/netextender
    mv NetExtender_webkit2_41 NetExtender
    rm -f NetExtender_webkit2_40 autoUpgrader_* upgrade.sh install.sh uninstall.sh
    patchShebangs .
    cd - > /dev/null

    makeWrapper $out/opt/netextender/nxcli $out/bin/nxcli \
      --prefix PATH : ${lib.makeBinPath [ ppp ]}
    ln -s nxcli $out/bin/netExtender

    # Point the menu entry at the wrapped GUI and a real icon path, instead
    # of the vendor's /usr/local/netextender locations.
    install -Dm644 com.sonicwall.NetExtender.desktop -t $out/share/applications
    sed -i \
      -e "s|^Exec=.*|Exec=$out/bin/NetExtender|" \
      -e "s|^Icon=.*|Icon=$out/opt/netextender/nx-icon.png|" \
      $out/share/applications/com.sonicwall.NetExtender.desktop

    runHook postInstall
  '';

  # If the window is blank or garbled (common with WebKitGTK on NVIDIA or
  # Wayland), add this line to the makeWrapper call below:
  #   --set WEBKIT_DISABLE_DMABUF_RENDERER 1 \
  preFixup = ''
    makeWrapper $out/opt/netextender/NetExtender $out/bin/NetExtender \
      "''${gappsWrapperArgs[@]}" \
      --prefix PATH : ${lib.makeBinPath [ ppp ]}
  '';

  meta = {
    description = "SonicWall NetExtender VPN client";
    homepage = "https://www.sonicwall.com";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
