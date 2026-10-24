{ config, lib, pkgs, ... }:
let
  netextender = pkgs.callPackage ../../pkgs/netextender.nix { };
in
{
  environment.systemPackages = [ netextender ];

  # The vendor binaries and systemd unit expect everything under
  # /usr/local/netextender (that is where install.sh copies it).
  systemd.tmpfiles.rules = [
    "d /usr/local 0755 root root -"
    "L+ /usr/local/netextender - - - - ${netextender}/opt/netextender"
  ];

  # Port of the vendor NEService.service.
  systemd.services.NEService = {
    description = "SonicWall NetExtender Service";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    # pppd (SSLVPN mode) and wg-quick (WireGuard mode) need ip, iptables,
    # resolvconf and friends. The last entry puts the system profile on
    # PATH as a catch-all.
    path = with pkgs; [
      coreutils
      bash
      iproute2
      iptables
      ppp
      procps
      gnugrep
      gnused
      "/run/current-system/sw"
    ];

    serviceConfig = {
      ExecStartPre = "${pkgs.coreutils}/bin/rm -f /var/run/NEService.pid";
      ExecStart = "/usr/local/netextender/NEService";
      Restart = "on-failure";
      KillMode = "process";
    };
  };
}
