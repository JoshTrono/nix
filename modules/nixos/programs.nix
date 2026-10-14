{
  flake.modules.nixos.programs =
    { pkgs, inputs ,... }:
    {
    imports = [inputs.nix-index-database.nixosModules.default];
    # --- Nixpkgs Configuration ---




      environment.systemPackages = with pkgs; [
        vscodium
        flatpak
        nixfmt
        direnv
        vulnix
        grayjay
        brave
        discord
        immich-go
        jellyfin-desktop
        # nix-index
        kdePackages.filelight
      ];
      programs.firefox.enable = true;
      programs.git.enable = true;



    services.flatpak.enable = true;
    services.packagekit.enable = false;
    # --- Brave Settings ---
    programs.chromium = {
      enable = true;
        extraOpts = {
          BraveWalletDisabled       = true;
          BraveNewsDisabled         = true;
          BraveTalkDisabled         = true;
          BraveAIChatEnabled        = false;
          BraveRewardsDisabled      = true;
          BraveVPNDisabled          = true;
          MetricsReportingEnabled   = false;
          BraveStatsPingEnabled     = false;
          BraveWebDiscoveryEnabled  = false;
        };
      };

          # --- AppImage support ---
    programs.appimage = {
      enable = true;
      binfmt = true;
    };




    };



}
