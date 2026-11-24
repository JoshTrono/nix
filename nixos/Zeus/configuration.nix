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
    nixos.nh
    nixos.de
    nixos.bootloader
    nixos.steam
    nixos.programs
    nixos.multiverse
    nixos.nixCaches
    nixos.vm
    nixos.netbird
    nixos.netextender
    nixos.users
    nixos.ssh
    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd
    inputs.hardware.nixosModules.framework-16-amd-ai-300-series
    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      inputs.self.overlays.additions
      inputs.self.overlays.modifications
      inputs.self.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };
  nix = {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Opinionated: disable global registry
      flake-registry = "";
    };
    # Opinionated: disable channels
    channel.enable = false;
  };
  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages;
  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      networkmanager-openvpn
    ];
  };
  networking.networkmanager.wifi.powersave = false;
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024; # 32 GiB
    }
  ];

  # TODO: Set your hostname
  networking.hostName = "${vars.hostname}";

  nix.registry.dots.to = {
    type = "github";
    owner = "joshtrono";
    repo = "nix-templates";
  };

  time.timeZone = "America/New_York";

  services.netbird.ui.enable = true;

  # No SSH server on the laptop until a key is added in variables.nix.
  services.openssh.enable = vars.sshKeys != [ ];

  environment.shellAliases = {
    r = "rider . &";
  };

  # Printing
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      cups-filters
      cups-browsed
    ];
  };
  # No system.autoUpgrade here on purpose: it would run as root from
  # ~/.dotfiles, a directory this user can write to, so anything running as the
  # user could edit the config and get root at the next upgrade. Update by hand
  # with `nh os switch` (the flake path is set in modules/nixos/nh.nix).
  programs.bash.interactiveShellInit = ''
    [ -f "$HOME/.config/work-aliases.sh" ] && . "$HOME/.config/work-aliases.sh"
  '';

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "26.05";
}
