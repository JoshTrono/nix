{ config, lib, pkgs, inputs, ... }:
{
  nixpkgs.overlays = [
    (final: _prev: {
      multiverse = inputs.multiverse.lib.mkMultiverse {
        system = final.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    })
  ];
}
