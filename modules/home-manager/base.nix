{ config, lib, pkgs, vars, ... }:

{
  config = {
    # Nixpkgs configuration
    nixpkgs.config.allowUnfree = true;

    # Home Manager identity
    home = {
      username = "${vars.username}";
      homeDirectory = "/home/${vars.username}";
    };

    # Common Git settings
    programs.git = {
      enable = true;
      settings.user = config.programs.git.settings.user or {
        name = "Joshua";
        email = "josh.trono@gmail.com";
      };
    };

    # Common Home Manager packages
    home.packages = config.home.packages ++ (with pkgs; [
      git
      curl
      wget
      htop
      tree
      tmux
      vim
      jq
      yq
    ]);

    # Home Manager state version
    home.stateVersion = "25.11";
  };

  options.home.base = {
    git.settings.user = lib.mkOption {
      type = lib.types.submodule {
        options = {
          name = lib.mkOption { type = lib.types.str; };
          email = lib.mkOption { type = lib.types.str; };
        };
      };
      default = {
        name = "Joshua";
        email = "josh.trono@gmail.com";
      };
      description = "Git user settings.";
    };
  };
}
