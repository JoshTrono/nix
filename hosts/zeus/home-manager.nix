{
  inputs,
  lib,
  config,
  pkgs,
  vars,
  ...
}:
{
  imports = [
    modules.home-manager.base
    # ./dotnet.nix
  ];

  nixpkgs = {
    overlays = [
      inputs.self.overlays.additions
      inputs.self.overlays.modifications
      inputs.self.overlays.unstable-packages
    ];
    config = {
      allowUnfree = true;
    };
  };

  programs.mangohud = {
    enable = true;
    enableSessionWide = true;
    settings = {
      cpu_stats = true;
      cpu_power = true;
      gpu_stats = true;
      gpu_power = true;
    };
  };

  programs.git.settings.user = config.home.base.git.settings.user;
}

