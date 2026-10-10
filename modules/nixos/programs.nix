{
  flake.modules.nixos.programs =
    { pkgs, ... }:
    {

    # --- Nixpkgs Configuration ---
    nixpkgs.config.permittedInsecurePackages = [
      "electron-41.10.7"
    ];



      environment.systemPackages = with pkgs; [
        vscodium
        flatpak
        nixfmt
        direnv
        vulnix
        grayjay
        brave
        discord
        opencode-desktop
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
