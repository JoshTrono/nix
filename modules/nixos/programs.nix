{
  flake.modules.nixos.programs =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        vscodium
        flatpak
        nixfmt
        direnv
        vulnix

        brave
        discord
      ];
      programs.firefox.enable = true;
      programs.git.enable = true;
    };
}
