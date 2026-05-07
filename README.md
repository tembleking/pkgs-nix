# pkgs-nix

Nix packages and NixOS modules not available in nixpkgs.

```sh
# List available packages
nix flake show github:tembleking/pkgs-nix
```

## Usage

```nix
{
  inputs.pkgs-nix.url = "github:tembleking/pkgs-nix";

  outputs = { pkgs-nix, ... }: {
    # Use the overlay
    nixpkgs.overlays = [ pkgs-nix.overlays.default ];

    # Or import a NixOS module (applies overlay automatically)
    imports = [ pkgs-nix.nixosModules.default ];
  };
}
```

## Adding a package

1. Create `pkgs/by-name/<two-letter-prefix>/<name>/default.nix`
2. Optionally add a NixOS module at `modules/<name>.nix`
3. `git add` the new files

Packages and modules are auto-discovered. No flake.nix changes needed.

### Auto-update

Add an `update.sh` to your package directory and set `passthru.updateScript = ./update.sh;`. The daily CI workflow runs all discovered update scripts automatically.
