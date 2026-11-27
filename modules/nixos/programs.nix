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


      environment.systemPackages = with pkgs; [
        vscodium
        flatpak
        nixfmt
        discord
        freerdp
        dig

        kdePackages.kmines

        filezilla
        netextender
        fastfetch
        unstable.devenv
        google-chrome

        libreoffice
        logseq
      ];
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      #OBS
      programs.obs-studio = {
        enableVirtualCamera = true;
        enable = true;

        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
          obs-backgroundremoval
          obs-pipewire-audio-capture
          obs-vaapi # optional AMD hardware acceleration
          obs-gstreamer
          obs-vkcapture
        ];
      };

      programs.git = {
        enable = true;
        config.safe.directory = [ "/home/${vars.username}/.dotfiles" ];
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
