#!/usr/bin/env bash
set -euo pipefail

script_dir="$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repository_dir="$(CDPATH='' cd -- "$script_dir/../.." && pwd)"
readonly version_file="$script_dir/version.nix"
readonly latest_url="https://cdn.getmoshi.app/hook/latest/version.txt"
readonly formula_url="https://raw.githubusercontent.com/rjyo/homebrew-moshi/main/Formula/moshi-hook.rb"
readonly script_dir repository_dir

fail() {
  echo "error: $*" >&2
  exit 1
}

for command in awk cp curl grep mktemp mv nix rm sort tail; do
  command -v "$command" >/dev/null || fail "missing required command: $command"
done

temporary_dir="$(mktemp -d)"
restore_version_file=false

cleanup() {
  if $restore_version_file; then
    cp "$temporary_dir/version.nix" "$version_file"
  fi
  rm -rf -- "$temporary_dir"
}
trap cleanup EXIT

latest_version="$(curl --fail --silent --show-error --location "$latest_url")"
latest_version="${latest_version//[[:space:]]/}"
latest_version="${latest_version#v}"
[[ "$latest_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] \
  || fail "invalid latest version: $latest_version"

readonly release_base="https://cdn.getmoshi.app/hook/v${latest_version}"
curl --fail --silent --show-error --location \
  "$release_base/checksums.txt" \
  --output "$temporary_dir/checksums.txt"
curl --fail --silent --show-error --location \
  "$formula_url" \
  --output "$temporary_dir/moshi-hook.rb"

formula_version="$(awk '$1 == "version" { gsub(/"/, "", $2); print $2 }' "$temporary_dir/moshi-hook.rb")"
[[ "$formula_version" == "$latest_version" ]] \
  || fail "Homebrew formula is at $formula_version, CDN is at $latest_version"

checksum_for() {
  local asset="$1"
  local checksum
  checksum="$(awk -v asset="$asset" '$2 == asset { print $1 }' "$temporary_dir/checksums.txt")"
  [[ "$checksum" =~ ^[0-9a-f]{64}$ ]] || fail "missing checksum for $asset"
  grep -Fq "hook/v${latest_version}/${asset}" "$temporary_dir/moshi-hook.rb" \
    || fail "Homebrew formula is missing $asset"
  grep -Fq "sha256 \"${checksum}\"" "$temporary_dir/moshi-hook.rb" \
    || fail "checksum for $asset differs from the Homebrew formula"
  printf '%s' "$checksum"
}

readonly x86_64_asset="moshi-hook_Linux_x86_64.tar.gz"
readonly aarch64_asset="moshi-hook_Linux_arm64.tar.gz"
x86_64_hash="$(nix hash convert --hash-algo sha256 --to sri "$(checksum_for "$x86_64_asset")")"
aarch64_hash="$(nix hash convert --hash-algo sha256 --to sri "$(checksum_for "$aarch64_asset")")"
readonly x86_64_hash aarch64_hash

current_version="$(awk -F\" '/^  version = / { print $2 }' "$version_file")"
[[ "$current_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] \
  || fail "invalid current version: $current_version"
if [[ "$current_version" == "$latest_version" ]]; then
  grep -Fq "hash = \"${x86_64_hash}\";" "$version_file" \
    || fail "stored x86_64 hash differs from the current release"
  grep -Fq "hash = \"${aarch64_hash}\";" "$version_file" \
    || fail "stored aarch64 hash differs from the current release"
  echo "moshi-hook is already at $latest_version"
  exit 0
fi
newest_version="$(printf '%s\n%s\n' "$current_version" "$latest_version" | sort --version-sort | tail -n 1)"
[[ "$newest_version" == "$latest_version" ]] \
  || fail "refusing to downgrade moshi-hook $current_version -> $latest_version"

cp "$version_file" "$temporary_dir/version.nix"
restore_version_file=true

{
  printf '{\n'
  printf '  version = "%s";\n' "$latest_version"
  printf '\n'
  printf '  sources = {\n'
  printf '    x86_64-linux = {\n'
  printf '      asset = "%s";\n' "$x86_64_asset"
  printf '      hash = "%s";\n' "$x86_64_hash"
  printf '    };\n'
  printf '\n'
  printf '    aarch64-linux = {\n'
  printf '      asset = "%s";\n' "$aarch64_asset"
  printf '      hash = "%s";\n' "$aarch64_hash"
  printf '    };\n'
  printf '  };\n'
  printf '}\n'
} >"$temporary_dir/candidate.nix"
mv "$temporary_dir/candidate.nix" "$version_file"

# shellcheck disable=SC2016
package_path="$(
  MOSHI_REPOSITORY_DIR="$repository_dir" nix build \
    --impure \
    --expr '
      let
        repositoryDir = builtins.getEnv "MOSHI_REPOSITORY_DIR";
        flake = builtins.getFlake "path:${repositoryDir}";
        pkgs = import flake.inputs.nixpkgs {
          system = builtins.currentSystem;
          config.allowUnfree = true;
        };
      in
      pkgs.callPackage (builtins.toPath "${repositoryDir}/custom/moshi-hook") { }
    ' \
    --no-link \
    --print-out-paths
)"

"$package_path/bin/moshi-hook" version | grep -Fq "moshi-hook $latest_version" \
  || fail "moshi-hook reports an unexpected version"

restore_version_file=false
echo "updated moshi-hook $current_version -> $latest_version"
