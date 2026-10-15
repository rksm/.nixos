#!/usr/bin/env bash
# Pin package.nix to the latest cf release on npm and regenerate its lockfile.
# Also pin the cf-cli skill, which follows commits instead of cf releases.
set -euo pipefail
cd "$(dirname "$0")"

# Pin the last commit that changed the skill, so changes to other skills in
# that repository do not rebuild cf.
skill_rev=$(curl -fsSL "https://api.github.com/repos/cloudflare/skills/commits?path=skills/cf-cli&per_page=1" | jq -r '.[0].sha')
if ! [[ $skill_rev =~ ^[0-9a-f]{40}$ ]]; then
  echo "Invalid cf-cli skill commit: $skill_rev" >&2
  exit 1
fi
skill_hash=$(nix flake prefetch --json "github:cloudflare/skills/$skill_rev" | jq -r .hash)
# The skill hash line follows its rev line.
sed -i \
  -e "s/^    rev = \".*\";/    rev = \"$skill_rev\";/" \
  -e "/^    rev = /{n;s|hash = .*;|hash = \"$skill_hash\";|}" \
  package.nix
echo "cf-cli skill $skill_rev"

current=$(sed -n 's/^  version = "\(.*\)";/\1/p' package.nix)
version=$(curl -fsSL https://registry.npmjs.org/cf/latest | jq -r .version)
if ! [[ $version =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?$ ]]; then
  echo "Invalid cf version: $version" >&2
  exit 1
fi
# A fresh lockfile can pick up newer transitive dependencies, so only
# regenerate it for a new release.
if [ "$version" = "$current" ]; then
  echo "cf $version"
  exit 0
fi

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
src=$(nix store prefetch-file --json "https://registry.npmjs.org/cf/-/cf-$version.tgz")
# package.nix drops the same devDependencies before npm ci.
tar -xzOf "$(jq -r .storePath <<<"$src")" package/package.json |
  jq 'del(.devDependencies)' >"$work/package.json"
(cd "$work" && npm install --package-lock-only --ignore-scripts)
deps_hash=$(prefetch-npm-deps "$work/package-lock.json")

cp "$work/package-lock.json" package-lock.json
# The tarball hash line follows its registry URL line.
sed -i \
  -e "s/^  version = \".*\";/  version = \"$version\";/" \
  -e "/registry\.npmjs\.org/{n;s|hash = .*;|hash = \"$(jq -r .hash <<<"$src")\";|}" \
  -e "s|^  npmDepsHash = .*;|  npmDepsHash = \"$deps_hash\";|" \
  package.nix
echo "cf $version"
