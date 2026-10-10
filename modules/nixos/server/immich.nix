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

      nixpkgs.config.permittedInsecurePackages = [
        "immich-2.7.5"
      ];

      services.immich.enable = true;
      services.immich.port = 2283;

      services.immich.host = "0.0.0.0";
      services.immich.openFirewall = true;
      services.immich.mediaLocation = "/home/joshua/mainlibrary/immich";
    };
}
