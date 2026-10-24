{ config, lib, pkgs, vars, ... }:
{
  services.netbird = {
    clients.wt0 = {
      login = {
        enable = true;
        setupKeyFile = "/home/${vars.username}/netbird-key";
      };

      environment = {
        NB_ENABLE_ROSENPASS = "true";
      };

      port = 51820;
      openFirewall = true;
      openInternalFirewall = true;
    };
  };
  services.netbird.useRoutingFeatures = "both";

  services.resolved.enable = true;
}
