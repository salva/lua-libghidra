# Regression selection and semantic evidence: implementation plan

## Preconditions and scope

This plan is a draft for subsequent independent review and later implementation
authorization. Current work is documentation only. Implement F08–F10 using native
local Lua/C++ tests, no SWIG/HTTP, unchanged pinned dependency inputs and the narrow
approved upstream source-generator exception. No new framework, fixtures, upstream
repairs, exhaustive engine faults or runtime-control work is part of this plan.

Read the [design](/docs/development/plans/package-fixes-2026-10-16/C-regressions/02-DESIGN.md#L1)
before editing. Inspect the worktree and preserve other groups' work. Use a
configured supported testing build and ordinary non-root qualification environment;
missing prerequisites block full integration rather than reducing its selection.
The recorded [18/18 result](/docs/history/reviews/package-audit-2026-10-16/07-BASELINE-VALIDATION.md#L3)
is reusable boundary baseline evidence only.

## Batches and dependencies

### 1. Explicit orchestration (F08)

Files: `tests/installed-qualification.sh`, `tests/installed-profiles.sh`,
`tests/installed-absence.sh`; search both child script names to catch any newly
introduced callers (currently only the qualification driver). Add the exact flag parser,
full/reduced summaries, preflight, unique work allocation, fresh cwd/HOME, prefix
freshness and explicit child arguments specified in the design. Preserve all
current selected test bodies and three-host coverage. Coordinate document group
invocation with B's unchanged three-argument document driver interface.

Then add only the integration-target/cache-input hunk to `cmake/Binding.cmake`.
This shared file also belongs to A's ABI and B's install changes: integrate their
hunks, never replace the file from a baseline copy. Do not change CTest selection
to pretend the installed integration suite was already registered.

Check shell syntax for every edited shell script with `bash -n`. Validate parser
errors without building: missing/unknown/duplicate options, existing prefix,
unwritable work root, missing external specs. Confirm diagnostics distinguish
usage/prerequisite failures from a child-test failure. No automatic fallback.

### 2. Specialist state prerequisites (F09)

Files: `tests/m4_services.lua`, `tests/m4_persistence.lua`. Against the pinned real
backend, add the design's create/read/edit/read/delete/absent sequences and exact
pre-save snapshots. Use existing method grammars and field names in
[conversion](/src/core_convert.hpp#L79). Investigate one bounded observation per
uncertain category rather than adding blind assertions or repeatedly rebuilding
the engine. Freeze supported-change assertions or deterministic limitation checks
based on that evidence; do not permit both outcomes at runtime. Keep profile labels
and distinguish local-kind from parameter-kind edits. No existing fixture bytes
or hashes are changed.

Stop and hand off a demonstrated wrapper defect to A/its adapter owner; report
the operation and minimal failing assertion. For native ignored writes, narrow
claims and continue independently. Do not repair the dependency or falsely mark
a never-observable category as lost on reload.

### 3. Authored leaves (F10)

File: `tests/m4_services.lua`, after batch 2 to avoid competing edits. Insert exact
two-leaf identity/order, caller exclusion, limit-one offsets including exhaustion,
singleton ranges and shortened-range tests. Keep raw-ELF NOT_SUPPORTED. Reference
existing [probe](/tests/project_probe.cpp#L19) and
[fixture source facts](/tests/fixtures/README.md#L30); no manifest/schema expansion
is required for three constants.

### 4. Bounded sensitivity checks and handoff

Use disposable copies of the edited Lua test (and a test-local forwarding proxy
if needed) to demonstrate one supported member rename dropped while returning its
original acknowledgement fails at the immediate readback, before save. If that
specific write is genuinely unobservable upstream, use one established observable
member/enum edit instead and report which. Do not weaken limitations to make a
mutant useful. For leaves, demonstrate a proxy returning an ordinary function
page fails caller/count checks, and one repeating offset-zero leaf fails offset
one. Run these copies against the real backend; no production test hook or generic
mutation framework is required. Confirm the unmodified tests pass. Retain concise
failure evidence; temporary mutants are not installed or committed.

F08's sensitivity check is selection, not semantics: run full mode with the ambient
card variable absent, and verify all required group completion lines. In a second
bounded reduced-mode run, set that variable to an unrelated directory and verify
the same reduced selection and explicit omissions; it must not change selected
groups or receive artifacts. Missing full-mode prerequisites must fail before
claiming qualification. Confirm the named integration target routes to the same
driver (a missing-input invocation is sufficient to check its error route before
one real full run; do not repeat expensive full runs solely for the target).

## Concrete validation interface after implementation

From the repository root, with absolute paths chosen by the implementer:

```sh
ROOT=$PWD
BUILD="$ROOT/build"
WORK=/home/salva/g/ml/tmp/llg-package-regressions
SPECS="$ROOT/.cache/native-inputs-patched/engine"
mkdir -p "$WORK"
RUN=$(mktemp -d "$WORK/validation.XXXXXX")
ctest --test-dir "$BUILD" --output-on-failure
env -u SAIVAGE_CARD_WORK_ROOT bash tests/installed-qualification.sh \
  --build "$BUILD" --prefix "$RUN/install-full" --work-root "$RUN" \
  --external-specs "$SPECS" --mode full
```

The prefix does not exist beforehand. The driver builds/installs and runs from its
own fresh cwd, so do not manually reuse a stale install. `WORK` is ordinary caller
storage, not a required special path. Run full mode as non-root with namespace
support. If those prerequisites are unavailable, report full integration blocked;
the following explicitly limited command can still establish reduced evidence:

```sh
bash tests/installed-qualification.sh --build "$BUILD" \
  --prefix "$RUN/install-reduced" --work-root "$RUN" --mode reduced
```

For focused development, after a fresh staged install, use existing interfaces:

```sh
lua5.4 tests/m4_services.lua "$RUN/install-full" "$ROOT"
PERSIST=$(mktemp -d "$RUN/persistence.XXXXXX")
lua5.4 tests/m4_persistence.lua "$RUN/install-full" "$ROOT" "$PERSIST"
sha256sum -c tests/fixtures/SHA256SUMS
```

These focused commands are not replacements for full selection. Persistence uses
a fresh directory so its known state-file removals cannot touch prior runs.
Configure the optional named target on the existing build using its existing
configuration plus:

```sh
cmake -S "$ROOT" -B "$BUILD" \
  -DLLG_INTEGRATION_PREFIX="$RUN/install-target" \
  -DLLG_INTEGRATION_WORK_ROOT="$RUN" \
  -DLLG_INTEGRATION_EXTERNAL_SPECS="$SPECS"
cmake --build "$BUILD" --target integration
```

Choose direct full invocation or target full invocation for final qualification,
not both by default. The target's prefix must also be fresh. Passing integration
does not replace offline source/SDK/LuaRocks install or sanitizer qualification.

## Evidence and cross-group completion

Supply B a compact correction payload, not a new ledger: actual commands, build/
SDK/engine/Lua identities, fixture hash check, selected groups and modes, supported
state changes versus acknowledgement-only cases, and pre-save/reopen outcomes.
B applies it to the replacement/current equivalents of:

* [M4 qualification prose](/docs/M4-FULL.md#L197): only attribute loss to observable
  pre-save state; distinguish missing member from isolated comment persistence.
* [GetRevision crosswalk row](/docs/FULL-CROSSWALK.md#L40): remove citations to
  tests that do not call get_revision; do not invent a new revision test merely
  to rescue the citation.
* [Enum claims](/docs/FULL-CROSSWALK.md#L107): width evidence does not prove ignored
  signedness. Add a direct justified readback only if this bounded work establishes
  it; otherwise narrow the text.
* Current developer testing guide: full/reduced command signatures, namespace and
  permission prerequisites, retained artifacts, and CTest versus integration scope.

A must provide a supported configured ABI/build and disclose any changed test
host naming. B must provide installed documentation layout/probe compatibility
before final full integration. Final package docs exclude automation-product
references except creation credit; identifiers in code/tests/tools are not banned.
C does not edit B's audience/navigation/install-manifest files concurrently.

Reuse unchanged native probe, fixture provenance, runtime-closure and boundary
qualifications with their original limits; never relabel old evidence as a fresh
run. Rerun changed tests and final orchestration once, expanding only for a failure
or changed input. No additional review bureaucracy, duplicate qualification ledger
or exhaustive upstream diagnosis is needed.

Rollback is limited to this future change set: revert C-owned hunks/test changes
while preserving A/B and operator work; remove only exact new temporary copies,
run directories and fresh prefixes created by the implementer after inspecting
their paths. Never reset the whole worktree or delete shared roots. Preserve
failure evidence and truthful limitation corrections even if code work is deferred.
