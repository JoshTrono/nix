{ config, lib, pkgs, vars, inputs, ... }:
let
  nixos = inputs.self.nixosModules;
in
{
  imports = [
    nixos.base
    nixos.nh
    nixos.de
    nixos.bootloader
    nixos.steam
    nixos.programs
    nixos.multiverse
    nixos.nix-caches
    nixos.vm
    #nixos.ai
    nixos.netbird
    nixos.netextender
    inputs.hardware.nixosModules.framework-16-amd-ai-300-series
     ./hardware.nix
  ];

  # Zeus-specific overrides/additions
  services.base.kernelPackages = pkgs.linuxPackages_latest;
  networking.networkmanager.wifi.powersave = false;
  
  services.base.extraGroups = [
    "netbird-wt0"
    "video"
    "audio"
  ];

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024; # 32 GiB
    }
  ];

  services.netbird.ui.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      cups-filters
      cups-browsed
    ];
  };

  system.autoUpgrade = {
    enable = true;
    flake = "/home/${vars.username}/.dotfiles";
    flags = [
      "--print-build-logs"
      "--commit-lock-file"
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };

  programs.bash.interactiveShellInit = ''
    [ -f "$HOME/.config/work-aliases.sh" ] && . "$HOME/.config/work-aliases.sh"
  '';

  environment.systemPackages = with pkgs; [
    iputils
    nmap
    dnsutils
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
    allowedUDPPorts = [ 53 ];
  };

  # Set your hostname
  networking.hostName = "${vars.hostname}";

  time.timeZone = "America/New_York";

  users.users = {
    "${vars.username}" = {
      initialPassword = "correcthorsebatterystaple";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        # Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
      extraGroups = [
        "wheel"
        "networkmanager"
        "netbird-wt0"
        "video"
        "audio"
      ];
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      PubkeyAuthentication = true;
      X11Forwarding = true;
    };
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.11";
}
