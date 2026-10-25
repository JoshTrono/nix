{
  flake.modules.nixos.de =
    { pkgs, vars, ... }:
    {
      # services.displayManager.sddm.enable = true;
      # services.desktopManager.plasma6.enable = true;

      services.displayManager.autoLogin = {
        user = "${vars.username}";
        enable = true;
      };

      hardware.bluetooth.enable = true;

      boot.initrd.systemd.enable = true;
      systemd.services.plasmalogin.serviceConfig.KeyringMode = "inherit";
      # security.pam.services.plasmalogin-autologin.rules.auth = {
      #   systemd_loadkey = {
      #     order = 0;
      #     control = "optional";
      #     modulePath = "${pkgs.systemd}/lib/security/pam_systemd_loadkey.so";
      #   };
      #   plasmalogin = {
      #     order = 1;
      #     control = "include";
      #     modulePath = "plasmalogin";
      #   };
      # };

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # To disable installing GNOME's suite of applications
  # and only be left with GNOME shell.
  services.gnome.core-apps.enable = true;
  services.gnome.core-developer-tools.enable = false;
  services.gnome.games.enable = true;
  environment.gnome.excludePackages = with pkgs; [ gnome-tour gnome-user-docs ];

  environment.systemPackages = with pkgs.gnomeExtensions; [
    blur-my-shell
    just-perfection
    dash-to-dock
    tiling-assistant
    appindicator
  ];
    };
}
