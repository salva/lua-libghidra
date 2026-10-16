# Documentation redesign — execution plan

Product baseline: `4dffcb1`. Scope: documentation, selected examples and their
package/site tooling. This standalone plan implements the organization in
[02-DESIGN](02-DESIGN.md). All commands below are for future authorized execution;
none are reported as run by this document. Planning authors change only working
documents. Implementation belongs to the existing project owning chain.

## 1. Authority, outcomes and boundaries

After both design and plan acceptance, the coordinator commits accepted working
artifacts, notifies the main Planner through Analyst, obtains adoption of the new
directions by the owning chain, then uses supported Run. The operator has already
authorized that conditional resume; no additional Run permission is needed once
those conditions hold. Until then execution stays stopped. A root lifecycle label
of `running` is not proof of active execution or adoption. Do not reset the root,
complete cards, Git history or runtime records.

Final readers must be able to install, decompile a known function in their own
supported input, interpret outcomes, and navigate method → model → limitation.
Maintained contributor guidance describes current architecture and commands.
Working plans/reviews/reports/operator instructions remain outside `docs/`, the
installed manual and site. No development history, approval narratives or example
provenance commentary in final docs except context genuinely needed to explain
present behavior, normally an inherited library limitation. No Saivage references
except the optional single creation credit. This restriction does not ban names
in production code, tools or tests.

Preserve substantive licenses, attribution, current pins and all safety/limitation
claims. New examples are independently task-authored; no distinctive upstream
copying was established, actual origin remains unknown. No clean-room claim,
cosmetic translation or further upstream-similarity campaign is required. Do not
add engine features, unsafe address probes, broad OOM sweeps, native repairs,
another generator/manual/framework, redirects or an historical-retention gate.
No push, Pages publication, repository-settings, deployment or prompt/model
configuration change is authorized by implementation resume.

## 2. Priorities, dependency graph and ownership

| Issue | Importance | Cross-cutting surfaces | Owning batches |
| --- | --- | --- | --- |
| R01 — reader journey/reference | High | Landing, install/tutorial, domains, model links, generated index, site navigation | E1 → E2 → E3 |
| R02 — current knowledge versus working documents | High | Contributor tree, reports, legal assets, source consumers, active plan references | E1, checked E2/E3 |
| R03 — independently authored tasks | High | Two Lua sources, guide invocations, installed copies, real validation, downloads | E2, consumed E3 |
| R04 — single authority/artifact closure | High | CMake exports, Lua checks, package routes, HTML routes and pending owner | E1 path changes → E2 package closure → E3 site |

```text
accepted design + accepted plan + committed artifacts
  → root/card-h adoption through supported controls → authorized Run
  → E1 reference/contributor/working-material migration
  → E2 task-first learning/examples and package integration
  → E3 existing card-h-d website + final combined verification
```

These are three coherent batches, not three independent redesigns. E1/E2 are
new documentation follow-up scope under `card-h`; completed A/B/C cards remain
complete. E3 belongs to the existing pending `card-h-d`; do not create a duplicate
website project. Root/card-h select supported child ownership for E1/E2 without
reopening accepted native milestones. Shared-file edits are strictly sequential.

E1 owns API, FIELDS renderer/tests, source-ledger path consumers, contributor
guidance, report/notice moves, and corresponding manifest/checker path changes.
E2 takes over README/learning pages, example sources/callers, manifests, Binding
install entries and package checks. E3 takes ownership of new site files and
workflows; any further shared helper/manifest correction is made sequentially
with the package owner and rechecked there before E3 closes. Never maintain a
second manifest or independently approximate the heading algorithm.

Each batch commits scoped passing work promptly as Salvador Fandiño
`<sfandino@yahoo.com>` for both author and committer. Do not commit generated
runtime state, credentials, build output or push. Record evidence/blockers in
this workflow area or workspace `tmp/`, not in the manual.

## 3. Target tree and complete baseline disposition

Final maintained layout:

```text
README.md; LICENSE; native-inputs.lock.json; native-patched.lock.json; native-system.lock.json
docs/INSTALL.md; docs/TUTORIAL.md; docs/EXAMPLES.md; docs/API.md; docs/NOTICES.md
docs/notices/*.txt
docs/development/{README,SPEC,DESIGN,COVERAGE,TESTING}.md
api/{README.md,FIELDS.md,coverage.json}
api/history/coverage-m3.json; api/runtime-evidence-m3.json  [source-only test data]
examples/{decompile,inspect_function}.lua                [only public scripts]
tests/examples/{first_slice,core_mutation,fixture_manifest}.lua
workflows/{history,evidence,reviews,package-fixes-2026-10-16}/
workflows/documentation-redesign-2026-10-16/              [this work]
site/                                                   [source-only site tooling]
```

| Baseline path(s) | Exact disposition |
| --- | --- |
| README | Concise current product/profile/attribution and links to Install, Tutorial, Examples, API, Fields, Notices. Source-only contributor entry is a plain path, not an escaping installed link. |
| `docs/EXAMPLES.md` | Installation sections become INSTALL; first-use sequence becomes TUTORIAL; EXAMPLES becomes the two-task catalog, invocations and output explanation. No second full Lua code copy. |
| `docs/API.md` | Domain reference and method index with exact surface/record links; retain current effective limits. |
| `api/FIELDS.md` | Regenerate using the existing renderer and ledger with the partition in E1. |
| `docs/NOTICES.md` | Retain attribution, exact inputs, substantive HOS/GPL/LGPL/source obligations; remove approval/process narrative. Extraction offsets/comparison procedure are working evidence, not user prose. |
| `docs/evidence/native-notices/*.txt` | Move all fourteen exact files to `docs/notices/`: abseil, binutils, engine, engine-zlib, httplib, libc6, libghidra, libiberty-dev, libstdc++6, libzstd1, lua, protobuf, utf8-range, zlib1g (each `.txt`). No byte normalization. |
| LICENSE and the three root locks | Unchanged exact legal/current input assets. No incidental dependency update. |
| `docs/{SPEC,DESIGN,COVERAGE}.md` | Rewrite maintained current technical content under `docs/development/` with the same basenames; remove old paths without redirects. Current signatures remain API authority. |
| `docs/development/README.md` | Current contributor entry; extract present commands into TESTING. No chronological evidence index or automation policy. |
| `api/README.md` | Current ledger generation instructions, no migration narrative or report-reading requirement. |
| `docs/PLAN.md`, `M0-LICENSE.md`, `M0-LICENSE-SOURCES.tsv`, `M1-BOUNDARY.md`, `M1-OWNERSHIP.md`, `M2-SLICE.md`, `M3-CORE.md`, `M4-FULL.md`, `INSTALLED-CORE.md`, `INSTALLED-FULL.md`, `FULL-CROSSWALK.md`, `NATIVE-READINESS.md`, `PACKAGE-FOUNDATION.md`, `PACKAGE-HANDOFF.md` (all under docs) | Move existing files to `workflows/history/` under their basenames. Extract needed present facts, not report prose, into maintained docs. |
| Remaining `docs/evidence/*` | Move to `workflows/evidence/`; native-notices has the separate disposition above. No new archive reconstruction. |
| `docs/development/plans/package-fixes-2026-10-16/**` | Move to `workflows/package-fixes-2026-10-16/**`. This plan replaces conflicting B/D instructions. |
| `docs/history/reviews/package-audit-2026-10-16/**` | Move to `workflows/reviews/package-audit-2026-10-16/**`. |
| `docs/reviews/**` | Move to `workflows/reviews/baseline/**`. |
| `api/coverage.md` | Move chronological research to `workflows/history/api-coverage.md`. |
| `api/history/coverage-m3.json`, `api/runtime-evidence-m3.json` | Keep existing test-consumed data at the same paths; never install/render/regenerate it. |
| Existing first_slice/core_mutation/fixture_manifest examples | Relocate to `tests/examples/`; remove the extreme lookup as specified in E2 before selected execution. No public installation/download. |
| `examples/decompile.lua` | Newly author from the selected task contract; keep filename, not a translation/rename exercise. Add only `inspect_function.lua`. |
| `.saivage/`, `.saivage-work/`, Git history | Preserve; do not rewrite cards/runtime JSON/history or erase locks. |

Update maintained path consumers, not every frozen historical link. This includes
AGENTS/project skills/current workflow references, fixture README, package probes,
`scripts/inventory-api.lua`, `scripts/inventory_surfaces.lua` and
`tests/tooling_coverage.lua`. Keep current guidance references correct through
applicable project skills; no live prompt deployment is part of these batches.
Source metadata path corrections may regenerate coverage, but must not change
runtime qualification slots or promote historical proposed grammar into API truth.

## 4. E1 — current reference and contributor separation

### Implementation

1. Inventory tracked changes and source consumers before moving files. Use the
   baseline/current comparison to preserve unrelated work. Capture exact notice,
   LICENSE and root-lock bytes for scoped comparison; no evidence dossier creation.
2. Apply report/notice/contributor moves from section 3. Rewrite contributor SPEC
   as present binding invariants, DESIGN as actual direct-C-API ownership/boundary
   architecture, COVERAGE as current included/excluded accounting and producer
   limits, TESTING as executable current tooling commands/prerequisites.
3. Reorganize API into construction/lifecycle/status; values/errors/pagination;
   functions/decompilation/signatures/locals; instructions/comments/data;
   symbols/xrefs; memory/patches; types/aliases/enums/members; performance; common
   ownership/invalidation/persistence limits. Index every implemented public name,
   including factories/check/u64/native/close and only the three real iterators.
4. Each method has exact arguments/defaults, Session/lowlevel availability,
   return differences, state requirements, mutation effects and relevant caveats.
   Link model-bearing results to envelope and nested model; scalar results say
   scalar. `get_function` links GetFunctionResponse/FunctionRecord and explains
   `response['function']`; get_decompilation links GetDecompilationResponse/
   DecompilationRecord; get_status links HealthStatus; get_capabilities links
   Capability array elements; patch_bytes_batch links BytePatch input items and
   PatchBytesBatchResponse. No invented capability envelope.
5. Extend `scripts/render-fields.lua`, retaining ledger → renderer → FIELDS as
   the sole field pipeline. Scope first: all native-only types/enums go to the
   appendix; included `*Record` plus HealthStatus/Capability are records/result
   values; included `*Request`/`*Options` plus BytePatch are request/options/input
   items; included `*Response` are envelopes; included enums are supported enums.
   The three exceptions are renderer presentation metadata, not a new schema.
   Unknown scope/unassigned/multiply assigned models fail. Disjoint emitted sets
   must equal all ledger type/enum keys exactly once. Alphabetize within groups,
   put supported records first, generate linked group/model index, preserve
   model-name anchors and nested links. Keep source reachability separate from
   producer evidence, persistence or supported iteration.
6. Adapt field tests to assert exception placement and exhaustive partition, as
   well as existing UInt64/narrow integer/optional/enum conversion facts. Update
   coverage input paths in generator/tests, and generated authority references
   where they name moved documents. Preserve 70 included/40 excluded accounting
   and unqualified generated evidence slots; no native adapter changes.
7. Update package manifest/checker/probe notice paths and any links affected by
   these moves atomically. Keep existing learning-page selection until E2 creates
   its replacements; do not commit links to nonexistent future files. Replace
   generator-policy tests of historical approval wording with current substantive
   SOURCE-only Python generator scope assertions, not historical-report checks.

### Evidence and exit

The existing [renderer](../../scripts/render-fields.lua#L43),
[field tests](../../tests/tooling_fields.lua#L22),
[inventory CLI](../../scripts/inventory-api.lua#L20) and
[tooling driver](../../scripts/check-tooling.lua#L5) define actual entrypoints.
From checkout root, with existing pinned source and a fresh work child:

```sh
lua5.4 scripts/render-fields.lua
lua5.4 scripts/render-fields.lua --check
lua5.4 tests/tooling_fields.lua
lua5.4 scripts/check-tooling.lua "$PINNED_SOURCE" "$WORK/e1-tooling"
bash tests/generator-policy.sh
```

Discover PINNED_SOURCE from the selected prepared input root/CMakeCache and
verify libghidra revision `d51ca813ae1b6b59519551a9be8c0b1ad74d862d`; do not download
or reconstruct upstream merely to move docs. Because source consumers change,
run fresh candidate generation into the tooling work directory and inspect the
semantic diff against committed coverage; differences must be intentional path/
presentation metadata, not runtime claims. Compare every moved exact legal asset
with its prechange bytes. Review method inventory against actual facade/native
registrations and every local model link. No invented CTest names.

Exit: maintained reference and contributor paths work; working material is outside
docs; exact legal assets survive; source/checker/generator tests applicable to
these changes pass. Record temporary E2 learning work as working status only.

## 5. E2 — two public tasks, learning pages and package closure

### Exact public task interfaces (future script implementation)

```text
lua5.4 decompile.lua BINARY ADDRESS LANGUAGE_ID COMPILER_SPEC_ID [GHIDRA_ROOT]
lua5.4 inspect_function.lua BINARY ADDRESS LANGUAGE_ID COMPILER_SPEC_ID MAPPED_START MAPPED_END BYTE_COUNT INSTRUCTION_END INSTRUCTION_COUNT [GHIDRA_ROOT]
```

All addresses are exact accepted UInt64 text, preferably `0x` hex. ADDRESS is a
caller-verified mapped virtual function/instruction entry, never a file offset or
script-selected first function. Bounds are inclusive. No built-in fixture address,
fixed function name, state file, timeout promise or second-client construction.
Optional GHIDRA_ROOT selects external specs; omission uses embedded specs.

Both scripts reject malformed/empty/extra arguments before open and use explicit
language/compiler hints. Exit 2 for invocation/validation error, 1 for native or
unavailable/incomplete task results, 0 for complete required observations. Release
the owner through a Lua 5.4 close scope before os.exit, including raised Lua-error
paths. Diagnostics on stderr retain code/operation/backend/message for structured
errors; engine error text is not silently discarded. Ordinary Lua allocation
errors are not fabricated native envelopes.

`decompile.lua` produces a function-level review note. Stdout begins with
`address=<canonical hex>` and
`result=<complete|incomplete|fallback|unavailable|error>`, followed by returned
pseudocode if present. Classification: nil native failure is error; completed
false is incomplete; otherwise is_fallback true is fallback; completed true,
is_fallback false and empty/no error_message is complete; remaining present
non-success outcomes are error. `unavailable` is a NOT_FOUND optional result.
Nonempty error_message always prevents exit 0. Preserve flags in additional
`completed=`/`is_fallback=` lines when a record exists; do not equate text presence
with success. Pseudocode formatting is not a golden-output contract.

`inspect_function.lua` first decompiles the known function (discovery is lazy),
then reports its available function record, byte data and instruction page. Require
all bounds/counts explicitly: BYTE_COUNT 1..64, INSTRUCTION_COUNT 1..8, instruction
offset 0, nonzero INSTRUCTION_END. Before native reads, verify exact ordered
MAPPED_START ≤ ADDRESS ≤ MAPPED_END, checked ADDRESS + BYTE_COUNT − 1 ≤ MAPPED_END,
and ADDRESS ≤ INSTRUCTION_END ≤ MAPPED_END. Both read starts are ADDRESS. Reject
overflow and zero-end sentinel; byte count does not bound the independent
instruction page. The caller confirms complete instruction bytes are mapped,
not merely instruction starting addresses. This is bounded-input checking, not
mapping detection or protection against native crashes. No exploratory scanning
or guessed replacement address is permitted.

Inspection stdout has `address=`, `result=`, available `function_name=` and exact
record address fields, `bytes_hex=` (two lowercase digits per byte), then ordered
`instruction_address=` lines from the returned page. Escape embedded control
characters in text metadata with Lua quoted-string formatting; pseudocode remains
data in the decompilation task. Result complete requires complete nonfallback
decompilation, a present function, requested byte length and a nonempty successful
instruction page within the requested bounds. Do not demand a full instruction
count: a short page is not exhaustive enumeration. Missing optional metadata or
empty instructions is unavailable, not “no code”; output available observations
but exit 1. Native failure is error. No mutation, stale iterator tour or saving.

### Implementation and source/package integration

1. Independently author those two small scripts from the task contract. No shared
   example framework or cosmetic renaming requirement. Derive tutorial invocations,
   site code display and downloads from these sources, not full copied Lua blocks.
2. Move fixture tours to tests/examples. In first_slice remove the two-line native
   `get_function(u64(fixture.absent_function_address))`/NOT_FOUND assertion; remove
   `absent_function_address='18446744073709551615'` from its helper. The unchanged
   extreme-address dispatch must not enter this lane. Keep safe metadata/envelope,
   alias/closure/reopen and core invalidation assertions. Rely on existing safe
   optional-result checks; do not search for another unmapped address.
3. Author INSTALL's four routes (source/SDK × CMake/LuaRocks), preserving actual
   absolute-path setup, selected Lua host/headers, helper DSO/$ORIGIN, prepared
   inputs and disconnected-build distinction, qualified SDK/PIC/Protobuf CONFIG
   requirements, source-only Python >=3.10 stdlib zlib/XML generator dependency
   and actual LuaRocks data prefix. No advertised public SDK. TUTORIAL assumes
   install, explains known virtual address selection and `nm` hex prefixing,
   outcome/error inspection and native crash limits before first invocation.
   EXAMPLES explains the two tasks and arguments/results; no fixture dependency.
4. Keep API authority for exact grammar/limits and FIELDS for generated types.
   Preserve one client/process, host ABI, detached records, logical versus owner
   closure, ignored protections/deadlines, bounded reads, real three-iterator and
   pages-only behavior, empty string stub, partial batches, category-specific
   persistence/no rollback, raw/FileBytes and true-local limits, and no dependency
   OOM recovery guarantee. Do not replace these with links to reports.
5. Make `cmake/PackageDocuments.cmake` the sole selection authority: documents are
   README, INSTALL, TUTORIAL, EXAMPLES, API, NOTICES, FIELDS, LICENSE, three root
   locks and fourteen docs/notices files. Add `LLG_PACKAGE_EXAMPLES` containing
   exactly the two root examples. Export `package-examples.txt` alongside the
   combined `package-documents.txt`; the combined list includes examples paths.
   In Binding.cmake replace the existing separate example install lists with
   that list. Install runnable copies under share/libghidra/examples and exact
   manual copies under share/doc/lua-libghidra/examples. No fixture/helper copy.
6. Documents retain source-relative paths under share/doc/lua-libghidra. Source
   mode resolves selected examples to root examples sources. Keep existing CLI:

```sh
lua5.4 tests/installed_documents.lua source "$SOURCE" "$MANIFEST"
lua5.4 tests/installed_documents.lua installed "$DOCUMENT_ROOT" "$SOURCE" "$MANIFEST"
bash tests/installed-documents.sh "$DOCUMENT_ROOT" "$SOURCE" "$MANIFEST" "$WORK/document-probes"
lua5.4 tests/package_documents.lua "$SOURCE" "$WORK/document-grammar"
```

All arguments are absolute; work children must not exist. MANIFEST is from the
producing build/export, never an inferred sibling build. Source mode permits
other files elsewhere in checkout and checks only selected inputs/graph. Exact
membership/regular-file checks apply to the document subtree/site, not the whole
prefix or repository. Check runnable example copies against source bytes too.
7. Remove the old path-dependent policy bypass in
   [package-documents.lua](../../scripts/package-documents.lua#L217): new target
   policy members and obligations are required, not optional when all old paths
   happen to exist. Update mutation probes for new paths; retain missing member,
   stale bytes, link/reference/image/fragment, malformed manifest, extra report,
   nonregular installed file and hidden marker sensitivity. Add schema partition/
   missing-method-model-link checks to the existing tests rather than a framework.
   Human review checks history/approval/origin prose; lexical checks cannot prove
   authorship. Preserve optional exact landing credit policy and exact legal bytes.
8. Update [installed qualification's example group](../../tests/installed-qualification.sh#L83)
   to run public installed scripts with safe fixture arguments and corrected
   source-only regressions against installed modules. Its public-example call uses
   the exact explicit host/module/example-root interface below, with values from
   its selected build and actual install; no legacy `--prefix` inference. Keep full/reduced semantics;
   do not silently skip old groups or broaden reduced into a full claim.

### Real validation and installation scope

Add one focused future runner `tests/installed-examples.sh` with this interface:

```sh
bash tests/installed-examples.sh --lua "$SELECTED_LUA" \
  --lua-module-dir "$DEPLOYED_LUA_DIR" --c-module-dir "$DEPLOYED_C_DIR" \
  --example-root "$INSTALLED_EXAMPLES" --source "$SOURCE" \
  --work "$WORK/examples" --external-specs "$EXTERNAL_SPECS"
```

The runner is new, not an existing command claimed to pass. Every path is absolute;
work is fresh. `--lua` is the artifact's selected ordinary Lua executable, not an
ambient `lua5.4` or a new embedded host. `--lua-module-dir` is the deployed directory
containing `libghidra/init.lua`; `--c-module-dir` contains `libghidra/_native.so`
and its installed helper DSO. `--example-root` contains the two installed scripts
and is independent of both module roots. `--source` locates test fixtures/oracles
only, never a fallback module or public-example location. Verify these files,
selected-host identity and example byte equality before execution; missing or
ambiguous route inputs fail rather than selecting ambient modules.

For public script subprocesses, clear `LUA_INIT`, `LUA_INIT_5_4`, `LUA_PATH`,
`LUA_PATH_5_4`, `LUA_CPATH` and `LUA_CPATH_5_4`, then set only:

```text
LUA_PATH=<DEPLOYED_LUA_DIR>/?.lua;<DEPLOYED_LUA_DIR>/?/init.lua
LUA_CPATH=<DEPLOYED_C_DIR>/?.so
```

No `;;`, empty search element, cwd, source, fixture-helper or ambient/default
fallback. Reject roots containing path-list separators. Invoke the explicit
selected executable with the installed script's absolute path from a fresh cwd.
Do not use Lua `-E`, which would discard these explicit environment paths. Retain
the package's installed $ORIGIN/helper layout, not a build-tree DSO fallback.
Safe internal regressions may load their source-only fixture helper explicitly;
their binding modules must still resolve from the same deployed roots.

External-specs is optional for the installed driver's embedded-only lane; E2's
focused acceptance invokes it and exercises both modes. The runner selects
existing locked fixture bytes/known safe entry and mapped spans and supplies them
as CLI arguments. No source fixture import by public scripts. Do not use the
helper's deleted extreme address. Check existing fixture SHA256SUMS before execution.

**CMake invocation.** Obtain SELECTED_LUA from the producing build's
`LUA_EXECUTABLE` cache value and confirm its recorded qualified host identity.
Resolve that build's `LUA_SOURCE_DIR` and `LUA_MODULE_DIR` install destinations:
relative values are beneath the actual install prefix, absolute values are used
as written. Confirm the installed files/install manifest, including any install
prefix override. For the current conventional relative destinations
`share/lua/5.4` and `lib/lua/5.4`, the concrete call is:

```sh
SELECTED_LUA=$(sed -n 's/^LUA_EXECUTABLE:[^=]*=//p' "$BUILD/CMakeCache.txt")
bash tests/installed-examples.sh --lua "$SELECTED_LUA" \
  --lua-module-dir "$PREFIX/share/lua/5.4" --c-module-dir "$PREFIX/lib/lua/5.4" \
  --example-root "$PREFIX/share/libghidra/examples" --source "$SOURCE" \
  --work "$WORK/cmake-examples" --external-specs "$EXTERNAL_SPECS"
```

Use the resolved actual destinations instead if the cache differs. The updated
installed-qualification example group passes these same flags and resolved values;
its embedded-only invocation omits `--external-specs`, not the host/module roots.

**Actual LuaRocks invocation.** Use the same `--tree`, `--lua-version` and
`--lua-dir` selection that produced the installed rock. The
[rockspec](../../lua-libghidra-scm-1.rockspec#L15) passes PREFIX, LIBDIR, LUADIR and
resolved LUA separately to the [driver](../../scripts/luarocks-build.lua#L14).
Record those actual expanded values from that build/install: PREFIX is reflected
in its CMAKE_INSTALL_PREFIX, LIBDIR in LUA_MODULE_DIR and LUADIR in LUA_SOURCE_DIR.
PREFIX locates versioned package data; LIBDIR/LUADIR describe CMake's rock install
destinations and may be staging directories, not final deployed module roots.
LuaRocks deployment must be verified separately using the selected tree's
`deploy_lua_dir`/`deploy_lib_dir` values and actual installed files. Never append
CMake's conventional module subpaths to the versioned package PREFIX.

Here ROCK_BUILD is the real producing LLG_BUILD_DIR, ROCKS the actual installed
tree, and LUA_DIR the compatible host prefix supplied to that installation:

```sh
ROCK_PACKAGE_PREFIX=$(sed -n 's/^CMAKE_INSTALL_PREFIX:[^=]*=//p' "$ROCK_BUILD/CMakeCache.txt")
ROCK_LUA=$(luarocks --lua-version=5.4 --lua-dir="$LUA_DIR" --tree="$ROCKS" config variables.LUA)
ROCK_LUA_MODULES=$(luarocks --lua-version=5.4 --lua-dir="$LUA_DIR" --tree="$ROCKS" config deploy_lua_dir)
ROCK_C_MODULES=$(luarocks --lua-version=5.4 --lua-dir="$LUA_DIR" --tree="$ROCKS" config deploy_lib_dir)
bash tests/installed-examples.sh --lua "$ROCK_LUA" \
  --lua-module-dir "$ROCK_LUA_MODULES" --c-module-dir "$ROCK_C_MODULES" \
  --example-root "$ROCK_PACKAGE_PREFIX/share/libghidra/examples" --source "$SOURCE" \
  --work "$WORK/rock-examples" --external-specs "$EXTERNAL_SPECS"
```

Before the call, verify ROCK_LUA agrees with the expanded build-command LUA and
cache LUA_EXECUTABLE, all values are absolute/resolved, and package data plus
deployed module/helper bytes are from this actual installation. Querying current
config alone cannot certify an older artifact's host or deployment. Resolve any
discrepancy from its real install records; otherwise report a blocker. Do not
simulate a versioned prefix or use `luarocks path` output with ambient fallbacks.
Reuse unchanged host/ABI qualification; these explicit inputs add no four-route
clean rebuild or new shared/static-host campaign.

Assert actual known arithmetic semantics for decompilation, exact address text,
completed/nonfallback flags/status, expected function name after discovery,
known bytes and safe instruction address sequence. Select verified complete
instruction spans from existing fixture evidence, not a scan at implementation
time. Exercise both public sources as installed copies. Invalid integer text,
extra/missing args, byte count 0/65, instruction count 0/9, reversed/outside bounds,
overflow and zero INSTRUCTION_END must fail before native reads; use synthetic
call observers for pre-dispatch/closure cases, not unsafe native probes.
Retain/adapt `tests/decompile_example.lua` for fallback/incomplete/error-message,
open failure and raised error control flow; synthetic results supplement real
execution. Existing safe optional-result coverage suffices when native NOT_FOUND
cannot safely be induced. Report unavailable cases explicitly.

The existing private authored fixture provides a concrete minimal oracle:
`tests/fixtures/inputs/authored.elf`, `native_smoke` at `0x401106`, semantic
`x * 3 + 7`, and entry bytes `f3 0f 1e fa` (ENDBR64), as used by
[the baseline first-slice assertions](../../examples/first_slice.lua#L15).
For execution-time inspection after relocation, use `tests/examples/first_slice.lua`
with the unsafe absent-address assertion removed, not the former examples path.
After confirming the locked fixture matches those identities, inspection can
request BYTE_COUNT=4, INSTRUCTION_END=0x401109 and INSTRUCTION_COUNT=1 with a
confirmed mapped extent covering the complete four-byte instruction. Require
`bytes_hex=f30f1efa` and first instruction address `0x0000000000401106`; use the
existing fixture's actual mapped bounds rather than asserting a guessed extent.
These are private validation inputs, never default addresses in public examples.

Discover existing qualified build(s) from actual CMakeCache, install manifests
and route logs. Inspect `cmake/Binding.cmake`, `tests/installed-qualification.sh`,
`tests/installed-profiles.sh`, `tests/installed-absence.sh`, and
`scripts/luarocks-build.lua` before selecting checks. `ctest --test-dir "$BUILD" -N`
lists actual registered names; documentation checks above are direct scripts,
not invented CTest entries. Do not run the unchanged installed example group
before removing the unsafe lookup.

At least one real CMake staged install and one actual LuaRocks versioned data
layout must demonstrate the changed example/document selection and bytes. Reuse
qualified source and SDK build inputs/objects and unchanged route evidence; prefer
existing source and SDK builds to cover both consumers. Reconfigure changed CMake
install/export rules, build only as needed, install into fresh prefixes, and run
the manifest checks and focused example runner against those artifacts. Execute
each final changed recipe command path where its logic differs; unchanged native
compilation/host/engine evidence is reusable with recorded matching identities.
Do not mandate four clean native rebuilds for document moves. If a recipe changes
native options, dependency/ABI selection or LuaRocks driver behavior, qualify that
affected route fully; if the requisite SDK/route is unavailable, mark its check
blocked rather than simulate a versioned prefix or claim a pass.

Existing driver contract, only when its declared integration scope is selected:

```sh
bash tests/installed-qualification.sh --build "$BUILD" --prefix "$FRESH_PREFIX" \
  --work-root "$WORK_ROOT" --external-specs "$EXTERNAL_SPECS" --mode full
bash tests/installed-qualification.sh --build "$BUILD" --prefix "$OTHER_FRESH_PREFIX" \
  --work-root "$WORK_ROOT" --mode reduced
```

Inspect its prerequisites: BUILD_TESTING=ON and built shared/static hosts;
full additionally needs non-root namespace/tool/fixture/external-spec support.
Focused docs/example checks do not require claiming a full driver pass. If full
is run, complete all its declared groups; if reduced is run, retain OMIT reporting.

Exit: real examples and affected install paths pass, manual/asset graph is closed,
negative probes fail for their intended reasons, exact legal/example bytes agree,
and editorial reader/authority boundaries pass. E3 consumes this committed source.

## 6. E3 — finish the existing Pandoc/Lua website

`card-h-d` consumes E2; it must not resume the old five-page build or old extra
example inventory. Its former plan moves to
`workflows/package-fixes-2026-10-16/D-website/03-PLAN.md`. This section replaces its
conflicting instructions completely; no old review-round reading sequence needed.

### Files and contracts to implement (all future)

```text
site/README.md                 source-only build/preview/publication guidance
site/toolchain.lock.json       actual Pandoc version/platform/URL/SHA256/license
site/content.lua               navigation and export-derived route rules
site/export-documents.cmake    script-mode export, no native configuration
site/template.html; site/style.css; site/links.lua
scripts/build-site.lua; scripts/check-site.lua; scripts/preview-site.sh
tests/site_contract.lua
.github/workflows/site-check.yml; .github/workflows/site-publish.yml
```

Use Lua 5.4, CMake >=3.26 script mode and a real pinned Pandoc release supporting
GFM/Lua filters. No exact release/hash is supplied by existing source: select an
actual release during E3, record exact archive URL/SHA256/version/license, verify
archive before extraction and executable version before rendering. Never invent
a checksum or use floating latest. A matching explicit local converter is valid.
Provision tools explicitly; subsequent builds/checks are offline, with no native
build, Python, Java or engine execution dependency. No framework fallback without
reporting a concrete blocker to the owner.

Exporter consumes the one CMake authority into fresh report/work storage. Define
future export CLI `cmake -DLLG_DOCUMENT_EXPORT_DIR="$EXPORT" -P site/export-documents.cmake`;
it writes package-documents.txt and package-examples.txt. Build invokes that export,
then render-fields --check and the existing absolute source-check CLI. Markdown
entries become same-relative `.html`, except README → index.html. LICENSE/locks/
notices/Lua examples are exact passthroughs; CSS → assets/style.css; add .nojekyll.
Every export entry is classified once, unknown classes/collisions fail. Reports,
raw Markdown, contributor/workflow/private files are not output. Public script
code display is escaped directly from the same downloaded/tested bytes.

Navigation: Home, Install, Tutorial, Examples, API, Fields, Notices. Generate TOCs
from headings. Share/export [the existing helper's heading implementation](../../scripts/package-documents.lua#L105)
with the Pandoc filter: lowercase, remove backticks/punctuation as specified there,
hyphenate whitespace, duplicate suffixes -1/-2. Set IDs explicitly; preserve model
slugs. Resolve links against source paths, then route-map to output; validate
actual rendered IDs/href/src including fragment-only, reference/image and encoded
forms. Unsupported syntax fails clearly. Canonical origin https://salva.github.io,
project base /lua-libghidra, page-relative assets/links; never /docs or /assets.

One accessible semantic template, skip link/keyboard focus, readable local system
fonts/CSS, narrow navigation and scrollable wide code/tables. No JS/analytics/remote
assets. Reject symlinks/escaping inputs/output-source overlap. Use fresh staging
and exact regular-file output membership; deterministic rendering, no timestamps
or host paths. Compare source bytes as well as report hashes so stale reports
cannot certify stale output. Scan raw/decoded HTML text, attributes/comments and
downloads; retain only the exact optional landing acknowledgment exemption. Do
not scrub exact notices if policy conflicts: report the conflict.

### Future commands and sensitivity

From checkout root; PANDOC is an absolute verified executable matching the lock.
WORK is a fresh directory under `/home/salva/g/ml/tmp`, not an artifact input.

```sh
lua5.4 scripts/render-fields.lua --check
lua5.4 scripts/build-site.lua --pandoc "$PANDOC" \
  --baseurl /lua-libghidra --origin https://salva.github.io \
  --output "$WORK/preview/lua-libghidra" --report "$WORK/build.json"
lua5.4 scripts/check-site.lua --root "$WORK/preview/lua-libghidra" \
  --baseurl /lua-libghidra --report "$WORK/build.json" --source .
lua5.4 tests/site_contract.lua --work "$WORK/site-probes" --pandoc "$PANDOC"
lua5.4 scripts/build-site.lua --pandoc "$PANDOC" \
  --baseurl /lua-libghidra --origin https://salva.github.io \
  --output "$WORK/rebuilt" --report "$WORK/rebuilt.json"
diff -r "$WORK/preview/lua-libghidra" "$WORK/rebuilt"
lua5.4 scripts/build-site.lua --pandoc "$PANDOC" --baseurl '' \
  --origin https://salva.github.io --output "$WORK/root-site" --report "$WORK/root.json"
lua5.4 scripts/check-site.lua --root "$WORK/root-site" --baseurl '' \
  --report "$WORK/root.json" --source .
sh scripts/preview-site.sh --root "$WORK/preview" --bind 127.0.0.1 --port 8088
```

Preview uses optional BusyBox httpd on loopback, fails clearly if absent, runs in
foreground until Ctrl-C, and serves the parent to retain the project path. Check
`http://127.0.0.1:8088/lua-libghidra/`, nested docs/API.html, api/FIELDS.html,
docs/notices/engine.txt, examples/decompile.lua and assets/style.css. At 360px and
desktop, verify keyboard/skip/TOC, 200% zoom, focus, table/code overflow and WCAG AA
normal text/link contrast. Record observations, not a claim of full accessibility
audit. External link URLs are inventoried, not network-required test gates.

Disposable-copy probes must reject missing notice/fragment, duplicate IDs, root
escaping asset, wrong README mapping, altered download, stale source/report/output,
extra history/private file, source symlink, encoded prohibited reference and
duplicate/mislocated credit. No mutation of original source by sensitivity tests.
After any shared-helper adjustment, rerun E2 source/package graph/probes affected
by it before declaring site integration complete.

### CI preparation, not publication

site-check runs on PR/default-branch push with contents:read, no persisted checkout
credentials, secrets, deployment or pull_request_target. Pin reviewed full action
SHAs with release comments and runner OS version; use the converter lock. Inspect
the actual default branch instead of assuming main. site-publish is manual
workflow_dispatch with explicit default-branch guard: read-only build/check job,
only deploy job receives pages:write/id-token:write and uses github-pages
environment; serialize publication with cancel-in-progress false. Deploy only
that run's checked artifact, never repository checkout or fork/workflow_run input.
Do not auto-enable Pages. Preparing YAML does not authorize push, dispatch,
settings/DNS changes or deployment; do not claim the target URL is live.

Exit: deterministic same-source site and negative checks pass, presentation
observations recorded, package checks remain valid, no public/history boundary
leakage. End-to-end reader walkthrough reaches install → tutorial → method →
record → caveat without entering workflows. Completed native evidence is reused,
not rewritten as a new whole-project qualification claim.

## 7. Failure handling, rollback and completion report

If a boundary check fails, correct the owning source/helper and rerun affected
checks; do not relax required warnings, fabricate evidence or copy the checkout
as a site workaround. Stop the affected lane on unavailable prerequisites and
continue only independent in-scope work. No broad evidence-retention obligation.

Rollback only this work's explicit files/hunks or scoped commits, after checking
for newer user/agent edits. Do not use broad reset/clean/delete, overwrite a whole
prefix, replace runtime state, reset history or restore old cards. Generated
outputs may be discarded only in the caller-created disposable work directories.
Reconcile reverse path moves with active owner references; avoid erasing later
work. Any runtime pause uses supported Stop, not lock removal/service restart.

Final report states exact commits, completed E1/E2/E3 outcomes, commands actually
run, input/profile identities and reused evidence, unavailable checks/blockers,
byte/graph/content/example/site results, and unperformed publication separately.
Required negative cases are not passes until observed to fail as intended. No
deployment or push follows implicitly from local completion.
