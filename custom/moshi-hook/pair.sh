#!/usr/bin/env bash
set -euo pipefail

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

command -v moshi-hook >/dev/null \
  || fail "moshi-hook is not installed. Run 'just switch' first."
systemctl --user cat moshi-hook.service >/dev/null 2>&1 \
  || fail "The Moshi service is not installed. Run 'just switch' first."

printf '%s\n' \
  '1. Open Moshi on your phone.' \
  '2. Open Settings, then Hooks.' \
  '3. Copy the pairing token.'
read -r -s -p '4. Paste the token: ' token
printf '\n'
[ -n "$token" ] || fail 'The token cannot be empty.'

moshi-hook pair --token "$token"
unset token
systemctl --user restart moshi-hook.service

printf '\nPairing complete. Current status:\n'
moshi-hook status
