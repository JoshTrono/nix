{
  flake.modules.nixos.jellyfin = {
    services.jellyfin = {
      enable = true;
      # Ports are opened on the Netbird interface only (see firewall.nix).
      openFirewall = false;
    };
  };
}
