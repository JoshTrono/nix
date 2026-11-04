# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  vars,
  ...
}:
let
  # "Latest version" download link on addons.mozilla.org for force-installed extensions
  moz = short: "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";

  nixIcon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";

  # Keyword search engine helper: nixSearch "@alias" "https://...{searchTerms}"
  nixSearch = alias: template: {
    urls = [ { inherit template; } ];
    icon = nixIcon;
    definedAliases = [ alias ];
  };

  # Extra uBlock Origin lists: imported AND enabled (see selectedFilterLists below)
  importedLists = [
    "https://filters.adtidy.org/extension/ublock/filters/3.txt"
    "https://github.com/DandelionSprout/adfilt/raw/master/LegitimateURLShortener.txt"
  ];
in
{
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # inputs.self.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ./dotnet.nix
    # ./gnome.nix
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
  programs.mangohud = {
    enable = true;
    enableSessionWide = true; # load into every Vulkan/OpenGL app, no wrapper needed
    settings = {
      cpu_stats = true;
      cpu_power = true;
      gpu_stats = true;
      gpu_power = true;
    };
  };

  home.packages = with pkgs; [
    jetbrains.pycharm
  ];

  # TODO: Set your username
  home = {
    username = "${vars.username}";
    homeDirectory = "/home/${vars.username}";
  };
  programs.git = {
    enable = true;
    settings.user = {
      name = "Joshua";
      email = "josh.trono@gmail.com";
    };
  };
  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  # Enable home-manager and git
  programs.home-manager.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "26.05";
}
