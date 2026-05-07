# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Nix flake mono-repo for packages and NixOS modules not in nixpkgs. Follows nixpkgs `by-name` convention with auto-discovery.

## Commands

```sh
nix flake show          # list all outputs
nix build .#<name>      # build a package
nix fmt                 # format all nix files (nixfmt-tree via treefmt)
nix flake check         # validate flake
```

New files must be `git add`ed before Nix can see them (flakes only read tracked files).

## Architecture

### Package auto-discovery

`flake.nix` scans `pkgs/by-name/<two-letter-prefix>/<name>/default.nix` via `builtins.readDir` and `callPackage`s each one into both the overlay and `packages` output. No manual registration needed.

**Exception:** `demisto-sdk` uses poetry2nix which is incompatible with nixpkgs-unstable, so it's built with a separate pinned nixpkgs (`poetry2nix.inputs.nixpkgs`) and merged into `packages` via `//`, overriding the lazy auto-discovered entry.

### Module auto-discovery

`modules/default.nix` scans for `.nix` files (excluding itself) and imports them. Modules are plain NixOS modules (`{ config, lib, pkgs, ... }:`) following the nixpkgs `mkPackageOption` pattern: each module exposes a `package` option defaulting to the overlay package, and uses `cfg.package` in config. The overlay must be applied for defaults to resolve.

### FHS-wrapped packages pattern

`carbonblack` and `cyberhaven` follow a split pattern:
- `unwrapped.nix`: base derivation (extracts .deb, patches ELF)
- `default.nix`: `buildFHSEnv` wrapper with `passthru.unwrapped` exposing the inner derivation

### Auto-update

Packages with `update.sh` in their directory set `passthru.updateScript = ./update.sh`. The GH Actions workflow (`.github/workflows/daily-update.yaml`) discovers and runs all `update.sh` files via `find`.

## Adding a package

1. `mkdir -p pkgs/by-name/<prefix>/<name>/`
2. Write `default.nix` (receives nixpkgs args via `callPackage`)
3. Optionally add `modules/<name>.nix` (plain NixOS module with `mkPackageOption`)
4. `git add` the new files
