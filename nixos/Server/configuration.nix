# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  vars,
  ...
}:
let
  inherit (inputs.self.modules) nixos;
in
{
  # You can import other NixOS modules here
  imports = [
    # Modules exported by your own flake (from modules/)
    nixos.base
    nixos.nh
    nixos.immich
    nixos.netbird
    nixos.forgejo
    nixos.nixCaches
    nixos.jellyfin
    nixos.serverFirewall
    nixos.users
    nixos.ssh
    # Or modules from other flakes (such as nixos-hardware):
    inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd
    # inputs.hardware.nixosModules.framework-16-7040-amd
    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Hardware/filesystem config is added per flake output (see flake.nix):
    #   Server     -> ./hardware-configuration.nix (existing single-disk install)
    #   ServerRaid -> ./hardware-raid.nix + ./disko.nix (RAID 1 install)
  ];

  boot.swraid.mdadmConf = ''
    MAILADDR root
  '';
  #Temp
  environment.systemPackages = with pkgs; [
    fastfetch
    gh
  ];
  programs.git = {
    enable = true;
    config.safe.directory = [ "/home/${vars.username}/.dotfiles" ];
  };

  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = false;
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

  users.users.${vars.username}.linger = true;
  services.netbird.useRoutingFeatures = "both";

  system.autoUpgrade = {
    enable = true;
    # Follows vars.deployRef (variables.nix). Use a protected branch you merge
    # into on purpose: whoever can push there gets root on this machine.
    flake = "github:joshtrono/nix/${vars.deployRef}#${vars.flakeAttr or vars.hostname}";
    flags = [ "--print-build-logs" ];
    dates = "02:00";
    randomizedDelaySec = "45min";
    # operation = "boot";  # optional: apply at next reboot instead of switching live
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "26.05";
}
