# Settings every host shares: nixpkgs config and overlays, nix settings,
# hostname, NetworkManager, timezone and kernel.
# Host-specific things stay in nixos/<Host>/configuration.nix.
{
  flake.modules.nixos.base =
    {
      inputs,
      pkgs,
      vars,
      ...
    }:
    {
      nixpkgs = {
        overlays = [
          # Custom packages (pkgs/), modifications, and `pkgs.unstable`
          # (see overlays/default.nix).
          inputs.self.overlays.additions
          inputs.self.overlays.modifications
          inputs.self.overlays.unstable-packages
        ];
        config.allowUnfree = true;
      };

      nix = {
        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          # Disable the global flake registry.
          flake-registry = "";
        };
        # Flakes only: no channels.
        channel.enable = false;
      };

      networking.hostName = vars.hostname;
      networking.networkmanager.enable = true;
      time.timeZone = "America/New_York";

      # The default (LTS) kernel. Use pkgs.linuxPackages_latest for the newest.
      boot.kernelPackages = pkgs.linuxPackages;
    };
}
