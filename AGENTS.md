# AGENTS.md

## Workflow & Commands
- **Validate Configuration**: `nix flake check` (Essential pre-run check)
- **Build/Deploy**: `nixos-rebuild --flake .#<HostName> switch` (Switches configuration)
- **Build/Test**: `nixos-rebuild --flake .#<HostName> build` (Builds outputs for a specific host)
- **Update Flakes**: `nix flake update` (Fetches latest inputs and dependencies)
- **Test**: `nixos-rebuild --flake .#<HostName> test` (Runs tests for a specific host)

## Repo Structure
- **Flakes**: `flake.nix` is the main entry point.
- **Hosts**: Configuration is separated into host-specific directories (`nixos/Zeus/`, `nixos/Server/`).
- **Configuration Source**: `nixos/Zeus/configuration.nix` (Desktop) and `nixos/Server/configuration.nix` (Server).

## Framework Quirks & Constraints
- **NixOS Specific**: The configuration uses `nixos-26.05` and separates `nixpkgs` instances (`nixpkgs` vs. `nixpkgs-small`) for different host types.
- **Deployment**: Use `./scripts/deploy.sh` for simplified configuration switching.
- **Security**: SSH and networking are hardened (e.g., SSH key-only, firewall enabled).
- **Tooling**: Use `nix flake build` for environment setup, ensuring all dependencies are sourced from flake inputs.
