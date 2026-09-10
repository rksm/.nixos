#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

current=$(sed -n 's/^  version = "\(.*\)";/\1/p' default.nix)
tag=$(curl -fsSL https://api.github.com/repos/shaharia-lab/slackcli/releases/latest | jq -er .tag_name)
version=${tag#v}
if [[ "$current" == "$version" ]]; then
  echo "slackcli $version is current."
  exit 0
fi
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]

binary_hash=$(nix store prefetch-file --json \
  "https://github.com/shaharia-lab/slackcli/releases/download/$tag/slackcli-linux" | jq -er .hash)
skill_hash=$(nix store prefetch-file --json --unpack \
  "https://github.com/shaharia-lab/slackcli/archive/refs/tags/$tag.tar.gz" | jq -er .hash)
mapfile -t old_hashes < <(sed -n 's/^    hash = "\(.*\)";/\1/p' default.nix)
[[ ${#old_hashes[@]} == 2 ]]
sed -i \
  -e "s|^  version = .*|  version = \"$version\";|" \
  -e "s|${old_hashes[0]}|$binary_hash|" \
  -e "s|${old_hashes[1]}|$skill_hash|" default.nix
nix build path:. --no-link
if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  echo "VERSION=$version" >> "$GITHUB_OUTPUT"
  echo "UPDATED=true" >> "$GITHUB_OUTPUT"
fi
