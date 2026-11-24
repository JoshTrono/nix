# AGENTS.md

## Key Commands
- `nix flake check` (validate the flake)
- `nixos-rebuild build --flake .#<Zeus|Server|ServerRaid|ServerRaidVM>` (build a host without activating it)
- `nix build .#netextender` (build the custom netextender package)

## Repo Structure
- `flake.nix`: inputs and outputs, including every `nixosConfigurations` entry.
- `variables.nix`: per-host values passed to modules as `vars` (hostname, username, SSH keys, deploy branch).
- `modules/nixos/`: NixOS modules, each defining `flake.modules.nixos.<name>`. Shared by every host: `base`, `users`, `ssh`, `nh`, `nixCaches`, `netbird`. Server-only modules are in `modules/nixos/server/`.
- `nixos/<Host>/`: host entry points (`configuration.nix`, hardware config, and for the Server `disko.nix` plus install notes).
- `home-manager/`: standalone Home Manager config for Zeus.
- `pkgs/` and `overlays/`: custom packages (netextender) and the overlays that expose them and `pkgs.unstable`.

## Framework Quirks
- Uses `flake-parts`. `import-tree` loads every `.nix` file under `modules/` as a flake-parts module, so a new file there is picked up automatically; don't leave stray `.nix` files in `modules/`.
- Hosts pull modules in with `inherit (inputs.self.modules) nixos;` and then `nixos.<name>`.
- NixOS 26.05 and Home Manager release-26.05. `pkgs.unstable` comes from nixpkgs-unstable through an overlay.
- `multiverse` provides `pkgs.multiverse` for pulling older package versions.

## Constraints
- This repo is public: never commit passwords, keys or tokens.
- Target NixOS 26.05; all dependencies must come from flake inputs.
- The Server auto-upgrades as root from the branch in `vars.deployRef`, so treat that branch as production.
