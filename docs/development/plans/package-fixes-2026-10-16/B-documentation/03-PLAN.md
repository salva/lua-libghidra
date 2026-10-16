# Package documentation — implementation plan

Draft awaiting fresh independent review. Baseline `4903eb7`, 2026-10-16.
Future authorized scope: F04–F07, F11–F13 only. This plan does not authorize
implementation, commits, submission, publication or runtime control now.

## 1. Preparation and dependencies

Read project/workspace guidance and apply the project validation skill when
implementation is authorized. Record the actual implementation baseline and
existing worktree changes. Preserve hashes of the three root native locks,
`api/history/coverage-m3.json`, `api/runtime-evidence-m3.json`, retained notice
texts, M0 license TSV and raw evidence. No dependency source changes are required.

Accept A's final facade reopen/Shutdown and Lua ABI dispositions before freezing
API signatures and supported-host text. Ask C for explicit integration selection
and fixture invocation details for example checks. These are dependencies, not
permission to implement A/C changes here. Other docs work can proceed separately.

C must propagate the selected build's `package-documents.txt` through both
pristine and shell-probe calls using the exact interfaces in section 5 below.
B owns the Lua checker and shell mutation loop; C owns the qualification-driver
call sites/full-reduced selection. Deliver the checker and caller change together
for integration; do not retain a legacy positional adapter. The website owner
receives the maintained source paths plus the same manifest, not a second manual
or a request to reorganize source for a site.

Before rewriting pages, extract a working content checklist of accepted grammar,
limitations, provenance and obligations using section 4 of `02-DESIGN.md`.
Resolve contradictory current claims against real exports/converters and agreed
contracts, not whichever milestone report sounds most recent. Do not create a
new permanent duplicate normative ledger merely to track this editorial work.

## 2. Author the compact current layer

Rewrite README, docs/EXAMPLES, docs/API and docs/NOTICES in place. Add only the
source-only `docs/development/README.md` index. Follow the exact disposition map
in the design: no blanket moves, redirects or historical rewrites. Correct the
maintained developer DESIGN map; SPEC/COVERAGE defer current grammar to API.
Classify PLAN and milestone/qualification reports in the index as dated records.

The user guide must define supported prerequisites explicitly: Ubuntu 24.04
amd64/Linux x86-64, C++20/GCC 13 qualified compiler, CMake >=3.26, Ninja,
pkg-config and compatible Lua 5.4 development/host configuration, LuaRocks 3.x
for rock routes, shared BFD/sframe/zstd/zlib development closure matching the
locks, and preparation tools GNU tar/unzip/sha256sum/patch/realpath/core utilities
(curl only for explicit online preparation). Source generator Python >=3.10
stdlib zlib/XML is a build-only exception. Avoid claiming an ambient package
manager command retrieves the historical locked versions today.

### Recipe skeleton to verify, then publish

The following uses existing command interfaces, not execution evidence. It is
intended to be copied into the maintained guide with explanation and final A ABI
selection options if needed. Run from an actual source checkout. Use a new WORK
per independent route; source/SDK are mutually exclusive selections.

```sh
SOURCE=$(pwd -P)
WORK=$(mktemp -d "$HOME/lua-libghidra.XXXXXX")
ARCHIVES="$WORK/archives"
INPUTS="$WORK/inputs"
PREFIX="$WORK/prefix"
ROCKS="$WORK/rocks"
mkdir -p "$ARCHIVES"
# Explicit network preparation; hashes checked before extraction.
lua5.4 scripts/prepare-native.lua --archives "$ARCHIVES" --output "$INPUTS" \
  --profile bfd-sleigh-target-autodetect
cmake -S "$SOURCE" -B "$WORK/cmake-source" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF \
  -DLIBGHIDRA_USE_SDK=OFF -DNATIVE_INPUT_ROOT="$INPUTS" \
  -DFETCHCONTENT_FULLY_DISCONNECTED=ON -DCMAKE_INSTALL_PREFIX="$PREFIX"
cmake --build "$WORK/cmake-source" --parallel 4
cmake --install "$WORK/cmake-source"
export LUA_PATH="$PREFIX/share/lua/5.4/?.lua;$PREFIX/share/lua/5.4/?/init.lua;;"
export LUA_CPATH="$PREFIX/lib/lua/5.4/?.so;;"
lua5.4 -e 'assert(require("libghidra")); assert(require("libghidra.lowlevel"))'
```

Offline alternative: supply an existing verified archive directory, use a fresh
INPUTS path and append `--offline` to preparation. Do not use the newly created
empty ARCHIVES directory and claim offline success. For clean source LuaRocks:

```sh
unset LLG_SDK_PREFIX
LLG_BUILD_DIR="$WORK/rock-source-build" LLG_INPUT_ROOT="$INPUTS" \
  luarocks --lua-version=5.4 --tree="$ROCKS" make --deps-mode=none --no-manifest
unset LUA_PATH LUA_CPATH
eval "$(luarocks --lua-version=5.4 --tree="$ROCKS" path)"
lua5.4 -e 'assert(require("libghidra")); assert(require("libghidra.lowlevel"))'
```

For SDK CMake, define `SDK` as the absolute existing qualified local SDK path;
check it is nonempty, absolute and contains the required CMake package files.
Configure in a fresh `$WORK/cmake-sdk`, replace source selector with
`-DLIBGHIDRA_USE_SDK=ON -DCMAKE_PREFIX_PATH="$SDK"`, omit NATIVE_INPUT_ROOT and
use a distinct prefix. Keep the same build/install/search-path/load commands.
For SDK LuaRocks, unset `LLG_INPUT_ROOT`, set `LLG_SDK_PREFIX="$SDK"` and fresh
`LLG_BUILD_DIR`/tree; use the same rock make and path commands. Never set both
input selectors. Do not supply a guessed SDK download URL or call an arbitrary
SDK qualified. Define caller absolute inputs before use, with useful early
errors, in the final published recipe.

Record recipe executions from an ordinary non-root shell with Saivage variables
absent; fresh cwd outside the checkout for load/example execution; both source
and SDK paths when their actual inputs are available. If an input is unavailable,
record that route unverified, do not silently substitute a cached unrelated run.
The final guide must distinguish installed paths from source-checkout commands.

## 3. Own-input example and documentation reconciliation

Add `examples/decompile.lua` accepting positional `BINARY ADDRESS LANGUAGE_ID
COMPILER_SPEC_ID [GHIDRA_ROOT]`. Require the first four; default spec root to
empty for embedded specs. Validate exact UInt64 through the public helper before
open; describe a suitable symbol-address extraction command such as
`nm -n --defined-only /absolute/path/to/binary` for an unstripped supported ELF,
and tell the user to choose a known function's mapped virtual address, never a
file offset. The example is not a general safe address scanner.

Make hexadecimal copy/paste explicit: `nm` prints unprefixed hexadecimal, so
prefix the selected address with `0x`. For example, a displayed
`0000000000401106` becomes argument `0x0000000000401106` (equivalently `0x401106`).
A bare all-digit string is decimal to `u64`, not automatically hexadecimal.

Use the real two-surface API and Lua 5.4 close scope, handle open/decompile errors
without assertions that erase structured diagnostics, print outcome flags/error
message and pseudocode, and return nonzero for a failed/incomplete/fallback
decompilation without conflating that with missing response. Normal complete
nonfallback output returns zero. Do not call os.exit while an owner is live:
return status from the close-scoped function, then exit. Cover malformed address,
missing file and a known positive; avoid known crash-address probes. Explain
that process crashes cannot be caught/repaired by deterministic Lua cleanup.

Install it beside existing fixture examples in Binding.cmake. Guide uses the
installed path for the chosen prefix (for LuaRocks, explicitly identify the
versioned package data prefix rather than assuming top-level tree/share).
Existing fixture demos keep their source-fixture prerequisite; no script is
relabeled as standalone without actually removing that dependency. Validate the
new example against real supported authored input without requiring its manifest
in the executable interface. No new public API or fixture generator is needed.

## 4. Field generation correction

Modify `scripts/inventory_source.lua` and, where needed, the assembled ledger
classification/renderer owner. Inspect actual enum converters and all native
type categories present in the pinned ledger. Add int32 and explicit enum/model
classification; preserve optional/vector recursion and excluded-only scope.
Update `scripts/render-fields.lua` to link included records/enums and API anchors,
provide actual public enum names/fallback, and remove installed links to M3/M4/
SPEC. Keep output at `api/FIELDS.md`. Update `api/README.md` commands/authority.

Add a focused Lua rendering/representation test (new file, suggested
`tests/tooling_fields.lua`) and wire it into `scripts/check-tooling.lua`.
Its checks must distinguish int32, uint64, nested optional/array records, byte
vectors, a real converted enum and an excluded-only type, with bad category/name
inputs failing clearly. Cross-check expected actual Lua types against existing
converter/runtime tests; add a narrow real `get_revision` field observation only
if existing tests do not establish the representation. Source default-zero
facts alone must not be presented as a populated producer qualification.

From checkout root, with actual pinned source and a fresh work directory:

```sh
lua5.4 scripts/inventory-api.lua "$PINNED_SOURCE" "$FRESH_JSON" --coverage
lua5.4 scripts/check-tooling.lua "$PINNED_SOURCE" "$FRESH_WORK"
# Review FRESH_JSON semantic diff; replace only current api/coverage.json.
lua5.4 scripts/render-fields.lua
lua5.4 scripts/render-fields.lua --check
```

Define PINNED_SOURCE/FRESH_JSON/FRESH_WORK to caller-owned absolute paths;
FRESH_JSON/FRESH_WORK must not already exist. Generation refuses overwrites.
Use normal reviewed file replacement only after checking the candidate. All
source body hashes, evidence status and immutable historical digest chains must
remain intact. Do not update golden historical bytes to make a test pass.

## 5. Notices correction and manifest installation

Correct GCC runtime/component rows and split both zlib identities. Retrieve the
already identified pinned engine header from a verified prepared tree or exact
URL, verify full-header SHA256
`5b3dc1c20e9b852ec1ef77f598c89129bae58de98d3773f91a4fc3071dd8cabf`, then extract
the complete notice block without line-ending/whitespace edits into future
`docs/evidence/native-notices/engine-zlib.txt`. Record URL, header digest, exact
extract boundaries and extract digest; compare extracted bytes independently.
Do not fetch floating master, substitute system zlib text or rewrite other
notices. Exact URL is
`https://raw.githubusercontent.com/NationalSecurityAgency/ghidra/2035b8153afaf7ce2edde24a2c80b62bbcf5127f/Ghidra/Features/Decompiler/src/decompile/zlib/zlib.h`.

Introduce `cmake/PackageDocuments.cmake` with the design's exact explicit list.
Replace `install(DIRECTORY docs api)` with per-file installation retaining relative
paths. Export `${CMAKE_BINARY_DIR}/package-documents.txt` directly from
`LLG_PACKAGE_DOCUMENTS` during configure: one relative path per line, final
newline, no comments/blank lines. Do not check in or independently edit this
projection. Accept only this simple list syntax rather than parsing arbitrary
CMake in Lua. Inspect
all install directives for unlisted documentation, including rock deployment.

Rework `tests/installed_documents.lua` to consume the exported list and explicit
document root, checking all files, not just the old hardcoded subset. Remove
shipping assertions for historical approval/process IDs and review sentences;
retain substantive safety/scope/Python/notices checks in their current authority.
Avoid dependence on exact prose line wrapping. Share graph/content checking in a
small Lua module used for source and installed checks, not duplicated lists.

Check actual local Markdown link/anchor forms in maintained docs, reference links,
images and fragment-only references; flag unsupported local markup. Mutation
tests on a disposable copy remove a destination, break an anchor, alter installed
bytes, add an unlisted plan, inject a harness URI/name and misuse/duplicate the
credit. Require useful file/target diagnostics. Raw exact notices are included
in scanning and freshness; an actual content conflict blocks acceptance pending
explicit resolution, never authorizes license redaction or broad exemptions.

Test CMake and LuaRocks clean installs (source/SDK matrix where real inputs are
available), using LuaRocks's actual versioned data root. An existing old prefix
can retain recursively installed history after upgrade; do not report it clean
based only on new manifest presence. Prefer clean prefixes for qualification.
Document bounded cleanup of the previous doc subtree for users intentionally
replacing that old install; no automatic destructive cleanup of arbitrary prefix
content belongs in this change.

### Exact checker and caller handoff

Replace the old positional checker/shell interfaces, without compatibility
fallback, with these required arguments (all paths absolute):

```text
lua5.4 tests/installed_documents.lua source SOURCE_ROOT MANIFEST
lua5.4 tests/installed_documents.lua installed DOCUMENT_ROOT SOURCE_ROOT MANIFEST
bash tests/installed-documents.sh DOCUMENT_ROOT SOURCE_ROOT MANIFEST FRESH_WORK
```

DOCUMENT_ROOT names the doc directory itself, not a module/data prefix. MANIFEST
is the configure export belonging to the build that produced this install.
Source mode checks the selected source files/graph/content; installed mode checks
exact membership, graph/content and then byte freshness against SOURCE_ROOT.
Source mode permits unselected developer/history files in the checkout. Both
modes reject missing/malformed manifest input rather than inferring a build.

B updates every checker call inside `tests/installed-documents.sh`. The shell
requires nonexistent FRESH_WORK, creates an untouched snapshot and a mutable
`FRESH_WORK/documents` copy of DOCUMENT_ROOT, and passes SOURCE_ROOT/MANIFEST
unchanged on every invocation. Its pristine, expected-failure and restored calls
all have this exact shape:

```sh
lua5.4 "$source/tests/installed_documents.lua" installed \
  "$work/documents" "$source" "$manifest"
```

Replace the existing loop over API/M4/FIELDS/coverage with manifest-member
mutations: select/assert current prose members for link/fragment/content probes
and members from the manifest for missing/stale probes. Never mutate or restore
M4-FULL/coverage.json as shipped files. Named probe targets are test cases, not
a second list used for installation or completeness. Each isolated probe has a
pristine-before check, one mutation, expected rejection, snapshot restoration
(or removal of the deliberately unlisted file), and pristine-after check. End
with another pristine check. Preserve logs identifying the mutated file/target.

Diagnose membership/missing files first, local graph/fragment/content violations
next, stale bytes last. Require an error category and implicated path/target for
each probe, so a general freshness failure cannot pass a link/content test:

| Probe | Mutation and expected diagnostic |
| --- | --- |
| Missing | Remove a listed file; `missing-member` and its path |
| Freshness | Harmless prose edit leaving links/content valid; `stale-bytes` and path |
| Local destination | Append a Markdown link to a nonexistent local target in a listed prose page; `missing-link-target` and target |
| Fragment | Link to an existing listed page with a nonexistent heading fragment; `missing-fragment` and fragment/target |
| Content | Inject forbidden name or card URI into listed prose; `forbidden-content` and path |
| Credit | Put the exact permitted credit in the wrong file, or duplicate it in README (insert twice even if original has none); `invalid-credit` and path |
| Membership | Add an unlisted file in the copy; `unlisted-document` and path |

For all mutations the real install, current source and manifest are unchanged.
No retained artifact is used as a mutable baseline. Separate assertions cover
invalid/duplicate/escaping manifest entries on disposable manifest copies.

C updates the qualification driver's existing pristine and probe call sites
(baseline lines 43 and 46). For its selected absolute build/prefix/source:

```sh
manifest="$build/package-documents.txt"
document_root="$prefix/share/doc/lua-libghidra"
lua5.4 "$root/tests/installed_documents.lua" source "$root" "$manifest"
lua5.4 "$root/tests/installed_documents.lua" installed \
  "$document_root" "$root" "$manifest"
# In full mode only; documents is C's newly allocated work child.
bash "$root/tests/installed-documents.sh" \
  "$document_root" "$root" "$manifest" "$documents/probes"
```

Both source and installed pristine checks run in reduced/full mode; full-only
probe omission is reported under C's selection contract. No independent manifest
selector/cache option or new test-selection system is needed. Reconfigure the
selected build to obtain its current export before running checks. C also updates
its child-interface documentation to exactly match this handoff. B's caller
contract does not expand `tests/package-foundation.sh` into a full integration
driver; LuaRocks doc checks are explicit route verification below.

### Concrete future validation commands

These commands are for the authorized implementation, not reported passes. From
the source/CMake recipe above, SOURCE/WORK/PREFIX are already absolute:

```sh
BUILD="$WORK/cmake-source"
MANIFEST="$BUILD/package-documents.txt"
DOCUMENT_ROOT="$PREFIX/share/doc/lua-libghidra"
lua5.4 "$SOURCE/tests/installed_documents.lua" source "$SOURCE" "$MANIFEST"
lua5.4 "$SOURCE/tests/installed_documents.lua" installed \
  "$DOCUMENT_ROOT" "$SOURCE" "$MANIFEST"
bash "$SOURCE/tests/installed-documents.sh" \
  "$DOCUMENT_ROOT" "$SOURCE" "$MANIFEST" "$WORK/cmake-source-doc-probes"
```

For the source LuaRocks recipe, use its own build export and the versioned
package-data prefix. With the baseline package/version and ordinary LuaRocks 5.4
tree layout, the explicit inputs are below. Confirm ROCK_PACKAGE_PREFIX equals
the actual `$(PREFIX)` used by the rock driver/CMake install (inspect that build's
CMakeCache/install log); for a configured different layout, set that exact prefix
explicitly before these checks. Do not search for or silently select another tree.

```sh
ROCK_BUILD="$WORK/rock-source-build"
ROCK_MANIFEST="$ROCK_BUILD/package-documents.txt"
ROCK_PACKAGE_PREFIX="$ROCKS/lib/luarocks/rocks-5.4/lua-libghidra/scm-1"
ROCK_DOCUMENT_ROOT="$ROCK_PACKAGE_PREFIX/share/doc/lua-libghidra"
test -f "$ROCK_MANIFEST"
test -d "$ROCK_DOCUMENT_ROOT"
lua5.4 "$SOURCE/tests/installed_documents.lua" source "$SOURCE" "$ROCK_MANIFEST"
lua5.4 "$SOURCE/tests/installed_documents.lua" installed \
  "$ROCK_DOCUMENT_ROOT" "$SOURCE" "$ROCK_MANIFEST"
bash "$SOURCE/tests/installed-documents.sh" \
  "$ROCK_DOCUMENT_ROOT" "$SOURCE" "$ROCK_MANIFEST" "$WORK/rock-source-doc-probes"
```

Repeat the same calls for SDK CMake using its configured `$WORK/cmake-sdk` build
and distinct SDK wrapper-install prefix; for SDK LuaRocks use the exact fresh
LLG_BUILD_DIR and tree/package prefix chosen for that route. Allocate new probe
work directories each time. Record each concrete command/path; do not count a
source-route manifest check as validation of the SDK route's install.

Historical-baggage recheck: this replaces the old fixed shipping assertions and
excluded-file restoration, not supplements them. CMake owns the single list;
the text export and shell probe targets introduce neither a second policy nor a
legacy adapter. The website handoff is read-only reuse of the maintained source
layer, not grounds for extra native-package pages or install lists.

## 6. Completion, validation matrix and bounded rollback

Once authorized implementation passes its checks, report exact modified paths,
commands, profiles, remaining unavailable inputs and actual results. Independent
review is still required; neither a static audit nor this draft establishes a
pass. Keep external-link availability separate from local graph closure. No new
release/legal clearance or source-delivery claim follows from doc tests.

| Area | Required check | Pass condition / bounded claim |
| --- | --- | --- |
| Preservation | Compare before/after hashes for root locks, historical ledger/index, raw evidence and existing exact notices | Unchanged bytes/locations; only new zlib extract and current generated outputs added/changed as planned |
| User journey | Read guide in order, run published routes with ordinary writable paths, no harness variables | Installation → require → own-input example → diagnostics/close works for tested supported route; unavailable routes explicitly unverified |
| Native example | Real known supported ELF/address, both external and embedded spec modes where available; malformed address/missing-file negative | Correct flags/pseudocode/error distinction and owner cleanup; no arbitrary-address safety claim |
| API/profile | Reconcile both exported surfaces with A and current converters; compare grammar extracted from M3/M4 | No undocumented existing methods, invented convenience, missing return envelope or stale compiler/runtime identity |
| Limitations | Editorial checklist against design section 4 | All effective safety/persistence/loader/producer/iteration limits retained at current authority |
| Field generator | Current inventory suites, new representative type/render cases, fresh coverage semantic diff, render --check | Correct int32/enum/model wording; unchanged source fingerprints and unqualified evidence meaning |
| Notices | Header/extract byte checks, all direct local notice links, locked runtime rows | Exact observed provenance; no substituted license bytes or complete-bundle/legal claim |
| Source docs | Manifest existence, path validity, local links/anchors, final-doc content scan | Closed local graph; only optional exact single README creation-credit exception |
| Installed docs | All manifest files and only those files in each clean doc root; equality with source; same closure/content checks | Fresh and complete CMake/LuaRocks data roots; development plans/history absent |
| Checker sensitivity | Exact section 5 source/installed/probe commands, disposable missing target/bad fragment/stale file/unlisted file/content/credit mutations | Same build manifest propagated throughout; each intended failure categorized; pristine before/after every restore; originals untouched |
| Regression integration | Project-required checks appropriate to tooling/install edits using C's explicit selection contract | Real selections executed and recorded; no silent skip or replay of old approval phrases |

Rollback is limited to this future documentation/manifest/generator/example/check
patch set. Preserve unrelated A/C/user changes. Revert current generated coverage
and rendered fields together with their generator changes, and restore manifest
and installed-doc checks together; never roll back by editing immutable evidence
or native locks. Reinstall into a fresh disposable prefix to verify the chosen
state. Do not delete a shared install tree, alter live runtime, or restore an old
recursive dossier install and still claim F13 acceptance. If an integration
dependency blocks the combined change, leave this draft/future patch unaccepted
and report the precise dependency instead of expanding scope.
