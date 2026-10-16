# Source-only developer index

This index is not installed package documentation. The maintained user layer is
[README](../../README.md), [guide](../EXAMPLES.md), [API](../API.md),
[notices](../NOTICES.md) and generated [FIELDS](../../api/FIELDS.md).
API is the single current call/default/envelope/limitations authority. Requirements
belong to [SPEC](../SPEC.md), architecture to [DESIGN](../DESIGN.md), delivery
sequencing to the accepted implementation contract; source accounting/methodology
belongs to [COVERAGE](../COVERAGE.md) and [api README](../../api/README.md).
Read [AGENTS](../../AGENTS.md) and the
[validation skill](../../.github/skills/lua-libghidra-validation/SKILL.md).

## Evidence is revision-scoped, not a second manual

[PLAN](../PLAN.md) is original historical planning, not today's installation or
execution-order authority. Retain the [M0 license report](../M0-LICENSE.md),
[M1 boundary](../M1-BOUNDARY.md), [M2](../M2-SLICE.md), [M3](../M3-CORE.md),
[M4](../M4-FULL.md), [installed core](../INSTALLED-CORE.md),
[installed full](../INSTALLED-FULL.md), [crosswalk](../FULL-CROSSWALK.md),
[readiness](../NATIVE-READINESS.md), [foundation](../PACKAGE-FOUNDATION.md) and
[handoff](../PACKAGE-HANDOFF.md) as dated developer evidence at their original
paths. Old commands/claims do not override the maintained manual. Raw artifacts,
locks, license source TSV and historical ledgers remain unchanged.

Current corrections consume A `0013ea8`, C `3205ef4`, and fields/notices `45222bd`:
Session reopen uses six raw keys/full response; shutdown shares the save guard.
Measured specialist evidence observes actual member/alias/enum/parameter edits,
true-local rename and **failed** char retype, enum width eight rather than requested
width (not runtime proof of ignored signedness), and inferred data after named
symbol deletion. Save/reopen keeps only a struct shell among the exercised new
categories; binary int-signature evidence is parameter-only, project true-local
rename resets. Historical broad persistence/local claims are not rewritten into
new evidence. No historical GetRevision test is cited: batch3 measured real
integer file_version (zero) and UInt64 IDs/counter, representation only, not a
populated producer or durability claim. Generated runtime slots stay unqualified.

## Source tooling and SDK

From the checkout, define absolute PINNED_SOURCE, FRESH_JSON and FRESH_WORK;
the output paths must not already exist:

```sh
lua5.4 scripts/inventory-api.lua "$PINNED_SOURCE" "$FRESH_JSON" --coverage
lua5.4 scripts/check-tooling.lua "$PINNED_SOURCE" "$FRESH_WORK"
# Review candidate semantic diff before replacing current api/coverage.json.
lua5.4 scripts/render-fields.lua
lua5.4 scripts/render-fields.lua --check
```

No second API generator or shipping inventory. Historical ledger/digests are not
generation input. See [api tooling](../../api/README.md).
For a reusable local SDK, after the guide's verified preparation, define absolute
INPUTS, fresh SDK_WORK and SDK, then from the checkout run:

```sh
BUILD_JOBS=4 sh scripts/build-native-sdk.sh "$INPUTS" "$SDK_WORK" "$SDK"
```

Inspect this [builder](../../scripts/build-native-sdk.sh) before use: it installs
PIC Protobuf/Abseil, source native dependencies and validates the SDK consumer;
it is not merely wrapper installation. Do not run with an arbitrary system BFD
static closure. The narrow unchanged upstream source-generator Python exception
is not permission for project-owned Python tooling or SDK/runtime Python.

## Explicit integration command contract

The C-owned [driver](../../tests/installed-qualification.sh) requires absolute
BUILD, fresh PREFIX and existing writable WORK_ROOT. Full is the default but
use explicit modes in evidence. Full also requires EXTERNAL_SPECS and available
non-root namespace/tool/fixture prerequisites:

```sh
bash tests/installed-qualification.sh --build "$BUILD" --prefix "$PREFIX" \
  --work-root "$WORK_ROOT" --external-specs "$EXTERNAL_SPECS" --mode full
bash tests/installed-qualification.sh --build "$BUILD" --prefix "$OTHER_FRESH_PREFIX" \
  --work-root "$WORK_ROOT" --mode reduced
```

No ambient skip variable changes selection. Reduced reports omitted groups;
it is not full qualification. Current driver intentionally stops at the pending
package-document manifest boundary; neither mode can yet claim end-to-end success.
Batch5 must integrate configure export, B checkers/probes and C staged callers.
Both modes require pristine source/installed document checks; full alone runs
mutation probes. Future exact B/C interfaces (all path arguments absolute):

```text
lua5.4 tests/installed_documents.lua source SOURCE_ROOT MANIFEST
lua5.4 tests/installed_documents.lua installed DOCUMENT_ROOT SOURCE_ROOT MANIFEST
bash tests/installed-documents.sh DOCUMENT_ROOT SOURCE_ROOT MANIFEST FRESH_WORK
```

MANIFEST is that producing build's package-documents.txt, DOCUMENT_ROOT its actual
share/doc/lua-libghidra directory (LuaRocks uses its confirmed versioned package
prefix). No fallback signatures or inferred sibling manifest. These interfaces
are the batch5 handoff, **not yet implemented acceptance**. Clean source/SDK ×
CMake/LuaRocks installation, installed example/external+embedded checks, document
closure/equality/content/probe sensitivity, C full/reduced sensitivity and final
A facade/ABI siblings remain required. Prior 18/18 CTest is bounded native evidence,
not final integrated acceptance. Website/publication and distribution clearance
are separate; no push is authorized.
