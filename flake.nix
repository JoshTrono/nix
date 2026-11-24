{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.
    hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Flake parts
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    import-tree.url = "github:vic/import-tree";

    # Declarative disk partitioning (used by the Server RAID 1 install)
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # --- Multiverse (Pull Any Published Package) ---
    multiverse.url = "github:fzakaria/nixpkgs-multiverse";

    lanzaboote = {
      # https://github.com/nix-community/lanzaboote/tags
      url = "github:nix-community/lanzaboote/v1.2.0";
      # follows unstable since lanzaboote recommends to run on unstable since it's active development
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

  };

  outputs =
    inputs@{
      flake-parts,
      home-manager,
      lanzaboote,

      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { self, ... }:
      let
        hosts = import ./variables.nix;
      in
      {
        imports = [
          # Provides the 'flake.modules.<class>.<name>' option
          flake-parts.flakeModules.modules
          # Loads every .nix file under ./modules as a flake-parts module
          (inputs.import-tree ./modules)
        ];

        # Supported systems for your flake packages, shell, etc.
        systems = [
          "x86_64-linux"
        ];

        # Per-system outputs. 'pkgs' here is nixpkgs.legacyPackages.${system}.
        perSystem =
          { system, ... }:
          let
            pkgs = import inputs.nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
          in
          {
            # Makes 'pkgs' unfree-enabled for everything else in perSystem too
            _module.args.pkgs = pkgs;

            packages = import ./pkgs pkgs;

            formatter = pkgs.alejandra;
          };

        # System-independent outputs
        flake = {
          # Your custom packages and modifications, exported as overlays
          overlays = import ./overlays { inherit inputs; };

          # Reusable nixos modules you might want to export
          # These are usually stuff you would upstream into nixpkgs
          nixosModules = import ./modules/nixos;

          # Reusable home-manager modules you might want to export
          # These are usually stuff you would upstream into home-manager
          homeManagerModules = import ./modules/home-manager;

          # NixOS configuration entrypoint
          # Available through 'nixos-rebuild --flake .#your-hostname'
          nixosConfigurations = {
            # FIXME replace with your hostname
            Zeus = inputs.nixpkgs.lib.nixosSystem {
              specialArgs = {
                inherit inputs;
                vars = hosts.Zeus;
              };

              modules = [

                lanzaboote.nixosModules.lanzaboote

                ({ pkgs, lib, ... }: {

                  environment.systemPackages = [
                    # For debugging and troubleshooting Secure Boot.
                    pkgs.sbctl
                  ];

                  # Lanzaboote currently replaces the systemd-boot module.
                  # This setting is usually set to true in configuration.nix
                  # generated at installation time. So we force it to false
                  # for now.
                  boot.loader.systemd-boot.enable = lib.mkForce false;

                  boot.lanzaboote = {
                    enable = true;
                    pkiBundle = "/var/lib/sbctl";
                  };
                })
                ./nixos/Zeus/configuration.nix
              ];
            };

            Server = inputs.nixpkgs.lib.nixosSystem {
              specialArgs = {
                # inputs = inputs // {
                #   nixpkgs = inputs.nixpkgs-small;
                #   home-manager = inputs.home-manager-small;
                #   nix-index-database = inputs.nix-index-database-small;
                # };
                inherit inputs;
                vars = hosts.Server;
              };
              modules = [
                # > Our main nixos configuration file <
                ./nixos/Server/configuration.nix
                ./nixos/Server/hardware-configuration.nix
              ];
            };

            # Same server, but installed onto two disks in RAID 1 (see nixos/Server/disko.nix).
            # Install with: disko-install --flake .#ServerRaid --disk one <dev1> --disk two <dev2>
            ServerRaid = inputs.nixpkgs.lib.nixosSystem {
              specialArgs = {
                inherit inputs;
                vars = hosts.ServerRaid;
              };
              modules = [
                inputs.disko.nixosModules.disko
                ./nixos/Server/configuration.nix
                ./nixos/Server/hardware-raid.nix
                ./nixos/Server/disko.nix
                self.modules.nixos.mainlibrary
              ];
            };

            # Throwaway VM copy of ServerRaid for testing the RAID 1 install in QEMU/virt-manager.
            # Format with: disko ./nixos/Server/disko.nix --arg disks '[ "/dev/vda" "/dev/vdb" ]' --argstr raidSize 15G
            # (see nixos/Server/SERVER-INSTALL.md). No real hardware config, no /mnt/mainlibrary.
            ServerRaidVM = inputs.nixpkgs.lib.nixosSystem {
              specialArgs = {
                inherit inputs;
                vars = hosts.ServerRaidVM;
              };
              modules = [
                inputs.disko.nixosModules.disko
                ./nixos/Server/configuration.nix
                ./nixos/Server/hardware-vm.nix
                ./nixos/Server/disko.nix
              ];
            };
          };

          # Standalone home-manager configuration entrypoint
          # Available through 'home-manager --flake .#your-username@your-hostname'
          homeConfigurations = {
            # FIXME replace with your username@hostname
            "${hosts.Zeus.username}@${hosts.Zeus.hostname}" = home-manager.lib.homeManagerConfiguration {
              # Home-manager requires 'pkgs' instance
              pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux; # FIXME replace x86_64-linux with your architecture
              extraSpecialArgs = {
                inherit inputs;
                vars = hosts.Zeus;
              };
              modules = [
                # > Our main home-manager configuration file <
                ./home-manager/home.nix
              ];
            };
          };
        };
      }
    );
}
