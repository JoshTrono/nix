{
  flake.modules.nixos.programs =
    {
      pkgs,
      inputs,
      lib,
      vars,
      ...
    }:
    {
      imports = [ inputs.nix-index-database.nixosModules.default ];
      # --- Nixpkgs Configuration ---
      nixpkgs.config.permittedInsecurePackages = [
        "electron-39.8.10"
      ];

      environment.systemPackages = with pkgs; [
        vscodium
        flatpak
        nixfmt
        discord
        freerdp
        dig


        filezilla
        netextender
        fastfetch
        unstable.devenv
        google-chrome
        (brave.override {
          commandLineArgs = builtins.concatStringsSep " " [
            "--ozone-platform-hint=auto" # native Wayland, falls back to X11
            "--enable-features=AcceleratedVideoDecodeLinuxGL,AcceleratedVideoEncoder,WaylandWindowDecorations"
            # NVIDIA only (with nvidia-vaapi-driver), add VaapiOnNvidiaGPUs to the list above
          ];
        })

        libreoffice
        logseq
      ];
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      programs.git = {
        enable = true;
        config.safe.directory = [ "/home/${vars.username}/.dotfiles" ];
      };
      environment.etc."brave/policies/managed/nix.json".text = builtins.toJSON {
        # Brave-specific nagging/bloat
        BraveRewardsDisabled = true;
        BraveWalletDisabled = true;
        BraveVPNDisabled = true;
        BraveAIChatEnabled = false;
        BraveNewsDisabled = true;
        BraveTalkDisabled = true;
        TorDisabled = false;

        # Telemetry / misc
        MetricsReportingEnabled = false;
        SafeBrowsingExtendedReportingEnabled = false;
        UrlKeyedAnonymizedDataCollectionEnabled = false;
        FeedbackSurveysEnabled = false;
        PasswordManagerEnabled = false; # Bitwarden handles it
        AutofillCreditCardEnabled = false;
        BrowserSignin = 0;
        SyncDisabled = true;
        BuiltInDnsClientEnabled = false;
        DefaultBrowserSettingEnabled = false;
        PromotionsEnabled = false;
        HardwareAccelerationModeEnabled = true;
        DownloadDirectory = "/home/${vars.username}/Downloads";
        ShowHomeButton = false;

        # Search
        DefaultSearchProviderEnabled = true;
        DefaultSearchProviderName = "DuckDuckGo";
        DefaultSearchProviderKeyword = "ddg";
        DefaultSearchProviderSearchURL = "https://duckduckgo.com/?q={searchTerms}";
        SearchSuggestEnabled = false;

        # Extensions: block everything except the allowlist
        ExtensionInstallBlocklist = [ "*" ];
        ExtensionInstallAllowlist = [
          "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
          "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin (see note below)
        ];
        ExtensionInstallForcelist = [
          "nngceckbapebfimnlniiiahkandclblb;https://clients2.google.com/service/update2/crx"
          "cjpalhdlnbpafiamejdnhcphjbkeiagm;https://clients2.google.com/service/update2/crx"
        ];
      };

      services.flatpak.enable = true;
      services.packagekit.enable = false;

      programs.nix-ld.enable = true;

      # --- AppImage support ---
      programs.appimage = {
        enable = true;
        binfmt = true;
      };

    };

}
