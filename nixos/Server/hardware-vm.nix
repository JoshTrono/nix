# Hardware config for the ServerRaidVM test output (QEMU/KVM guest).
# / , /boot and /boot2 come from ./disko.nix (+ ./disko-vm.nix); there is no
# /mnt/mainlibrary here, so Immich simply writes under / in the VM.
{ lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.swraid.enable = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # The VM output is not pushed anywhere meant to be tracked; don't let it self-upgrade.
  system.autoUpgrade.enable = lib.mkForce false;
}
