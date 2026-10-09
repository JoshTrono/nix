{
  flake.modules.nixos.steam = { pkgs, ... }: {
    programs.steam = {
      enable = true;
    };
    programs.steam.extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
    programs.gamemode.enable = true;
    environment.systemPackages = with pkgs; [
      (unstable.bottles.override { removeWarningPopup = true; })
    ];
  };
}
