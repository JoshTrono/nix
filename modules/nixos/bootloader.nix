# /.dotfiles/modules/bootloader.nix
# Lanzaboote (Secure Boot on systemd-boot) + Plymouth.
{ inputs, ... }:
{
  flake.modules.nixos.bootloader = { config, lib, pkgs, ... }: {

    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.timeout = 5;

boot.loader.limine = {
  enable = true;
  secureBoot.enable = true;
};
    environment.systemPackages = [ pkgs.sbctl ];

    # TPM support: systemd-based initrd is needed for TPM2 LUKS unlock
    security.tpm2.enable = true;
    boot.initrd.systemd.enable = true;

    boot.plymouth = {
      enable = true;
      theme = "rings";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override { selected_themes = [ "rings" ]; })
      ];
    };
    boot.consoleLogLevel = 0;
    boot.initrd.verbose = false;
    boot.kernelParams = [
      "quiet"
      "splash"
      "udev.log_level=3"
      "usbcore.autosuspend=-1"
    ];

    boot.tmp.cleanOnBoot = true;
  };
}