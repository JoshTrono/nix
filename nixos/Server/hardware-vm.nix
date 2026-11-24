# Hardware config for the ServerRaidVM test output (QEMU/KVM guest).
# / , /boot and /boot2 come from ./disko.nix (+ ./disko-vm.nix); there is no
# /mnt/mainlibrary here, so Immich simply writes under / in the VM.
{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  # The test VM has no Netbird, so keep SSH and the web UIs reachable on every
  # interface instead of the Netbird-only rules from modules/nixos/server/firewall.nix.
  services.openssh.openFirewall = lib.mkForce true;
  networking.firewall.allowedTCPPorts = [
    config.services.immich.port
    8096
    8920
  ];

  boot.swraid.enable = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # The VM output is not pushed anywhere meant to be tracked; don't let it self-upgrade.
  system.autoUpgrade.enable = lib.mkForce false;
}
