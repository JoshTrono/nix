{ appimageTools, fetchurl, makeDesktopItem }:

let
  pname = "epic-games-launcher";
  version = "preview";

  src = fetchurl {
    url = "https://launcher-public-service-prod06.ol.epicgames.com/launcher/api/installer/download/EpicGamesLauncher-x86_64.AppImage";
    hash = "sha256-hBVn6T2RKMnSTLuLHk0m4Vw3XKDHPpaFUaLBrzILBr0=";
  };

  desktopItem = makeDesktopItem {
    name = pname;
    desktopName = "Epic Games Launcher";
    exec = pname;
    icon = pname;           # see the icon step below
    categories = [ "Game" ];
    terminal = false;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${desktopItem}/share/applications/*.desktop \
      -t $out/share/applications
  '';
}