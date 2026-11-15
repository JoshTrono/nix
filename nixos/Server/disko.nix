# Declarative disk layout for a fresh Server install with RAID 1.
#
# Both disks get the same layout:
#   - 1G ESP   (disk "one" -> /boot, disk "two" -> /boot2; GRUB mirroredBoots keeps them in sync)
#   - the rest as an mdadm RAID 1 member
# The two RAID members form /dev/md/root, formatted ext4 and mounted at /.
#
# Pick the disks at install time with --disk, or replace the placeholders below
# with stable /dev/disk/by-id/... paths:
#   disko-install --flake .#ServerRaid \
#     --disk one /dev/disk/by-id/<disk-1> --disk two /dev/disk/by-id/<disk-2>
{ lib, ... }:
{
  disko.devices = {
    disk = {
      one = {
        type = "disk";
        device = lib.mkDefault "/dev/disk/by-id/CHANGE-ME-DISK-1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            raid = {
              size = "100%";
              content = {
                type = "mdraid";
                name = "root";
              };
            };
          };
        };
      };
      two = {
        type = "disk";
        device = lib.mkDefault "/dev/disk/by-id/CHANGE-ME-DISK-2";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot2";
                mountOptions = [ "umask=0077" ];
              };
            };
            raid = {
              size = "100%";
              content = {
                type = "mdraid";
                name = "root";
              };
            };
          };
        };
      };
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
