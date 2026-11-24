# Server: reachable only over Netbird.
#
# SSH, Immich and Jellyfin used to be open on every network interface (plain
# HTTP). Their ports are now opened only on the Netbird interface. If the
# Netbird client is down the server can only be reached from its console.
#
# If TVs or phones on your LAN need Jellyfin/Immich without Netbird, open just
# those ports to your LAN subnet instead of to everyone, e.g. with
# networking.nftables.enable = true and:
#   networking.firewall.extraInputRules =
#     "ip saddr 192.168.1.0/24 tcp dport { 8096, 2283 } accept";
{
  flake.modules.nixos.serverFirewall =
    { config, ... }:
    let
      # Read from the client config instead of hardcoding it: the interface
      # NixOS creates for `services.netbird.clients.wt0` is not necessarily
      # called "wt0".
      netbirdIf = config.services.netbird.clients.wt0.interface;
    in
    {
      services.openssh.openFirewall = false;

      networking.firewall.interfaces.${netbirdIf}.allowedTCPPorts = [
        22 # ssh
        config.services.immich.port
        8096 # jellyfin http
        8920 # jellyfin https
      ];
    };
}
