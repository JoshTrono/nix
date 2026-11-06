{
  flake.modules.nixos.de =
    { pkgs, vars, ... }:
    {
      services.displayManager.sddm.enable = true;
      services.desktopManager.plasma6.enable = true;

      services.displayManager.autoLogin = {
        user = "${vars.username}";
        enable = true;
      };

      hardware.bluetooth.enable = true;
    };
}
