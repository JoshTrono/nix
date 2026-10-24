{
  description = "Joshua's NixOS configuration";

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

    # AI
    nix-amd-ai.url = "github:noamsto/nix-amd-ai";

    # Flake parts
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    import-tree.url = "github:vic/import-tree";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # -- for secure boot
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- Multiverse (Pull Any Published Package) ---
    multiverse.url = "github:fzakaria/nixpkgs-multiverse";

    # For the server - keep nixpkgs-small for server-specific packages
    nixpkgs-small.url = "github:nixos/nixpkgs/nixos-26.05-small";
    home-manager-small = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-small";
    };

    nix-index-database-small = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-small";
    };
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
           # Loads every .nix file under ./flake-modules as a flake-parts module
           (inputs.import-tree ./flake-modules)

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
             # Desktop system
             Zeus = inputs.nixpkgs.lib.nixosSystem {
               specialArgs = {
                 inherit inputs;
                 vars = hosts.Zeus;
               };
               modules = [
                 ./hosts/zeus/nixos.nix
               ];
             };

             # Server system - using nixpkgs-small for better compatibility
             Server = inputs.nixpkgs-small.lib.nixosSystem {
               specialArgs = {
                 inputs = inputs // {
                   nixpkgs = inputs.nixpkgs-small;
                   home-manager = inputs.home-manager-small;
                   nix-index-database = inputs.nix-index-database-small;
                 };
                 vars = hosts.Server;
               };
               modules = [
                 ./hosts/server/nixos.nix
               ];
             };
           };

           # Standalone home-manager configuration entrypoint
           # Available through 'home-manager --flake .#your-username@your-hostname'
           homeConfigurations = {
             # Desktop user configuration
             "${hosts.Zeus.username}@${hosts.Zeus.hostname}" = home-manager.lib.homeManagerConfiguration {
               # Home-manager requires 'pkgs' instance
               pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux; # Use x86_64-linux for desktop
               extraSpecialArgs = {
                 inherit inputs;
                 vars = hosts.Zeus;
               };
               modules = [
                 ./hosts/zeus/home-manager.nix
               ];
             };
           };

        };
      }
    );
}
