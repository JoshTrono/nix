# Per-host values, passed to every module as `vars` (see flake.nix).
let
  # SSH public keys allowed to log in as the main user, on every host.
  # Paste yours here, e.g. "ssh-ed25519 AAAA... you@host".
  # While this list is empty the Server still accepts SSH password logins (and
  # the build prints a warning); once it has a key, password logins turn off.
  sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIX5wsuRPq3jfTXqe71U8rPTX6YvNQK/HOfihLUML7zS joshua@Zeus
    "
  ];

  # Branch the Server's nightly auto-upgrade follows. Point this at a protected
  # branch (e.g. "deploy") that you merge into on purpose, instead of master.
  deployRef = "master";
in
{
  Zeus = {
    hostname = "Zeus";
    username = "joshua";
    system = "x86_64-linux";
    inherit sshKeys;
  };
  Server = {
    hostname = "Server";
    username = "joshua";
    system = "x86_64-linux";
    inherit sshKeys deployRef;
  };
  # Server installed on two disks in RAID 1. Same hostname, different flake output.
  ServerRaid = {
    hostname = "Server";
    flakeAttr = "ServerRaid";
    username = "joshua";
    system = "x86_64-linux";
    inherit sshKeys deployRef;
  };
  # VM copy of ServerRaid for testing the install. Same hostname, different flake output.
  ServerRaidVM = {
    hostname = "Server";
    flakeAttr = "ServerRaidVM";
    username = "joshua";
    system = "x86_64-linux";
    inherit sshKeys deployRef;
  };
}
