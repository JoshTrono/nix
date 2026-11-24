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

## 2. Choose the disks and RAID size

`disko.nix` takes two arguments, `disks` (a list of two device paths) and
`raidSize`, with defaults for the real server (the two by-id paths above and
`230G`). Run disko on the file (not with `--flake`) to override them:

- Real server: use the defaults, nothing to pass. To use other disks add
  `--arg disks '[ "/dev/disk/by-id/<disk-1>" "/dev/disk/by-id/<disk-2>" ]'`.
- VM test (two 20G virtio disks): `--arg disks '[ "/dev/vda" "/dev/vdb" ]' --argstr raidSize 15G`.

`raidSize` must fit on the smaller disk and is the same on both so mdadm does
not ask its size-mismatch question.

## 3. Create the RAID 1 array and mount it

Real server:

```bash
sudo nix --extra-experimental-features 'nix-command flakes' run github:nix-community/disko/latest -- \
  --mode destroy,format,mount --yes-wipe-all-disks ./nixos/Server/disko.nix
```

VM test:

```bash
sudo nix --extra-experimental-features 'nix-command flakes' run github:nix-community/disko/latest -- \
  --mode destroy,format,mount --yes-wipe-all-disks ./nixos/Server/disko.nix \
  --arg disks '[ "/dev/vda" "/dev/vdb" ]' --argstr raidSize 15G
```

Do not use `--disk` or `--flake` here; `--disk` is only for `disko-install`.
The installed system refers to `/dev/md/root` and partition labels, so the paths
and sizes passed here do not have to match anything in the flake.

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

## 5. The main library disk

`/mnt/mainlibrary` is declared in `modules/nixos/server/mainlibrary.nix` and
imported by the `ServerRaid` output, so regenerating `hardware-raid.nix` in
step 4 does not touch it.

Immich stores its media in `/mnt/mainlibrary/immich`
(`modules/nixos/server/immich.nix`), so Immich expects this mount to exist. The
mount is strict: if the disk is missing at boot, the machine drops to emergency
mode.

1. Make sure the data array is assembled and find its filesystem UUID:

   ```bash
   sudo mdadm --assemble --scan     # only if it is not already assembled
   sudo blkid                       # find the ext4 entry for the data array (not the new RAID 1 disks)
   ```

2. Compare it with the UUID in `modules/nixos/server/mainlibrary.nix`
   (`0d77e4fd-206d-48b3-a653-62e552f80198`, from the previous install). If
   `blkid` shows a different one, edit that file.

3. No data disk attached? Remove `self.modules.nixos.mainlibrary` from the
   `ServerRaid` modules in `flake.nix` before installing, and add it back later.

## 6. Install

```bash
sudo nixos-install --flake .#ServerRaid --no-root-passwd
# The config sets no password for your user (the repo is public), so set one
# before rebooting or you cannot log in:
sudo nixos-enter --root /mnt -c 'passwd joshua'
sudo reboot
```

GRUB is installed to both ESPs (`mirroredBoots` in
`nixos/Server/configuration.nix`), so the machine can boot from either disk.

## 7. After the first boot

- Check the array: `cat /proc/mdstat` (should show `[UU]`).
- Add your SSH public key to `sshKeys` in `variables.nix`, commit, and rebuild.
  Until a key is listed the server still accepts SSH password logins and the
  build prints a warning; once a key is there, password logins turn off. Test
  the key from a second terminal before closing your first session.
- Commit `nixos/Server/hardware-raid.nix` back to GitHub so the repo matches the
  machine. Nightly auto-upgrade follows
  `github:joshtrono/nix#ServerRaid`.

## Troubleshooting

| Symptom | Cause / fix |
|---------|-------------|
| `sed: can't read nixos/Server/disko.nix` | Wrong directory or stale clone. `cd` into the repo; `git pull`. |
| disko prints its usage text | An option it does not know, usually `--disk`. Use the exact command in step 3. |
| `mdadm: largest drive exceeds size ... Continue creating array [y/N]` then `create aborted` | RAID partitions are not equal size. Use the same `raidSize` for both disks (step 2). |
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

`disko-install` cannot change `raidSize`, so it uses the default in `disko.nix`. It also uses
whatever `hardware-raid.nix` is already in the repo, so regenerate that first if
the hardware changed.
