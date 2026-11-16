# Server install (RAID 1)

Fresh install of the `Server` host onto two disks in RAID 1, using the
`ServerRaid` flake output and `nixos/Server/disko.nix`.

Layout created on each disk:

| Partition | Size | Use |
|-----------|------|-----|
| ESP       | 1G   | disk one -> `/boot`, disk two -> `/boot2` (GRUB `mirroredBoots` keeps both bootable) |
| raid      | 230G | member of the mdadm RAID 1 array `/dev/md/root` (ext4, mounted at `/`) |

The RAID partitions are a fixed size (not `100%`) so both are identical even if
the disks differ in size. `mdadm` asks an interactive question when sizes differ
by more than 1%, and disko cannot answer it. Pick a size that fits on the
smaller disk. Spare space on either disk is left unused.

`/mnt/mainlibrary` (media/Immich data) is a separate disk and is optional. See
step 5.

> Everything below wipes the two chosen disks. Double-check disk IDs.

## 0. Before you start

- Boot the NixOS graphical/minimal ISO and get network working.
- Know your two disk IDs. List them with `ls -l /dev/disk/by-id` and compare
  sizes with `lsblk`. Use the `ata-...`, `nvme-...` or `wwn-...` names, not the
  ones ending in `-part1`.
- Current server disks:
  - `ata-WDC_WDS250G2B0B_19435B803332` (disk one, `/boot`)
  - `ata-SPCC_Solid_State_Disk_AA000000000000001163` (disk two, `/boot2`)

## 1. Clone the repo

```bash
git clone https://github.com/JoshTrono/nix
cd nix
ls nixos/Server        # must list disko.nix and hardware-raid.nix
```

If `disko.nix` is missing you are in the wrong directory or have an old clone.

## 2. Set the disks in `disko.nix`

The checked-in file has placeholders and `size = "100%"`. Replace them
(edit the IDs if the disks changed):

```bash
sed -i \
  -e 's|CHANGE-ME-DISK-1|ata-WDC_WDS250G2B0B_19435B803332|' \
  -e 's|CHANGE-ME-DISK-2|ata-SPCC_Solid_State_Disk_AA000000000000001163|' \
  -e 's|size = "100%";|size = "230G";|' \
  nixos/Server/disko.nix

grep -nE 'device = |size = ' nixos/Server/disko.nix
# expect: the two /dev/disk/by-id/ata-... paths, then sizes 1G, 230G, 1G, 230G
```

(If you commit these values to the repo, you can skip this step next time.)

## 3. Create the RAID 1 array and mount it

```bash
sudo nix --extra-experimental-features 'nix-command flakes' run github:nix-community/disko/latest -- \
  --mode destroy,format,mount --flake .#ServerRaid --yes-wipe-all-disks
```

Do not pass `--disk`. This disko command does not have that option (only
`disko-install` does). Do not pipe `yes` into it either; disko answers the one
`mdadm` question it needs to itself.

Verify:

```bash
cat /proc/mdstat                  # raid1, active, both members (resync is fine)
findmnt /mnt /mnt/boot /mnt/boot2 # /dev/md/root, then the two ESPs
```

## 4. Regenerate the hardware config

The server's hardware file is not tracked as the source of truth; regenerate it
for this machine. Use `--no-filesystems` so it does not clash with the
filesystems disko defines:

```bash
nixos-generate-config --root /mnt --no-filesystems --show-hardware-config \
  | sudo tee nixos/Server/hardware-raid.nix
```

Check it parses: `nix-instantiate --parse nixos/Server/hardware-raid.nix >/dev/null && echo ok`

## 5. (Optional) Re-add the main library disk

Skip this section if you do not have the data disk attached, or want to add it
later.

Immich stores its media in `/mnt/mainlibrary/immich`
(`modules/nixos/server/immich.nix`), so Immich expects this mount to exist.

1. Make sure the data array is assembled and find its filesystem UUID:

   ```bash
   sudo mdadm --assemble --scan     # only if it is not already assembled
   sudo blkid                       # find the ext4 entry for the data array (not the new RAID 1 disks)
   ```

2. Add this block to `nixos/Server/hardware-raid.nix`, inside the outer `{ ... }`,
   for example right after `boot.extraModulePackages = [ ];`:

   ```nix
   fileSystems."/mnt/mainlibrary" = {
     device = "/dev/disk/by-uuid/<uuid-from-blkid>";
     fsType = "ext4";
   };
   ```

   The previous install used `0d77e4fd-206d-48b3-a653-62e552f80198`. Use it only
   if `blkid` shows the same UUID.

3. Re-check syntax:

   ```bash
   nix-instantiate --parse nixos/Server/hardware-raid.nix >/dev/null && echo ok
   ```

To add it after install instead, put the same block in the file on the server
and run `sudo nixos-rebuild switch --flake .#ServerRaid`.

## 6. Install

```bash
sudo nixos-install --flake .#ServerRaid --no-root-passwd
sudo reboot
```

GRUB is installed to both ESPs (`mirroredBoots` in
`nixos/Server/configuration.nix`), so the machine can boot from either disk.

## 7. After the first boot

- Check the array: `cat /proc/mdstat` (should show `[UU]`).
- Commit `nixos/Server/hardware-raid.nix` and the `disko.nix` disk values back to
  GitHub so the repo matches the machine. Nightly auto-upgrade follows
  `github:joshtrono/nix#ServerRaid`.

## Troubleshooting

| Symptom | Cause / fix |
|---------|-------------|
| `sed: can't read nixos/Server/disko.nix` | Wrong directory or stale clone. `cd` into the repo; `git pull`. |
| disko prints its usage text | An option it does not know, usually `--disk`. Use the exact command in step 3. |
| `mdadm: largest drive exceeds size ... Continue creating array [y/N]` then `create aborted` | RAID partitions are not equal size. Use fixed `size = "230G"` on both (step 2). |
| `syntax error, unexpected end of file` in `hardware-raid.nix` | Missing `}` or `;` after editing. Run `nix-instantiate --parse` on it. |
| `No space left on device` during install | The ISO's RAM-backed store filled up. `sudo mount -o remount,size=8G /nix/.rw-store`, and `export TMPDIR=/mnt/tmp` (after `sudo mkdir -p /mnt/tmp`). |
| `ServerRaid` not found | Old checkout. `git pull` and check `git log` shows the `server-raid1` merge. |

## One-command alternative

`disko-install` partitions and installs in one step and accepts `--disk`:

```bash
sudo nix --extra-experimental-features 'nix-command flakes' run 'github:nix-community/disko/latest#disko-install' -- \
  --flake .#ServerRaid \
  --disk one /dev/disk/by-id/<disk-1> \
  --disk two /dev/disk/by-id/<disk-2>
```

You still need equal RAID partition sizes (step 2's `size` change), and it uses
whatever `hardware-raid.nix` is already in the repo, so regenerate that first if
the hardware changed.
