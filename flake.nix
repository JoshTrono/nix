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

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # --- Multiverse (Pull Any Published Package) ---
    multiverse.url = "github:fzakaria/nixpkgs-multiverse";



    #LTS - for server once 26.05 no longer is supported
    nixpkgs-lts.url = "https://channels.cyberus-linux.com/channel/cyberus-linux-26.05.tar.xz";
  };

  outputs =
    inputs@{ flake-parts, home-manager, ... }:
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
          "aarch64-linux"
          "i686-linux"
          "x86_64-linux"
          "aarch64-darwin"
          "x86_64-darwin"
        ];

        # Per-system outputs. 'pkgs' here is nixpkgs.legacyPackages.${system}.
        perSystem =
          { pkgs, ... }:
          {
            # Your custom packages
            # Accessible through 'nix build', 'nix shell', etc
            packages = import ./pkgs pkgs;

            # Formatter for your nix files, available through 'nix fmt'
            # Other options beside 'alejandra' include 'nixpkgs-fmt'
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
                # > Our main nixos configuration file <
                ./nixos/Zeus/configuration.nix
              ];
            };

            Server = inputs.nixpkgs-lts.lib.nixosSystem {
              specialArgs = {
                inherit inputs;
                vars = hosts.Server;
              };
              modules = [
                # > Our main nixos configuration file <
                ./nixos/Server/configuration.nix
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
