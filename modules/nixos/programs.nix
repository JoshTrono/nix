{
  flake.modules.nixos.programs =
    {
      pkgs,
      inputs,
      lib,
      ...
    }:
    let
      epicPkgs =
        import
          (builtins.fetchTarball {
            url = "https://github.com/no-mood/nixpkgs/archive/27d65d5b8af9bbd5e40906d8757ff1d1fa87ac14.tar.gz";
            sha256 = "sha256:0wqrxf1nr3is6cv39gbr7lj5j1y0ikckvki4ma6c6kmdk3cqlpcg";
          })
          {
            system = pkgs.stdenv.hostPlatform.system;
            config.allowUnfree = true;
          };
    in
    {
      imports = [ inputs.nix-index-database.nixosModules.default ];
      # --- Nixpkgs Configuration ---

      environment.systemPackages = with pkgs; [
        vscodium
        flatpak
        nixfmt
        direnv
        brave
        discord
        jellyfin-desktop
        filezilla
        freerdp
        dig.dnsutils
        netextender
        openconnect
        fastfetch
        libreoffice



        epicPkgs.epic-games-launcher

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
          BraveWalletDisabled = true;
          BraveNewsDisabled = true;
          BraveTalkDisabled = true;
          BraveAIChatEnabled = false;
          BraveRewardsDisabled = true;
          BraveVPNDisabled = true;
          MetricsReportingEnabled = false;
          BraveStatsPingEnabled = false;
          BraveWebDiscoveryEnabled = false;
        };
      };

      # --- AppImage support ---
      programs.appimage = {
        enable = true;
        binfmt = true;
      };

    };

}
