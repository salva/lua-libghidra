#!/usr/bin/env bash
# MIT Copyright 2026 Salvador Fandiño.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
if grep -nE 'pending operator approval|Neither option is preapproved|pending authority' \
 "$root/docs/PACKAGE-FOUNDATION.md" "$root/docs/PACKAGE-HANDOFF.md"; then
 echo 'FAIL: resolved generator decision still pending' >&2
 exit 1
fi
grep -q 'approved one narrow exception' "$root/docs/SPEC.md"
grep -q 'SDK-consumer builds or installed Lua runtime' "$root/docs/SPEC.md"
echo 'narrow approved SOURCE generator policy consistency PASS'
