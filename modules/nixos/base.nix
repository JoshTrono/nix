{ config, lib, pkgs, vars, ... }:

{
  config = {
    # Common Nix settings
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      flake-registry = "";
    };
    nix.channel.enable = false;

    # Common Boot settings
    boot.kernelPackages = pkgs.linuxPackages_latest;

    # Common Networking settings
    networking.networkmanager.enable = true;
    networking.hostName = "${vars.hostname}";
    networking.firewall.enable = config.services.base.firewall.enable or true;

    # Common Time settings
    time.timeZone = "America/New_York";

    # Common User settings
    users.users."${vars.username}" = {
      isNormalUser = true;
      initialPassword = "correcthorsebatterystaple";
      extraGroups = [
        "wheel"
        "networkmanager"
      ] ++ (config.services.base.extraGroups or []);
    };

    # Common SSH settings
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PubkeyAuthentication = true;
        PasswordAuthentication = false;
      };
    };

    # Common System settings
    system.stateVersion = "25.11";
  };

  options.services.base = {
    kernelPackages = lib.mkOption {
      type = lib.types.anything;
      default = pkgs.linuxPackages_latest;
      description = "The kernel packages to use.";
    };
    firewall.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable the firewall.";
    };
    extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Extra groups for the main user.";
    };
  };
}
