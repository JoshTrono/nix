{
  base = ./base.nix;
  ai = ./ai.nix;
  vm = ./vm.nix;
  steam = ./steam.nix;
  server = {
    immich = ./server/immich.nix;
    jellyfin = ./server/jellyfin.nix;
    forgejo = ./server/forgejo.nix;
  };
  bootloader = ./bootloader.nix;
  netextender = ./netextender.nix;
  netbird = ./netbird.nix;
  de = ./de.nix;
  nix-caches = ./nix-caches.nix;
  programs = ./programs.nix;
  nh = ./nh.nix;
  multiverse = ./multiverse.nix;
}
