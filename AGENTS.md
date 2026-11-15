# AGENTS.md

## Key Commands
- `nix flake check` (validate flake configuration)
- `nix build .#netextender` (build the custom netextender package)

## Repo Structure
- `modules/`: Reusable NixOS and Home Manager modules.
- `home-manager/`: User-specific Home Manager configuration.
- `pkgs/`: Custom Nix packages and overlays.
- `nixos/`: System-specific NixOS configurations (Zeus, Server).
- `variables.nix`: Host-specific variables for configurations.

## Framework Quirks
- Uses `flake-parts` for flake organization.
- Uses `import-tree` to automatically load modules from `modules/`.
- NixOS 26.05 and Home Manager 26.05 targets.
- `nix-index-database` is used for faster lookups.
- `multiverse` is available for pull-any-published-package.

## Constraints
- NixOS 26.05 required.
- All dependencies must come from flake inputs.
- Use `nix flake build` for environment setup.
- Avoid manual node versions; use flake-provided Nix defaults.
