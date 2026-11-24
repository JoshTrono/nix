{ inputs, ... }: # <- flake-parts args, add this
{
  flake.modules.nixos.netbird = { lib, pkgs, vars, ... }: {

    # Replace the stable netbird module with the one from unstable
    # disabledModules = [ "services/networking/netbird.nix" ];
    # imports = [ "${inputs.nixpkgs-unstable}/nixos/modules/services/networking/netbird.nix" ];

    services.netbird = {
      # package = pkgs.unstable.netbird;
      # ui.package = pkgs.unstable.netbird-ui;

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
    # Only a host that routes traffic for other peers needs "server"/"both"
    # (IP forwarding); everything else stays a plain client. The Server sets
    # "both" itself in nixos/Server/configuration.nix.
    services.netbird.useRoutingFeatures = lib.mkDefault "client";

    # Lets the main user talk to the client (`netbird status`, the UI).
    users.users.${vars.username}.extraGroups = [ "netbird-wt0" ];

    services.resolved.enable = true;
  };
}
