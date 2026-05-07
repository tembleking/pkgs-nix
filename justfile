update:
    #!/usr/bin/env bash
    set -euo pipefail

    repo_root="$(pwd)"
    flake_store=$(nix flake metadata --json | jq -r '.path')

    for pkg in $(nix eval .#packages.x86_64-linux --apply 'ps: builtins.attrNames ps' --json | jq -r '.[]'); do
        if script_json=$(nix eval --json ".#packages.x86_64-linux.$pkg.updateScript" 2>/dev/null); then
            echo ">>> Updating $pkg (updateScript)"

            # Normalize (string|list|attrset) → args, rewrite store paths to source tree
            cmd=()
            while IFS= read -r arg; do
                cmd+=("${arg/"$flake_store"/"$repo_root"}")
            done < <(echo "$script_json" | jq -r '
                if type == "string" then .
                elif type == "array" then .[]
                elif type == "object" then (.command // [.])[]
                else . end')

            if [ -x "${cmd[0]}" ]; then
                UPDATE_NIX_ATTR_PATH="$pkg" \
                UPDATE_NIX_PNAME="$(nix eval --raw ".#packages.x86_64-linux.$pkg.pname" 2>/dev/null || echo "$pkg")" \
                UPDATE_NIX_OLD_VERSION="$(nix eval --raw ".#packages.x86_64-linux.$pkg.version" 2>/dev/null || true)" \
                "${cmd[@]}" || true
            else
                # updateScript not realized (e.g. inherited nix-update-script), use nix-update directly
                nix-update --flake "$pkg" || true
            fi
        else
            echo ">>> Updating $pkg (nix-update)"
            nix-update --flake "$pkg" || true
        fi
    done
