# Declarative disk layout for a fresh Server install with RAID 1.
#
# Both disks get the same layout:
#   - 1G ESP   (disk "one" -> /boot, disk "two" -> /boot2; GRUB mirroredBoots keeps them in sync)
#   - raidSize as an mdadm RAID 1 member
# The two RAID members form /dev/md/root, formatted ext4 and mounted at /.
#
# `disks` and `raidSize` have defaults for the real server, and can be overridden
# when running disko on this file directly (not with --flake):
#   disko --mode destroy,format,mount --yes-wipe-all-disks ./nixos/Server/disko.nix \
#     --arg disks '[ "/dev/vda" "/dev/vdb" ]' --argstr raidSize 15G
# The RAID partitions must be the same size on both disks (mdadm asks an
# interactive question otherwise), so raidSize is fixed rather than "100%".
{
  lib,
  disks ? [
    "/dev/disk/by-id/ata-WDC_WDS250G2B0B_19435B803332"
    "/dev/disk/by-id/ata-SPCC_Solid_State_Disk_AA000000000000001163"
  ],
  raidSize ? "230G",
  ...
}:
let
  disk = device: espMount: {
    type = "disk";
    device = lib.mkDefault device;
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = espMount;
            mountOptions = [ "umask=0077" ];
          };
        };
        raid = {
          size = raidSize;
          content = {
            type = "mdraid";
            name = "root";
          };
        };
      };
    };
  };
in
{
  disko.devices = {
    disk = {
      one = disk (builtins.elemAt disks 0) "/boot";
      two = disk (builtins.elemAt disks 1) "/boot2";
    };

    mdadm.root = {
      type = "mdadm";
      level = 1;
      content = {
        type = "filesystem";
        format = "ext4";
        mountpoint = "/";
      };
    };
  };
}
