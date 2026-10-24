{ config, lib, pkgs, inputs, ... }:
let
  stable = import inputs.nixpkgs {
    system = pkgs.stdenv.hostPlatform.system;
    config.permittedInsecurePackages = [ "immich-2.7.5" ];
  };
in
{
  services.immich = {
    enable = true;
    package = stable.immich;
    port = 2283;
    host = "0.0.0.0";
    openFirewall = true;
    mediaLocation = "/mnt/mainlibrary/immich";
  };
}
