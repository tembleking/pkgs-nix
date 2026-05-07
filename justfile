update:
    #!/usr/bin/env bash
    set -euo pipefail
    for pkg in $(nix eval .#packages.x86_64-linux --apply 'ps: builtins.attrNames ps' --json | jq -r '.[]'); do
        store_path=$(nix eval --raw ".#packages.x86_64-linux.$pkg.updateScript" 2>/dev/null) || continue
        # Resolve source tree path (store paths are read-only)
        prefix="${pkg:0:2}"
        # Strip nix store hash prefix from basename
        name=$(basename "$store_path" | sed 's/^[a-z0-9]\{32\}-//')
        src_script="pkgs/by-name/$prefix/$pkg/$name"
        if [ -f "$src_script" ]; then
            echo ">>> Updating $pkg (source: $src_script)"
            "$src_script"
        else
            echo ">>> Updating $pkg (store: $store_path)"
            "$store_path"
        fi
    done
