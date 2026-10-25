# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  vars,
  ...
}:
let
  # "Latest version" download link on addons.mozilla.org for force-installed extensions
  moz = short: "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";

  nixIcon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";

  # Keyword search engine helper: nixSearch "@alias" "https://...{searchTerms}"
  nixSearch = alias: template: {
    urls = [ { inherit template; } ];
    icon = nixIcon;
    definedAliases = [ alias ];
  };

  # Extra uBlock Origin lists: imported AND enabled (see selectedFilterLists below)
  importedLists = [
    "https://filters.adtidy.org/extension/ublock/filters/3.txt"
    "https://github.com/DandelionSprout/adfilt/raw/master/LegitimateURLShortener.txt"
  ];
in
{
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # inputs.self.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ./dotnet.nix
    ./gnome.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      inputs.self.overlays.additions
      inputs.self.overlays.modifications
      inputs.self.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };
  programs.mangohud = {
    enable = true;
    enableSessionWide = true; # load into every Vulkan/OpenGL app, no wrapper needed
    settings = {
      cpu_stats = true;
      cpu_power = true;
      gpu_stats = true;
      gpu_power = true;
    };
  };

  # TODO: Set your username
  home = {
    username = "${vars.username}";
    homeDirectory = "/home/${vars.username}";
  };
  programs.git = {
    enable = true;
    settings.user = {
      name = "Joshua";
      email = "josh.trono@gmail.com";
    };
  };
  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  programs.firefox = {
    enable = true;

    # No languagePacks: en-US is built into Firefox, so there is no separate pack to install.

    policies = {
      # Updates: Nix owns these
      DisableAppUpdate = true;

      # Telemetry, studies, nagging
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisableFeedbackCommands = true;
      DisableFirefoxScreenshots = true;
      DisableProfileImport = true;
      DisableProfileRefresh = true;
      DisableSetDesktopBackground = true;
      DisableForgetButton = true;
      DisableFormHistory = true;
      NoDefaultBookmarks = true;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";

      # Bitwarden handles passwords, so turn the built-in manager off entirely
      # (this also makes OfferToSaveLogins / DisablePasswordReveal /
      # DisableMasterPasswordCreation redundant)
      PasswordManagerEnabled = false;

      # Keep your original choice; remove this if you'd rather use Firefox's PDF viewer
      DisableBuiltinPDFViewer = true;

      BlockAboutProfiles = true;
      BlockAboutSupport = true;

      EnableTrackingProtection = {
        Value = true;
        Cryptomining = true;
        Fingerprinting = true;
        EmailTracking = true;
      };

      FirefoxHome = {
        SponsoredTopSites = false;
        Highlights = false;
      };
      FirefoxSuggest = {
        WebSuggestions = false;
        SponsoredSuggestions = false;
        ImproveSuggest = false;
      };
      UserMessaging = {
        ExtensionRecommendations = false;
        FeatureRecommendations = false;
        UrlbarInterventions = false;
        MoreFromMozilla = false;
        SkipOnboarding = true;
      };

      # UI and behavior
      DisplayMenuBar = "never";
      DontCheckDefaultBrowser = true;
      HardwareAcceleration = true;
      # No dependency on a `vars` argument being passed into home-manager
      DefaultDownloadDirectory = "${config.home.homeDirectory}/Downloads";

      # Extensions: only what's listed here can be installed
      ExtensionSettings = {
        "*" = {
          installation_mode = "blocked";
          blocked_install_message = "Extensions are managed declaratively in Nix.";
        };

        "uBlock0@raymondhill.net" = {
          install_url = moz "ublock-origin";
          installation_mode = "force_installed";
          default_area = "navbar";
          private_browsing = true;
        };

        # Bitwarden
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = moz "bitwarden-password-manager";
          installation_mode = "force_installed";
          default_area = "navbar";
          private_browsing = true;
        };
      };

      # uBlock Origin configuration
      "3rdparty".Extensions."uBlock0@raymondhill.net".adminSettings = {
        userSettings = {
          uiTheme = "dark";
          uiAccentCustom = true;
          uiAccentCustom0 = "#8300ff";
          cloudStorageEnabled = false;
          externalLists = lib.concatStringsSep "\n" importedLists;
        };

        selectedFilterLists = [
          # "CZE-0" removed: that's the Czech/Slovak regional list. Add it back if you want it.
          "adguard-generic"
          "adguard-annoyance"
          "adguard-social"
          "adguard-spyware-url"
          "easylist"
          "easyprivacy"
          "plowe-0"
          "ublock-abuse"
          "ublock-badware"
          "ublock-filters"
          "ublock-privacy"
          "ublock-quick-fixes"
          "ublock-unbreak"
          "urlhaus-1"
        ]
        ++ importedLists; # imported lists only take effect once they're also selected
      };
    };

    profiles.default = {
      isDefault = true;

      settings = {
        "browser.aboutConfig.showWarning" = false;
        "browser.search.suggest.enabled" = false;
        "privacy.globalprivacycontrol.enabled" = true;
        # Hardware video decoding (pairs with HardwareAcceleration above)
        "media.ffmpeg.vaapi.enabled" = true;
      };

      search = {
        force = true; # Firefox rewrites this file on exit; without force, the next switch fails
        default = "ddg";
        privateDefault = "ddg";

        engines = {
          "Nix Packages" =
            nixSearch "@np" "https://search.nixos.org/packages?channel=unstable&query={searchTerms}";
          "Nix Options" =
            nixSearch "@no" "https://search.nixos.org/options?channel=unstable&query={searchTerms}";
          "NixOS Wiki" = nixSearch "@nw" "https://wiki.nixos.org/w/index.php?search={searchTerms}";
          "Home Manager Options" =
            nixSearch "@hm" "https://home-manager-options.extranix.com/?query={searchTerms}";
        };
      };
    };
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "26.05";
}
