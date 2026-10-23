#!/usr/bin/env bash
# Pin package.nix to the latest ramp-cli release.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
repo=https://github.com/ramp-public/ramp-cli

current=$(sed -n 's/^  version = "\(.*\)";/\1/p' package.nix)
# /releases/latest redirects to /releases/tag/v<version>.
latest=$(curl -sfI "$repo/releases/latest" | sed -n 's|^location: .*/tag/v\([^[:space:]]*\).*|\1|ip')

if [ -z "$latest" ]; then
  echo "could not determine the latest release" >&2
  exit 1
fi
if [ "$current" = "$latest" ]; then
  echo "ramp-cli is up to date ($current)"
  exit 0
fi

# Upstream publishes a sha256 file next to every asset. Fetch all of them
# before editing so a missing asset leaves package.nix untouched.
edits=(-e "s/^  version = \"$current\";/  version = \"$latest\";/")
for asset in $(sed -n 's/^ *name = "\(.*\)";/\1/p' package.nix); do
  hex=$(curl -sfL "$repo/releases/download/v$latest/ramp-$asset.tar.gz.sha256" | cut -d' ' -f1)
  sri=$(nix hash convert --hash-algo sha256 --to sri "$hex")
  edits+=(-e "/name = \"$asset\";/{n;s|hash = \"[^\"]*\"|hash = \"$sri\"|}")
done
sed -i "${edits[@]}" package.nix

echo "updated ramp-cli $current -> $latest"
