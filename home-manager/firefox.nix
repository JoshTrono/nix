{
  # programs.firefox = {
  #   enable = true;

  #   # No languagePacks: en-US is built into Firefox, so there is no separate pack to install.

  #   policies = {
  #     # Updates: Nix owns these
  #     DisableAppUpdate = true;

  #     # Telemetry, studies, nagging
  #     DisableTelemetry = true;
  #     DisableFirefoxStudies = true;
  #     DisableFeedbackCommands = true;
  #     DisableFirefoxScreenshots = true;
  #     DisableProfileImport = true;
  #     DisableProfileRefresh = true;
  #     DisableSetDesktopBackground = true;
  #     DisableForgetButton = true;
  #     DisableFormHistory = true;
  #     NoDefaultBookmarks = true;
  #     OverrideFirstRunPage = "";
  #     OverridePostUpdatePage = "";

  #     # Bitwarden handles passwords, so turn the built-in manager off entirely
  #     # (this also makes OfferToSaveLogins / DisablePasswordReveal /
  #     # DisableMasterPasswordCreation redundant)
  #     PasswordManagerEnabled = false;

  #     # Keep your original choice; remove this if you'd rather use Firefox's PDF viewer
  #     DisableBuiltinPDFViewer = true;

  #     BlockAboutProfiles = true;
  #     BlockAboutSupport = true;

  #     EnableTrackingProtection = {
  #       Value = true;
  #       Cryptomining = true;
  #       Fingerprinting = true;
  #       EmailTracking = true;
  #     };

  #     FirefoxHome = {
  #       SponsoredTopSites = false;
  #       Highlights = false;
  #     };
  #     FirefoxSuggest = {
  #       WebSuggestions = false;
  #       SponsoredSuggestions = false;
  #       ImproveSuggest = false;
  #     };
  #     UserMessaging = {
  #       ExtensionRecommendations = false;
  #       FeatureRecommendations = false;
  #       UrlbarInterventions = false;
  #       MoreFromMozilla = false;
  #       SkipOnboarding = true;
  #     };

  #     # UI and behavior
  #     DisplayMenuBar = "never";
  #     DontCheckDefaultBrowser = true;
  #     HardwareAcceleration = true;
  #     # No dependency on a `vars` argument being passed into home-manager
  #     DefaultDownloadDirectory = "${config.home.homeDirectory}/Downloads";

  #     # Extensions: only what's listed here can be installed
  #     ExtensionSettings = {
  #       "*" = {
  #         installation_mode = "blocked";
  #         blocked_install_message = "Extensions are managed declaratively in Nix.";
  #       };

  #       "uBlock0@raymondhill.net" = {
  #         install_url = moz "ublock-origin";
  #         installation_mode = "force_installed";
  #         default_area = "navbar";
  #         private_browsing = true;
  #       };

  #       # Bitwarden
  #       "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
  #         install_url = moz "bitwarden-password-manager";
  #         installation_mode = "force_installed";
  #         default_area = "navbar";
  #         private_browsing = true;
  #       };
  #     };

  #     # uBlock Origin configuration
  #     "3rdparty".Extensions."uBlock0@raymondhill.net".adminSettings = {
  #       userSettings = {
  #         uiTheme = "dark";
  #         uiAccentCustom = true;
  #         uiAccentCustom0 = "#8300ff";
  #         cloudStorageEnabled = false;
  #         externalLists = lib.concatStringsSep "\n" importedLists;
  #       };

  #       selectedFilterLists = [
  #         # "CZE-0" removed: that's the Czech/Slovak regional list. Add it back if you want it.
  #         "adguard-generic"
  #         "adguard-annoyance"
  #         "adguard-social"
  #         "adguard-spyware-url"
  #         "easylist"
  #         "easyprivacy"
  #         "plowe-0"
  #         "ublock-abuse"
  #         "ublock-badware"
  #         "ublock-filters"
  #         "ublock-privacy"
  #         "ublock-quick-fixes"
  #         "ublock-unbreak"
  #         "urlhaus-1"
  #       ]
  #       ++ importedLists; # imported lists only take effect once they're also selected
  #     };
  #   };

  #   profiles.default = {
  #     isDefault = true;

  #     settings = {
  #       "browser.aboutConfig.showWarning" = false;
  #       "browser.search.suggest.enabled" = false;
  #       "privacy.globalprivacycontrol.enabled" = true;
  #       # Hardware video decoding (pairs with HardwareAcceleration above)
  #       "media.ffmpeg.vaapi.enabled" = true;
  #     };

  #     search = {
  #       force = true; # Firefox rewrites this file on exit; without force, the next switch fails
  #       default = "ddg";
  #       privateDefault = "ddg";

  #       engines = {
  #         "Nix Packages" =
  #           nixSearch "@np" "https://search.nixos.org/packages?channel=unstable&query={searchTerms}";
  #         "Nix Options" =
  #           nixSearch "@no" "https://search.nixos.org/options?channel=unstable&query={searchTerms}";
  #         "NixOS Wiki" = nixSearch "@nw" "https://wiki.nixos.org/w/index.php?search={searchTerms}";
  #         "Home Manager Options" =
  #           nixSearch "@hm" "https://home-manager-options.extranix.com/?query={searchTerms}";
  #       };
  #     };
  #   };
  # };
}