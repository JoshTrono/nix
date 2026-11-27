# SonicWall NetExtender: installs the package from pkgs/netextender.nix and runs
# the vendor NEService daemon (as root, outside the Nix sandboxing options).
{
  flake.modules.nixos.netextender = { pkgs, ... }:
    let
      netextender = pkgs.callPackage ../../pkgs/netextender.nix { };
    in
    {
      environment.systemPackages = [ netextender ];


      systemd.tmpfiles.rules = [
        "d /usr/local 0755 root root -"
        "L+ /usr/local/netextender - - - - ${netextender}/opt/netextender"
      ];

      systemd.services.NEService = {
        description = "SonicWall NetExtender Service";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];


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
    };
}
