# NixOS Configuration

This is my personal NixOS configuration managed with flakes.

## Structure

- `flake.nix`: Main flake configuration
- `variables.nix`: Host configuration variables
- `nixos/`: NixOS configurations
  - `Zeus/`: Desktop configuration
  - `Server/`: Server configuration
- `home-manager/`: Home Manager configuration
- `modules/`: Reusable NixOS modules
- `overlays/`: Custom package overlays
- `pkgs/`: Custom packages
- `templates/`: Project templates

## Hosts

- **Zeus**: Desktop system (Framework laptop with AMD AI)
- **Server**: Server system (using nixpkgs-small for better compatibility)

# NixOS Configuration
 
This is my personal NixOS configuration managed with flakes.
 
## Structure
 
- `flake.nix`: Main flake configuration
- `variables.nix`: Host configuration variables
- `nixos/`: NixOS configurations
  - `Zeus/`: Desktop configuration
  - `Server/`: Server configuration
- `home-manager/`: Home Manager configuration
- `modules/`: Reusable NixOS modules
- `overlays/`: Custom package overlays
- `pkgs/`: Custom packages
- `templates/`: Project templates
 
## Hosts
 
- **Zeus**: Desktop system (Framework laptop with AMD AI)
- **Server**: Server system (using nixpkgs-small for better compatibility)
 
## Key Features
 
- Uses nixos-26.05 stable release
- Separate nixpkgs for server to maintain compatibility
- Home Manager for user environment management
- Nix-index-database for improved package search
- Lanzaboote for secure boot
- Netbird for networking
- AI packages via nix-amd-ai
 
## Security Hardening
 
The configurations enforce strict security measures:
 
- **SSH**: Key-only authentication is required on both hosts, disabling password login. Root login via SSH is disabled.
- **Firewall**: A robust firewall is enabled on both the desktop and server.
- **System Updates**: `system.autoUpgrade` is configured to ensure the system is kept up-to-date automatically.
 
## Usage
 
```bash
# Build and switch to a configuration
sudo nixos-rebuild --flake .#Zeus switch
 
# Build a configuration
nixos-rebuild --flake .#Server build
 
# Update flakes
nix flake update
```
 
## Development
 
```bash
# Test configuration
nixos-rebuild --flake .#Zeus test
 
# Check syntax
nix flake check
```