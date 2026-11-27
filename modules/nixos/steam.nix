{
  flake.modules.nixos.steam =
    { pkgs, inputs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
    in

    {
      # --- Gameing: Steam ---
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        # Only needed when hosting a game server from this machine.
        dedicatedServer.openFirewall = false;
        extraCompatPackages = with pkgs; [
          unstable.proton-ge-bin
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
        epic-games-launcher
        (unstable.heroic.override {
          extraPkgs =
            pkgs': with pkgs'; [
              gamescope
              gamemode
            ];
        })
      ];
      hardware.graphics.enable32Bit = true;

    };
}
