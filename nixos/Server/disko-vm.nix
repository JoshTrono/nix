# Overrides for testing ./disko.nix in a VM with two small virtio disks.
{ lib, ... }:
{
  disko.devices.disk.one.device = lib.mkForce "/dev/vda";
  disko.devices.disk.two.device = lib.mkForce "/dev/vdb";

  # Fixed, equal RAID partition sizes (mdadm prompts if they differ). Fits 20G disks.
  disko.devices.disk.one.content.partitions.raid.size = lib.mkForce "15G";
  disko.devices.disk.two.content.partitions.raid.size = lib.mkForce "15G";
}
