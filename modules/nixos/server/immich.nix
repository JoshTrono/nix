# /.dotfiles/modules/bootloader.nix
# Limine bootloader config.
{
  flake.modules.nixos.immich =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {

services.immich.package = pkgs.unstable.immich;

      services.immich.enable = true;
      services.immich.port = 2283;
      services.immich.user = "joshua";
      services.immich.host = "0.0.0.0";
      services.immich.openFirewall = true;
      # services.immich.mediaLocation = "/home/joshua/mainlibrary/immich";
    };
}
