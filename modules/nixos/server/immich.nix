# modules/nixos/server/immich.nix
{ inputs, ... }:
{
  flake.modules.nixos.immich =
    { pkgs, ... }:
    let
      stable = import inputs.nixpkgs {
        system = pkgs.stdenv.hostPlatform.system;
        config.permittedInsecurePackages = [ "immich-2.7.5" ];
      };
    in
    {
      # disabledModules = [ "services/web-apps/immich.nix" ];
      # imports = [ "${inputs.nixpkgs}/nixos/modules/services/web-apps/immich.nix" ];

      services.immich = {
        enable = true;
        package = stable.immich;
        port = 2283;
        host = "0.0.0.0";
        # The port is opened on the Netbird interface only (see firewall.nix).
        openFirewall = false;
        mediaLocation = "/mnt/mainlibrary/immich";
      };
    };
}
