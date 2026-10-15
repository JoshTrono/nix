{
  fetchurl,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook3,
  gtk3,
  gtk2,
  webkitgtk_4_1,
  glib-networking,
  gsettings-desktop-schemas,
  adwaita-icon-theme,
  stdenv,
  lib,
  makeWrapper,
  iproute2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "netextender";
  version = "10.3.6-39";

  src = fetchurl {
    url = "https://software.sonicwall.com/NetExtender/NetExtender-linux-amd64-${finalAttrs.version}.deb";
    hash = "sha256-Ls+YcAYU6EQnpZWrQO+zZG4+UFb2kb8HY6u1IHWXQJU=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    gtk2 # drop if the build doesn't need it
    webkitgtk_4_1
    glib-networking
    gsettings-desktop-schemas
    adwaita-icon-theme
  ];

  # only wrap the GUI binary with the GApps env; NEService is a daemon
  dontWrapGApps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/{netextender,applications}
    mkdir $out/bin

    mv usr/local/netextender/locales $out/share/netextender
    # copy any other assets the GUI needs (icon, etc.)
    cp usr/local/netextender/*.png $out/share/netextender/ 2>/dev/null || true
    mv usr/local/netextender/{NEService,nxcli,wg,wg-quick,wireguard-go} $out/bin
    mv usr/local/netextender/com.sonicwall.NetExtender.desktop $out/share/applications
    mv usr/local/netextender/NetExtender_webkit2_41 $out/bin/NetExtender

    sed -i "s,Icon=/usr/local/netextender/nx-icon.png,Icon=$out/share/netextender/nx-icon.png,g" $out/share/applications/com.sonicwall.NetExtender.desktop
    sed -i "s,Exec=/usr/local/netextender/NetExtender,Exec=$out/bin/NetExtender,g" $out/share/applications/com.sonicwall.NetExtender.desktop

    runHook postInstall
  '';

  postFixup = ''
    wrapGApp $out/bin/NetExtender
    wrapProgram $out/bin/NEService --prefix PATH : "${lib.makeBinPath [ iproute2 ]}"
  '';

  meta = {
    homepage = "https://www.sonicwall.com";
    description = "SonicWall NetExtender Enterprise VPN Client";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.unfree;
    mainProgram = "NetExtender";
  };
})