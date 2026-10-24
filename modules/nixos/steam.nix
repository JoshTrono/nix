{ config, lib, pkgs, ... }:
{
  # --- Gaming: Steam ---
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  # --- Gaming: Gamescope ---
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  # --- Gaming: Gamemode ---
  programs.gamemode = {
    enable = true;
    settings = {
      general.renice = 10;
      cpu.park_cores = "no";
    };
  };

  programs.command-not-found.enable = false;

  # --- XBox Gaming Controller Support ---
  hardware.xone.enable = true;
  hardware.xpadneo.enable = true;
  environment.systemPackages = with pkgs; [
    prismlauncher
    (heroic.override {
      extraPkgs =
        pkgs': with pkgs'; [
          gamescope
          gamemode
        ];
    })
  ];
  hardware.graphics.enable32Bit = true;
}
