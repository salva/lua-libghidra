# Implementation and qualification plan

Proposed, 2026-10-15. No milestone has passed. [SPEC](SPEC.md) is the contract;
[DESIGN](DESIGN.md) the architecture; [coverage](COVERAGE.md) the scope.
Deployment policy stays in [operations](../workflows/OPERATIONS.md).

## M0 — Decisions, dependencies and real fixture readiness

Confirm baseline/platform/tier and license applicability before implementation.
The wrapper license is MIT (operator-selected; see [LICENSE](../LICENSE)).
Record intended distribution, dependency sources/digests,
spec compatibility, deterministic BFD profile and notices. Inventory every native
and Python local operation and every request/response field in `api/coverage.*`.
Mark HTTP-only stubs excluded; they are not local implementations.
Check source-build Python >=3.10 and importable zlib early; record build-tool and
qualification-oracle versions separately from the Python-free runtime profile.

Create authored redistributable binary source and compiler/flags/source-hash/
binary-hash manifest with known symbols, bytes and instruction expectations.
Generate a real analyzed-project fixture (development Java/Ghidra allowed),
record generator versions, commands and artifact hashes. Exercise leaf queries,
xrefs, comments and data. Prove native local loading and completed nonfallback
decompilation with expected semantics on known code. Nonempty pseudocode or an
unsupported response is not readiness.

Exit: repeatable offline inputs and positive native evidence for binary and
analyzed fixtures; open engine/spec/licensing gates block M1 rather than waiting
for packaging. This document does not authorize implementation.

## M1 — Build, ownership and value boundary

Build source/installed-SDK whole-archive paths with PIC; test standalone and
shared/static embedded C-built Lua. Implement exact values, errors and shared
handle. Qualify every-frame longjmp safety, allocation-failure publication and
conversion, native exceptions, __close error preservation, surviving aliases,
double-finalization resistance and ASan/UBSan. Test process guard across states,
client B after A close, and engine globals/init/destruction. Retain sol2 only if
audit passes; otherwise direct C API with unchanged public surfaces. No SWIG.
Test ReadBytes boundary validation at zero, INT32_MAX, INT32_MAX+1 and UINT32_MAX:
oversized rejection must precede native dispatch/requested-buffer allocation.
Upper accepted-bound validation needs no multi-gigabyte read; real small reads
are M2's positive integration cases.

Exit: reproducible local-enabled installed load, no second VM, exact numeric
conversion and safe failure/teardown; no broad adapters before this gate passes.

## M2 — Both surfaces, first usable slice

Implement first-slice coverage on lowlevel and Session: factory/open/close,
status/capabilities, function lookup/pages/iterator, bytes, instructions and
decompilation. Preserve full responses and missing-record/unsupported distinctions.
Exercise known bytes/instructions and semantic nonfallback decompilation using
M0 fixtures. Qualify Python oracle with identical pin/architecture/specs; compare
normalized fields, not formatting. Test false/zero, optional/nested values,
uint64 boundaries, zero-based ordinals, flags and outcome presence.
Execute SPEC's first-slice grammar and EXAMPLES with real manifest inputs;
verify open's third-result metadata without reopening, including false/zero
fields and retention after later close. Capability output must remain faithful
without being treated as a precise operation-support oracle. The mutation example
is an M3 extension, not an extra first-slice adapter requirement.
Test explicit zero range_end (Lua integer and UInt64), omitted/default maximum
and ordinary inclusive bounds, including positive start with zero end. For
instructions use a manifest-known code start and unmapped/gap cases: empty output
is not evidence of no code elsewhere. Check ReadBytes oversized errors through
both views without allocating requested buffers.
Test logical close through one view and NO_PROGRAM reads through the other,
usable owner-level status, reopening the same owner through native(), permanently
invalid old iterators and retained historical metadata. A program close must not
release the process client slot; owner close must release it and make aliases
CLOSED. Verify source/resource lifecycle without treating logical close as engine
unloading or claiming failed close succeeded.

Exit: positive real-engine cases through both surfaces, installed examples and
negative/fallback diagnostics; no runtime Python/Java/network dependency.

## M3 — Core operations and robust iteration

Implement core inventory; register fields and dispatch mutation classifications
as each lands. Test compound INT_MAX boundaries, positive page sizes,
empty/exact/partial/capped pages, stable serial CFG/block order, stalled pages,
errors and early exit. Test generation invalidation across native escape-hatch
calls and before buffered yields. No universal snapshot claim.
Verify signature candidate-offset/filtering semantics as page calls only; require
no signature iterator. Qualify defined-string empty-success fidelity on a fixture
with known strings, unloaded error and argument validation; no populated-page or
discovery gate applies to this constant-empty compatibility operation.

Verify per-category save/reopen on disposable fixtures, no-op discard,
empty-state-path facade save rejection versus native behavior, nonpersistent
byte overlay and destructor no-save. Every supported core row needs a positive
test; negative NOT_SUPPORTED alone cannot satisfy it. The explicitly classified
defined-string stub satisfies only the fidelity gate above. Execute the M3 native
mutation/invalidation example with a disposable fixture.

Exit: all core rows qualified/documented. Route core release through M5 now;
M4 is not a prerequisite for a labelled core release.

## M4 — Full native local coverage

Complete full-tier inventory: native batch decompilation, project-backed leaves,
type/enum/member edits, parameter/local edits, data edits, patch batches,
performance records and local Shutdown. Each service slice includes positive
supported cases, errors, complete field maps and low/high-layer dispositions.
Preserve actual batch semantics without invented atomicity. Reconcile public
headers against LocalClient overrides and Python; each omission has a tier/reason.
Test ignored mutation fields (DeleteSymbol name, CreateType/AddTypeMember size,
CreateTypeEnum width/is_signed) and unsupported CreateType kinds; preserve the
documented limits rather than promising enforcement of ignored arguments.

Exit: every local operation accounted for and supported cases demonstrated.

## M5 — Required for every release tier

From clean directories run CMake/LuaRocks offline install, standalone/embedded
hosts, values, lifecycle/fault injection/sanitizers, pagination, real binary and
analyzed fixtures and required normalized Python comparisons. Run both DESIGN
profiles: explicit external roots (valid/missing/unreadable), and empty-root
embedded specs (isolated cold/warm/unwritable HOME cache), proving constructor
selection for each. Test runtime network/Java/Python absence. Record exact
compiler/engine/spec/Lua/dependency identities and actual linked licenses/PIC.
Ship API reference, manifest, examples, limitations, license/source links and
visible attribution. Missing tests block qualification; publication requires
operator direction. Lua 5.3 independently passes equivalent gates.

Sequence: M0 → M1 → M2 → M3 → M5 (core), then M4 → M5 (full), or M4 before the
first M5 for a full-first release. Commit each implemented slice promptly.

## Review completion and operator decisions

Writer corrections are not reviewer approval. Original reviewers must re-review
their findings, then fresh independent rounds must return no unresolved findings
before the owning session declares convergence. Record each round and stable
dispositions in [the index](reviews/00-INDEX.md); never invent review results.
This writer does not spawn reviewers.

Remaining operator decisions: approve two-surface/default restrictions, confirm
upstream/platform and first release tier, confirm intended distribution and record
upstream applicability determination. MIT is already selected for the wrapper.
Technical experiments are
objective M0/M1 gates above, not substitute operator choices.
