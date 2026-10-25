{ pkgs, ... }: {
  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface".color-scheme = "prefer-dark";

      # Minimize + maximize + close buttons (GNOME hides the first two by default)
      "org/gnome/desktop/wm/preferences".button-layout = "appmenu:minimize,maximize,close";

      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = with pkgs.gnomeExtensions; [
          blur-my-shell.extensionUuid
          just-perfection.extensionUuid
          dash-to-dock.extensionUuid
          tiling-assistant.extensionUuid
          appindicator.extensionUuid
        ];
      };
    };
  };
}