{

  flake.modules.nixos.netbird = { pkgs, vars, ... }: {
    services.netbird = {
      package = pkgs.unstable.netbird;
      # ui.package = pkgs.unstable.netbird-ui;

      clients.wt0 = {

        # Automatically login to your Netbird network with a setup key
        # This is mostly useful for server computers.
        # For manual setup instructions, see the wiki page section below.
        login = {
          enable = true;

          # Path to a file containing the setup key for your peer
          # NOTE: if your setup key is reusable, make sure it is not copied to the Nix store.
          setupKeyFile = "/home/${vars.username}/netbird-key";
        };

        environment = {
          NB_ENABLE_ROSENPASS = "true";
          # Optional: still connect to peers that don't have Rosenpass enabled
          # NB_ROSENPASS_PERMISSIVE = "true";
        };

        # Port used to listen to wireguard connections
        port = 51821;

        # Set this to true if you want the GUI client
        ui.enable = false;

        # This opens ports required for direct connection without a relay
        openFirewall = true;

        # This opens necessary firewall ports in the Netbird client's network interface
        openInternalFirewall = true;
      };
    };
    services.resolved.enable = true;

  };
}
