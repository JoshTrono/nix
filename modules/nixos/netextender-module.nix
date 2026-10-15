{ ... }:
{
  flake.modules.nixos.netextender =
    { config, lib, pkgs, ... }:
    let
      cfg = config.services.netextender;
    in
    {
      options.services.netextender.enable = lib.mkEnableOption "SonicWall NetExtender VPN client";

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [ pkgs.netextender ];
        boot.kernelModules = [ "tun" ];

        systemd.services.netextender = {
          description = "SonicWall NetExtender service";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];
          # path = [ pkgs.openresolv pkgs.iptables ];  # uncomment if the journal shows missing tools
          serviceConfig = {
            ExecStart = "${pkgs.netextender}/bin/NEService";
            Restart = "on-failure";
            StateDirectory = "netextender";
          };
        };
      };
    };
}