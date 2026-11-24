# The Server's separate media/data disk (Immich stores its library here).
#
# Lives in its own module, not in nixos/Server/hardware-raid.nix, because that
# file is regenerated with nixos-generate-config at install time and would
# lose a hand-added mount. Imported by the ServerRaid output in flake.nix.
#
# The mount is strict: if the disk is missing the machine drops to emergency
# mode instead of letting Immich write into / under /mnt/mainlibrary. Adding
# "nofail" is only safe if Immich is also made to require this mount.
{
  flake.modules.nixos.mainlibrary = {
    fileSystems."/mnt/mainlibrary" = {
      device = "/dev/disk/by-uuid/0d77e4fd-206d-48b3-a653-62e552f80198";
      fsType = "ext4";
    };
  };
}
