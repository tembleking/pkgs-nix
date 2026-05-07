update:
    #!/usr/bin/env bash
    set -euo pipefail
    for pkg in $(nix eval .#packages.x86_64-linux --apply 'ps: builtins.attrNames ps' --json | jq -r '.[]'); do
        echo ">>> Updating $pkg"
        nix-update --flake --use-update-script "$pkg" || true
    done
