# The main user, shared by every host.
#
# There is deliberately no password here: this repo is public. Set one on the
# machine with `passwd` (on a fresh install: `nixos-enter --root /mnt -c 'passwd <user>'`).
# Per-module groups (libvirtd, video, netbird-wt0, ...) are added by those modules.
{
  flake.modules.nixos.users =
    { vars, ... }:
    {
      users.users.${vars.username} = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
      };
    };
}
