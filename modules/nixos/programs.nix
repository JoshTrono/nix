{
  flake.modules.nixos.programs =
    {
      pkgs,
      inputs,
      lib,
      vars,
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

        epicPkgs.epic-games-launcher

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
