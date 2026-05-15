#!/bin/bash

set -euo pipefail

desc_file="DESCRIPTION"
cff_file="citation.cff"
update_cff=false

if [[ "${1:-}" == "--update-cff" || "${1:-}" == "-c" ]]; then
    update_cff=true
    shift
fi

if [[ $# -gt 0 ]]; then
    echo "Usage: $0 [--update-cff|-c]"
    exit 1
fi

if [[ ! -f "$desc_file" ]]; then
    echo "Missing $desc_file"
    exit 1
fi

old_line=$(grep -E '^Version:' "$desc_file" || true)
if [[ -z "$old_line" ]]; then
    echo "Could not find Version field in $desc_file"
    exit 1
fi

version_string=$(echo "$old_line" | sed -E 's/^Version:[[:space:]]*//; s/[[:space:]]*$//')

if [[ ! "$version_string" =~ ^([0-9]+)[.-]([0-9]+)[.-]([0-9]+)$ ]]; then
    echo "Unsupported version format in $desc_file: $version_string"
    exit 1
fi

major="${BASH_REMATCH[1]}"
minor="${BASH_REMATCH[2]}"
patch="${BASH_REMATCH[3]}"

old_patch="$patch"
patch=$((patch+1))
version_change_summary="$old_patch->$patch"

new_version_string="$major.$minor.$patch"
echo "==> $new_version_string ($version_change_summary)"

new_line="Version: $new_version_string"
sed -i -E "s/^Version:[[:space:]]*.*$/$new_line/" "$desc_file"

if [[ "$update_cff" == true && -f "$cff_file" ]]; then
    if grep -Eq '^[[:space:]]*version:[[:space:]]*' "$cff_file"; then
        sed -i -E "s|^([[:space:]]*version:[[:space:]]*).*$|\\1$new_version_string|" "$cff_file"
        if ! grep -Eq "^[[:space:]]*version:[[:space:]]*$new_version_string([[:space:]]*(#.*)?)?$" "$cff_file"; then
            echo "Failed to update version in $cff_file"
            exit 1
        fi
    else
        echo "No version field found in $cff_file; skipping"
    fi
fi

git add "$desc_file"
if [[ "$update_cff" == true && -f "$cff_file" ]]; then
    git add "$cff_file"
fi

git commit -m "version bump $new_version_string"
