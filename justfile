update:
    #!/usr/bin/env bash
    set -euo pipefail

    for pkg in $(nix eval .#packages.x86_64-linux --apply 'ps: builtins.attrNames ps' --json | jq -r '.[]'); do
        if nix eval ".#packages.x86_64-linux.$pkg.skipAutoUpdate" 2>/dev/null | grep -q "true"; then
            echo ">>> Skipping $pkg (skipAutoUpdate)"
            continue
        fi

        echo ">>> Updating $pkg"
        nix-update --flake -u "$pkg" || true
    done
