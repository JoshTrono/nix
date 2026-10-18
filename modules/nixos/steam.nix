{
  flake.modules.nixos.steam =
    { pkgs, inputs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      # nix-packages = inputs.nix-packages.packages.${system};
      #zen-browser = inputs.zen-browser.packages.${system}.default;
    in

    {
      # --- Gameing: Steam ---
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        extraCompatPackages = with pkgs; [
          proton-ge-bin
          #         proton-ge-bin nix-packages.proton-ge-w3rt
          #inputs.nix-proton-cachyos.packages.${pkgs.stdenv.hostPlatform.system}.proton-cachyos
          #run: nix flake update nix-proton-cachyos, first before uncommenting out the line above.
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

    };
}
