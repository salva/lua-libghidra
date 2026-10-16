#!/usr/bin/env bash
# MIT Copyright 2026 Salvador Fandiño.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
# Current substantive dependency contract, not historical permission wording.
for member in docs/development/SPEC.md docs/development/TESTING.md docs/NOTICES.md; do
 text=$(tr '\n' ' ' < "$root/$member")
 for fact in 'cpp/embed_specs.py' 'Python >=3.10' 'zlib/XML'; do
  [[ $text == *"$fact"* ]] || { echo "FAIL: $member missing $fact" >&2; exit 1; }
 done
done
spec=$(tr '\n' ' ' < "$root/docs/development/SPEC.md")
for fact in 'unchanged pinned' 'cpp/cmake/EmbedSpecs.cmake' 'SOURCE-only' \
 'no Python bindings' 'project-owned Python tooling/test oracle' \
 'SDK-consumer or installed Lua runtime Python requirement'; do
 [[ $spec == *"$fact"* ]] || { echo "FAIL: SPEC missing $fact" >&2; exit 1; }
done
echo 'SOURCE-only unchanged upstream Python >=3.10 stdlib zlib/XML generator contract PASS'
