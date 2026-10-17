{ appimageTools, fetchurl, makeDesktopItem }:

let
  pname = "epic-games-launcher";
  version = "preview";

  src = fetchurl {
    url = "https://launcher-public-service-prod06.ol.epicgames.com/launcher/api/installer/download/EpicGamesLauncher-x86_64.AppImage";
    hash = "sha256-XPhge7Co8pqYhySdSRw8Qeo9Do7QaoZpWqjjtgAO2uY=";
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
