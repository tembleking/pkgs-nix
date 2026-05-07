update:
    #!/usr/bin/env bash
    set -euo pipefail
    for pkg in $(nix eval .#packages.x86_64-linux --apply 'ps: builtins.attrNames ps' --json | jq -r '.[]'); do
        script=$(nix eval --raw ".#packages.x86_64-linux.$pkg.updateScript" 2>/dev/null) || continue
        echo ">>> Updating $pkg"
        eval "$script"
    done
