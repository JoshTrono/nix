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
        direnv
        discord
        jellyfin-desktop
        filezilla
        unstable.freerdp
        dig.dnsutils
        netextender
        openconnect
        fastfetch
        libreoffice
        logseq

        kdePackages.filelight
      ];
      programs.git = {
        enable = true;
        config.safe.directory = [ "/home/${vars.username}/.dotfiles" ];
      };

      services.flatpak.enable = true;
      services.packagekit.enable = false;
     
      # --- AppImage support ---
      programs.appimage = {
        enable = true;
        binfmt = true;
      };

    };

}
