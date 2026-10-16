#!/usr/bin/env bash
# MIT Copyright 2026 Salvador Fandiño.
set -euo pipefail
[[ $# == 4 ]] || { echo 'usage: DOCUMENT_ROOT SOURCE_ROOT MANIFEST FRESH_WORK' >&2; exit 1; }
documents=$1 source=$2 manifest=$3 work=$4
for path in "$documents" "$source" "$manifest" "$work"; do
 [[ $path == /* ]] || { echo "absolute path required: $path" >&2; exit 1; }
done
[[ ! -e $work && ! -L $work ]]
mkdir -p "$work"
cp -a "$documents" "$work/snapshot"
cp -a "$work/snapshot" "$work/documents"
check() {
 lua5.4 "$source/tests/installed_documents.lua" installed "$work/documents" "$source" "$manifest"
}
restore() {
 rm -rf -- "$work/documents"
 cp -a "$work/snapshot" "$work/documents"
 check
}
reject() {
 local category=$1 path=$2
 if check >"$work/$category.log" 2>&1; then
  echo "false green: $category $path" >&2; exit 1
 fi
 grep -F "$category:" "$work/$category.log"
 grep -F -- "$path" "$work/$category.log"
 restore
}
# These are probe cases, not a second shipping inventory.
for path in README.md docs/API.md; do grep -Fx "$path" "$manifest"; done
check
rm "$work/documents/docs/API.md"
reject missing-member docs/API.md
printf '\nHarmless freshness probe.\n' >> "$work/documents/README.md"
reject stale-bytes README.md
printf '\n[bad](missing-document.md)\n' >> "$work/documents/README.md"
reject missing-link-target missing-document.md
printf '\n![bad image](missing-image.png)\n' >> "$work/documents/README.md"
reject missing-link-target missing-image.png
printf '\n[bad reference][probe]\n\n[probe]: missing-reference.md\n' >> "$work/documents/README.md"
reject missing-link-target missing-reference.md
printf '\n<a href="docs/API.md">unsupported local HTML</a>\n' >> "$work/documents/README.md"
reject unsupported-markup README.md
printf '\n[bad](docs/API.md#absent-probe-anchor)\n' >> "$work/documents/README.md"
reject missing-fragment absent-probe-anchor
for marker in Saivage 'record:///probe' 'card:///probe' 'work:///probe' '[[card:card-probe]]'; do
 check
 printf '\n<!-- %s -->\n' "$marker" >> "$work/documents/docs/API.md"
 reject forbidden-content docs/API.md
done
printf '\nSaivage was used in creating this project.\n' >> "$work/documents/docs/API.md"
reject invalid-credit docs/API.md
printf '\nSaivage was used in creating this project.\nSaivage was used in creating this project.\n' >> "$work/documents/README.md"
reject invalid-credit README.md
printf 'unlisted\n' > "$work/documents/UNLISTED-PLAN.md"
reject unlisted-document UNLISTED-PLAN.md
printf '\nWORK:///notice-probe\n' >> "$work/documents/docs/evidence/native-notices/engine.txt"
reject forbidden-content docs/evidence/native-notices/engine.txt
# Credit policy must be decided before byte freshness, with no substring exemption.
for variant in valid inline wrapped mislocated no-section fenced; do
 check
 case $variant in
  valid) printf '\n## Acknowledgments\n\nSaivage was used in creating this project.\n' >> "$work/documents/README.md"; category=stale-bytes;;
  inline) printf '\n## Acknowledgments\n\nPrefix Saivage was used in creating this project. suffix\n' >> "$work/documents/README.md"; category=invalid-credit;;
  wrapped) printf '\n## Acknowledgments\n\nSaivage was used in creating this\nproject.\n' >> "$work/documents/README.md"; category=forbidden-content;;
  mislocated) printf '\n## Installation probe\n\nSaivage was used in creating this project.\n' >> "$work/documents/README.md"; category=invalid-credit;;
  no-section) printf '\nSaivage was used in creating this project.\n' >> "$work/documents/README.md"; category=invalid-credit;;
  fenced) printf '\n## Acknowledgments\n\n```\nSaivage was used in creating this project.\n```\n' >> "$work/documents/README.md"; category=invalid-credit;;
 esac
 reject "$category" README.md
done
# Both file and export are disposable; filename policy must win over freshness.
original_manifest=$manifest
for filename in saivage-note.txt SAIVAGE-note.txt card-probe.txt; do
 check
 manifest="$work/filename.manifest"
 cp "$original_manifest" "$manifest"
 printf '%s\n' "$filename" >> "$manifest"
 printf 'Ordinary bytes.\n' > "$work/documents/$filename"
 if check >"$work/filename-$filename.log" 2>&1; then echo "false green: $filename" >&2; exit 1; fi
 grep -F 'forbidden-filename:' "$work/filename-$filename.log"
 grep -F "$filename" "$work/filename-$filename.log"
 manifest=$original_manifest
 restore
done
original_manifest=$manifest
for fault in duplicate escaping absolute blank unterminated; do
 manifest="$work/$fault.manifest"
 cp "$original_manifest" "$manifest"
 case $fault in
  duplicate) head -n1 "$original_manifest" >> "$manifest";;
  escaping) printf '../escape.md\n' >> "$manifest";;
  absolute) printf '/escape.md\n' >> "$manifest";;
  blank) printf '\n' >> "$manifest";;
  unterminated) printf 'incomplete' >> "$manifest";;
 esac
 if check >"$work/manifest-$fault.log" 2>&1; then echo "false green: $fault manifest" >&2; exit 1; fi
 grep -F 'invalid-manifest:' "$work/manifest-$fault.log"
 grep -F "$manifest" "$work/manifest-$fault.log"
 manifest=$original_manifest
 check
done
check
diff -r "$work/snapshot" "$work/documents"
echo 'isolated document probes PASS; snapshot restored'
