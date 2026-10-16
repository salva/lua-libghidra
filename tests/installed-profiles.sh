#!/usr/bin/env bash
# MIT Copyright 2026 Salvador Fandiño.
# Ordinary-user profile permissions; disposable artifacts below caller work root.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
prefix=$(realpath "${1:?installed prefix}")
work=${2:?fresh work directory}
[[ $(id -u) != 0 && ! -e $work ]]
mkdir -p "$work"
work=$(realpath "$work")
mkdir "$work/cwd"
cd "$work/cwd"
external=$(realpath "${3:?external specs tree}")
[[ -d $external/Ghidra/Processors ]]
trap 'chmod -R u+rwX "$work"' EXIT
run() {
 local label=$1 spec=$2 home=$3 expected=$4
 printf '\nPROFILE %s explicit-root=%q HOME=%q expected=%s\n' "$label" "$spec" "$home" "$expected"
 HOME="$home" LLG_PROFILE_ROOT="$spec" LLG_PROFILE_EXPECT="$expected" \
  lua5.4 "$root/tests/installed_profiles.lua" "$prefix" "$root"
}
mkdir "$work/external-home" "$work/unreadable" "$work/cold-denied"
chmod 000 "$work/unreadable"
chmod a-w "$work/cold-denied"
[[ ! -r $work/unreadable && ! -w $work/cold-denied ]]
run external-valid "$external" "$work/external-home" success
run external-missing "$work/missing" "$work/external-home" failure
run external-unreadable "$work/unreadable" "$work/external-home" failure
[[ ! -e $work/external-home/.ghidracpp ]]
printf 'external profiles bypassed HOME extraction PASS\n'
mkdir "$work/embedded-home"
run embedded-cold '' "$work/embedded-home" success
[[ $(find "$work/embedded-home" -name .complete | wc -l) == 1 ]]
find "$work/embedded-home" -type f -printf '%P %T@ %s\n' | sort > "$work/before"
find "$work/embedded-home" -type f -exec sha256sum {} + | sort > "$work/hashes-before"
run embedded-warm '' "$work/embedded-home" success
chmod -R a-w "$work/embedded-home"
[[ ! -w $work/embedded-home ]]
run embedded-warm-unwritable '' "$work/embedded-home" success
find "$work/embedded-home" -type f -printf '%P %T@ %s\n' | sort > "$work/after"
find "$work/embedded-home" -type f -exec sha256sum {} + | sort > "$work/hashes-after"
cmp "$work/before" "$work/after"
cmp "$work/hashes-before" "$work/hashes-after"
run embedded-cold-unwritable '' "$work/cold-denied" failure
printf 'installed constructor/cache matrix and unchanged warm cache PASS\n'
