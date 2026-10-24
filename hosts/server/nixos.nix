{ config, lib, pkgs, vars, inputs, ... }:
let
  nixos = inputs.self.nixosModules;
in
{
  imports = [
    nixos.base
    nixos.server.immich
    nixos.netbird
    nixos.server.forgejo
    nixos.nix-caches
    nixos.server.jellyfin
    inputs.hardware.nixosModules.common-cpu-amd
    ./hardware.nix
  ];

  # Server-specific overrides/additions
  boot.swraid.mdadmConf = ''
    MAILADDR root
  '';

  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEefiVariables = false;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    mirroredBoots = [
      {
        devices = [ "nodev" ];
        path = "/boot";
      }
      {
        devices = [ "nodev" ];
        path = "/boot2";
      }
    ];
  };

  # Use standard kernel instead of latest for stability
  services.base.kernelPackages = pkgs.linuxPackages;

  programs.git = {
    enable = true;
    config.safe.directory = [ "/home/${vars.username}/.dotfiles" ];
  };

  services.netbird.useRoutingFeatures = "both";

  system.autoUpgrade = {
    enable = true;
    flake = "github:joshtrono/nix";
    flags = [ "--print-build-logs" ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };

  environment.systemPackages = with pkgs; [
    fastfetch
    gh
    jq
    yq
  ];

  users.users."${vars.username}" = {
    linger = true;
    # extraGroups is handled via services.base.extraGroups
  };

  services.openssh = {
    settings.PasswordAuthentication = false;
  };
}
