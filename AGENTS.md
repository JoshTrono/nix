# AGENTS.md

## Key Commands
- `nix flake check` (validate flake configuration)
- `nix build` (build flake outputs)
- `npm run lint` (ESLint)
- `npm run typecheck` (TypeScript)
- `npm run test` (Jest)

## Test Execution
- Single test: `npm run test -- --testMatch 'path/to/file'`
- Watch mode: `npm run test -- --watch`
- Use `--no-cache` for fresh test runs

## Workflow
1. `lint -> typecheck -> test` (CI order)
2. Use `--fix` flag for auto-fixing lints

## Repo Structure
- Packages: `packages/`
- Configs: `.config/`
- CI: `.github/workflows/`
- Flakes: `flake.nix` and `default.nix`

## Framework Quirks
- TypeScript 5.2+ required
- Jest snapshots stored in `__snapshots__`
- NixOS flake integration required
- Use `yarn` for package management
- Test db mock required for integration tests

## Constraints
- No global npm installs
- Use `nix flake build` for environment setup
- All dependencies must come from flake inputs
- Avoid manual node versions; use flake-provided Nix defaults
