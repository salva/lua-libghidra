#!/usr/bin/env bash
# MIT Copyright 2026 Salvador Fandiño.
# Preserve the stale-full-handoff reproducer, without touching the real install.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
prefix=$(realpath "${1:?module prefix}")
data=$(realpath "${2:?documentation prefix}")
work=${3:?fresh disposable work directory}
[[ ! -e $work ]]
mkdir -p "$work/share/doc"
work=$(realpath "$work")
cp -a "$data/share/doc/lua-libghidra" "$work/share/doc/"
copy="$work/share/doc/lua-libghidra"
lua5.4 "$root/tests/installed_documents.lua" "$prefix" "$work" "$root"
for path in docs/API.md docs/M4-FULL.md api/FIELDS.md api/coverage.json; do
 for fault in stale missing; do
  if [[ $fault == stale ]]; then
   printf '\nSTALE FULL HANDOFF RED PROBE\n' >> "$copy/$path"
  else
   rm "$copy/$path"
  fi
  if lua5.4 "$root/tests/installed_documents.lua" "$prefix" "$work" "$root" >"$work/probe.log" 2>&1; then
   echo "false green for $fault $path"; exit 1
  fi
  grep -F "$path" "$work/probe.log"
  cp "$root/$path" "$copy/$path"
 done
done
lua5.4 "$root/tests/installed_documents.lua" "$prefix" "$work" "$root"
printf 'installed full handoff pristine/stale/missing regression PASS\n'
