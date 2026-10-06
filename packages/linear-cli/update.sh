#!/usr/bin/env bash
# Pin package.nix to the latest linear-cli release.
set -euo pipefail
cd "$(dirname "$0")"

version=$(curl -fsSL https://api.github.com/repos/schpet/linear-cli/releases/latest | jq -r .tag_name)
version=${version#v}
if ! [[ $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid linear-cli version: $version" >&2
  exit 1
fi

sed -i "s/^  version = \".*\";/  version = \"$version\";/" package.nix
for target in x86_64-unknown-linux-gnu aarch64-apple-darwin; do
  url="https://github.com/schpet/linear-cli/releases/download/v$version/linear-$target.tar.xz"
  hash=$(nix store prefetch-file --json "$url" | jq -r .hash)
  # The hash line follows the target line.
  sed -i "/target = \"$target\";/{n;s|hash = \".*\";|hash = \"$hash\";|}" package.nix
done
skill_hash=$(nix flake prefetch --json "github:schpet/linear-cli/v$version" | jq -r .hash)
# The skill source hash follows its tag line.
sed -i "/tag = \"v\${finalAttrs.version}\";/{n;s|hash = \".*\";|hash = \"$skill_hash\";|}" package.nix
echo "linear-cli $version"
