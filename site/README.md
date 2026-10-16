# Website tooling (source only)

The website consumes `cmake/PackageDocuments.cmake`, not a separate manual list.
Lua 5.4, CMake >=3.26, POSIX shell, GNU find/coreutils and the locked Pandoc
executable are required. Native libraries, Python, Java, network access and
example execution are not build prerequisites. The executable examples have a
separate installed-runtime qualification lane.

## Current integration boundary

These tools are under implementation. Export/routing/path/HTML primitives have
focused regression coverage. **Rendering is not qualified yet**: the package
owner must first expose its existing heading allocator as
`package_documents.heading_ids()`, returning a stateful function that accepts
heading text and returns the current helper's slug with duplicate suffixes.
`site/links.lua` explicitly refuses an independent approximation. No package-owned
file is changed by the site tools. Full artifact mutation tests, browser/reader
observations remain required before acceptance. CI files are preparation only.

## Explicit tool preparation

`site/toolchain.lock.json` records the selected Linux AMD64 Pandoc3.6.4 release
archive, observed SHA256 and upstream copyright/license location. The release
archive was downloaded from that exact HTTPS URL; its bytes were hashed, checked
against the recorded digest before extraction, and the executable reports
`pandoc 3.6.4`. The release API exposes no digest for this older asset and there
is no `sha256sums.txt` release asset (that attempted URL returned404). The lock
therefore records the actually inspected archive, not a claimed upstream signed
checksum. Review the upstream COPYRIGHT for exceptions; no converter is shipped
in the manual or installed runtime.

Prepare separately in a fresh caller-owned work directory using
`sh site/prepare-toolchain.sh "$TOOLS"`. It consumes the lock and verifies the
archive before extraction. It needs curl and tar and is not part of offline
build/check. Equivalent explicit steps are:

```sh
URL=https://github.com/jgm/pandoc/releases/download/3.6.4/pandoc-3.6.4-linux-amd64.tar.gz
curl -fL "$URL" -o "$TOOLS/pandoc.tar.gz"
printf '%s  %s\n' 5def6e1ff535e397becce292ee97767a947306150b9fb1488003b67ac3417c5e "$TOOLS/pandoc.tar.gz" | sha256sum -c -
tar -xzf "$TOOLS/pandoc.tar.gz" -C "$TOOLS"
PANDOC="$TOOLS/pandoc-3.6.4/bin/pandoc"
"$PANDOC" --version
```

Use absolute paths for PANDOC, output, report and work. Output/report parents must
already exist and must not contain symlinks. Output, report and the report's
`.work` sibling must not exist; failed work is retained for diagnosis and a retry
uses new paths. Run from the checkout root. Reports and intermediate exports stay
outside the final artifact. No command below fetches dependencies:

```sh
cmake -DLLG_DOCUMENT_EXPORT_DIR="$WORK/export" -P site/export-documents.cmake
lua5.4 scripts/build-site.lua --pandoc "$PANDOC" \
  --baseurl /lua-libghidra --origin https://salva.github.io \
  --output "$WORK/preview/lua-libghidra" --report "$WORK/build.json"
lua5.4 scripts/check-site.lua --root "$WORK/preview/lua-libghidra" \
  --baseurl /lua-libghidra --report "$WORK/build.json" --source .
lua5.4 tests/site_contract.lua --work "$WORK/probes" --pandoc "$PANDOC"
```

The contract test deliberately exits nonzero while integration coverage remains
unfinished; a passing foundation message is not website acceptance. Build checks
the executable's exact version and selected source graph before creating output.
A matching explicitly supplied local executable is allowed. The checker inspects
actual regular files, IDs, URLs and bytes against current sources as well as the
report; it does not execute a converter or examples. Full source-freshness
qualification still needs the planned mutation tests and rendered reproducibility
checks, not just these entrypoints' presence.

## Preview and publication boundaries

Optional preview requires BusyBox with its httpd applet. Serve the parent directory
so project-path URLs remain correct:

```sh
sh scripts/preview-site.sh --root "$WORK/preview" --bind 127.0.0.1 --port 8088
```

It runs in the foreground; Ctrl-C stops it. Missing BusyBox fails explicitly; it
is not replaced by a Python server. Check both the project base and an empty-base
fresh render, deterministic double rendering and actual desktop/360px/zoom/
keyboard/reader behavior before acceptance. Do not claim a full accessibility
audit from bounded observations.

The two prepared workflows use ubuntu-24.04, full-SHA actions and read-only
build jobs. `site-check.yml` handles PR/main push; `site-publish.yml` is manual,
main-only with only the deploy job holding Pages/OIDC rights, a github-pages
environment and serialized publication. It uploads only a checked output tar
from that run. The upload is pinned directly instead of using the Pages upload
composite, whose reviewed revision invokes a floating upload-artifact@v4. The
public repository API reports `main` as the default branch. YAML parsing and
permission/pin assertions passed locally; no remote run or deployment occurred.
The contract test remains red, so these workflows cannot yet publish successfully. Preparing local tools grants no permission to push,
dispatch, enable Pages, alter repository settings or deploy. There is no live-site
claim and no distribution permission implied by rendering exact legal assets.
