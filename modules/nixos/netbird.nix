{ inputs, ... }: # <- flake-parts args, add this
{
  flake.modules.nixos.netbird = { pkgs, vars, ... }: {

    # Replace the stable netbird module with the one from unstable
    disabledModules = [ "services/networking/netbird.nix" ];
    imports = [ "${inputs.nixpkgs-unstable}/nixos/modules/services/networking/netbird.nix" ];

    services.netbird = {
      package = pkgs.unstable.netbird;
      ui.package = pkgs.unstable.netbird-ui;

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

    services.resolved.enable = true;
  };
}
