# Website tooling (source only)

The static website consumes the sole `cmake/PackageDocuments.cmake` export:
all selected Markdown pages, exact legal/lock/notice assets and exactly two Lua
examples. No separate manual inventory, native build, engine execution, Python,
Java, remote assets or JavaScript is required for generation.

## Prerequisites and explicit preparation

Use Lua5.4, CMake>=3.26, POSIX shell, GNU find/coreutils, and the exact Pandoc
version in `toolchain.lock.json`. Run from checkout root. Explicit network-enabled
preparation (curl/tar required) is separate from all offline build/check commands:

```sh
sh site/prepare-toolchain.sh "$TOOLS"
PANDOC="$TOOLS/pandoc-3.6.4/bin/pandoc"
export LLG_SITE_PANDOC="$PANDOC"
```

TOOLS must be an absolute fresh directory. The actual inspected release archive
SHA256 is pinned and verified before extraction; executable version is checked.
The old release exposes no signed/checksum asset: this is the observed archive
hash, not a claimed signed upstream attestation. License and upstream COPYRIGHT
URLs are in the lock; no converter is distributed in the manual/runtime.

## Offline build and independent check

Create output/report parents first; output, report and report.work must be fresh.
Use absolute paths with no symlink ancestors; reports/intermediates stay outside
the site output. A failed operation retains work for diagnosis; retry with new paths.

```sh
lua5.4 scripts/build-site.lua --pandoc "$PANDOC" \
  --baseurl /lua-libghidra --origin https://salva.github.io \
  --output "$WORK/preview/lua-libghidra" --report "$WORK/build.json"
lua5.4 scripts/check-site.lua --root "$WORK/preview/lua-libghidra" \
  --baseurl /lua-libghidra --report "$WORK/build.json" --source .
lua5.4 tests/site_contract.lua --work "$WORK/probes" --pandoc "$PANDOC"
lua5.4 tests/site_render.lua --work "$WORK/renders" --pandoc "$PANDOC"
```

The checker uses LLG_SITE_PANDOC (or an exact matching pandoc on PATH), never a
report-selected executable. It independently regenerates every current selected
Markdown page and compares exact HTML. Editable report hashes alone cannot certify
fresh output. Verification is offline but now intentionally requires the converter;
it retains fresh `.check-*` work beside the report. Source/graph/content, actual
IDs/URLs, exact membership, regular files, downloads/example text and current
source/tooling bytes are also checked. This is reproducibility checking against
trusted current tooling, not a signature or defense against compromised source/tools.

The contract exercises disposable real-artifact attacks including recomputed
report hashes and stale source snapshots. The render test covers project/empty
base, deterministic double renders, generated C++ type display and presentation
semantics. Actual examples have separate installed-Lua runtime qualification;
a rendered script is not runtime evidence. Shared heading IDs come from the
package helper; unsupported markup fails rather than bypassing graph validation.

## Preview and publication boundaries

Optional BusyBox httpd preview serves the parent to retain project-path URLs:

```sh
sh scripts/preview-site.sh --root "$WORK/preview" --bind 127.0.0.1 --port 8088
```

It runs in foreground until Ctrl-C; absent BusyBox fails clearly. Browser checks
must cover narrow/desktop layout, zoom, keyboard/skip/nav/TOC/focus, local wide
code/table scrolling, contrast and the installation-to-reference reader journey.
Bounded observations are not a complete accessibility audit.

Prepared workflows use ubuntu-24.04, full-SHA actions, read-only PR/main checks
and no persisted checkout credentials. Publication is separately manual/main-only;
only deploy has Pages/OIDC rights, github-pages environment and serialization.
Only that run's checked output tar is uploaded. No configure-pages/auto-enablement,
PR secrets or pull_request_target. Local tests/YAML preparation do not authorize
push, dispatch, repository settings, Pages enablement or deployment, and imply
no live URL or new distribution permission. Independent acceptance is separate.
