{
  Zeus = {
    hostname = "Zeus";
    username = "joshua";
    system = "x86_64-linux";
  };
  Server = {
    hostname = "Server";
    username = "joshua";
    system = "x86_64-linux";
  };
  # Server installed on two disks in RAID 1. Same hostname, different flake output.
  ServerRaid = {
    hostname = "Server";
    flakeAttr = "ServerRaid";
    username = "joshua";
    system = "x86_64-linux";
  };
  # VM copy of ServerRaid for testing the install. Same hostname, different flake output.
  ServerRaidVM = {
    hostname = "Server";
    flakeAttr = "ServerRaidVM";
    username = "joshua";
    system = "x86_64-linux";
  };
}
