# Implementation and qualification plan

Updated exit report, 2026-10-15. M0 is pending review; M1–M5 are not qualified. [SPEC](SPEC.md) is the contract;
[DESIGN](DESIGN.md) the architecture; [coverage](COVERAGE.md) the scope.
Deployment policy stays in [operations](../workflows/OPERATIONS.md).

## M0 — Decisions, dependencies and real fixture readiness

### Consolidated M0 gate matrix — 2026-10-15, pending review

**M0 is pending review, not accepted.** The scoped prerequisite passes below are
an integrated exit report for review R1, not reviewer approval or authorization
to implement M1. “Passed” means only the stated planning/source-accounting or
native guest experiment. “Open” identifies an outstanding review or unsupported
path; “Deferred” identifies a mandatory later gate, not a waiver. No unavailable
external input blocks this reporting correction.

Evidence baseline: legal delivery `dbd2251` ([[card:card-a-a]]), native profile
`a4c15fa` ([[card:card-a-b]]), inventory `8940dfa` ([[card:card-a-c]]) and fixtures
`ecb5f0e` ([[card:card-a-d]]). Retained execution evidence is reused with unchanged
code, dependency pins and fixture inputs; no unchanged builds were repeated for
this documentation correction.

| Gate | Disposition and exact scope | Evidence / limits / blocker |
| --- | --- | --- |
| Authority, platform, surfaces and tier | **Passed — decisions settled.** Accepted baseline `6d023d7`: Linux x86-64, PUC Lua 5.4/64-bit integers, two public layers over one native owner, core then full. Native-local only; HTTP/remote and SWIG excluded. Lua 5.3 needs independent later qualification. | [Launch authority](../workflows/LAUNCH.md), [SPEC](SPEC.md), [DESIGN](DESIGN.md). No renewed platform/tier/two-surface decision required. No M1 implementation acceptance inferred. |
| Wrapper MIT and upstream license planning closure | **Passed — planning only.** MIT, Copyright 2026 Salvador Fandiño, for original wrapper code/docs. Operator accepted existing upstream license for project planning and closed licensing research; no repeated applicability/permission prerequisite. | [LICENSE](../LICENSE), [bounded license report](M0-LICENSE.md), [launch disposition](../workflows/LAUNCH.md#operator-disposition--licensing-research-done-for-planning). Not legal clearance, combined-license compatibility proof, a new rightsholder grant or upstream relicensing. |
| Intended use and distribution limits | **Passed — bounded planning use recorded; Deferred — actual distribution approval/compliance.** Target is native-local Lua binding and eventual CMake/LuaRocks source installation, standalone/embedded hosts, core then full; current artifacts are development probes, not a distributable Lua module. No push/publication authorized. | [SPEC](SPEC.md), [M0-LICENSE](M0-LICENSE.md), [native notices](evidence/native-notices). HOS, GPL BFD/sframe and all transitive notices/source obligations remain; actual distribution form, linked closure, notices/corresponding source and operator publication direction are packaging/release gates, not planning blockers. |
| Exact native inputs and offline/toolchain/transitives | **Passed — locked Ubuntu 24.04 amd64 guest SDK.** libghidra `d51ca813ae1b6b59519551a9be8c0b1ad74d862d` (reports 0.0.9), engine `2035b8153afaf7ce2edde24a2c80b62bbcf5127f`, specs Ghidra 12.1.3 build/20260817; protobuf v29.3 (CMake 29.3.0), Abseil 20240722.0, httplib v0.16.3, protobuf-bundled utf8_range and engine-bundled zlib. GCC 13.3.0 Ubuntu, CMake 3.28.3/C++20; Lua 5.4.6 is the development target, not a linked binding qualification. Fresh archive-verified network-disabled build/install succeeded. | [Input URL/SHA256 lock](../native-inputs.lock.json), [system binary/source lock](../native-system.lock.json), [toolchain/package identities](evidence/native-toolchain.txt), [readiness and offline recipe/log links](NATIVE-READINESS.md). Nine system binary packages locked/download-verified; six source control documents record source archive hashes, not all source archives downloaded/built. Guest-specific, not portable packaging. |
| Engine/spec/BFD/PIC and source overrides | **Passed — separate authorized profile only.** Bundled `bfd-sleigh-target-autodetect` patch SHA256 `488eda3edc8c26cc93155240663f20d0512318428c4b69e2fbb3b409989ac82d`; only two engine files changed, libghidra authored sources unchanged (normal generator output excepted), spec overlay bytes verified. Default/unmodified profile preserved. Shared BFD 2.42 explicitly selected with shared sframe/zstd; no libiberty.a. PIC proven by installed WHOLE_ARCHIVE shared `-z defs` link, exact Protobuf CONFIG. | [Patch/base/authorization lock](../native-patched.lock.json), [source integrity](evidence/native-patched-source-integrity.log), [profile controls](evidence/native-patched-qualification.log), [installed consumer](../tests/installed-sdk/CMakeLists.txt). All `NATIVE_{LIBGHIDRA,ENGINE,PROTOBUF,ABSEIL,HTTPLIB}_SOURCE` overrides supported; arbitrary overridden edits are caller responsibility, not certified by locks. No configure-time FetchContent download. |
| Spec profiles and loader controls | **Passed — x86 ELF semantics, external and embedded, explicit hint and auto.** Cold/warm/warm-unwritable embedded cache controls pass; missing/unreadable external roots and cold-unwritable HOME fail at actual open as expected. | [Patched qualification](evidence/native-patched-qualification.log), [readiness](NATIVE-READINESS.md). **Open limitation:** actual raw .text/reconstructed FileBytes memory route remains unsupported by BFD capability selection, not repaired by the authorized target patch. This does not block the qualified external-ELF project route; no all-architecture/spec compatibility claim. |
| Python/zlib build vs runtime and native authority | **Passed — development/build separation.** Source embedding uses Python >=3.10 with importable zlib (recorded Python 3.12.3/zlib 1.3); preparation uses Python 3.12 safe extraction. Installed native SDK/probes require no Python/Java/Lua runtime or network. Shared closure is BFD, zlib/zstd/sframe, C/C++ runtimes. Native API/direct C++ probes authoritative; upstream Python bindings are not a build/runtime/required-test dependency. | [Toolchain](evidence/native-toolchain.txt), [linked closure/profile log](evidence/native-patched-qualification.log), [superseding Lua-native policy](../workflows/LAUNCH.md#operator-update--lua-based-deliverable-no-python-binding-dependency). Development Ghidra/Java used only for fixture generation. System zlib is also a native runtime dependency, distinct from Python's importable zlib check. |
| Exhaustive native operation/field inventory | **Passed — source accounting at pinned API, not runtime coverage.** 70 included/40 excluded service operations; 160 models/466 direct fields; 156 direct and 20 nested request paths, 345 expanded response paths, four factory options. Recursive cross-ledger/source checks and corruption tests retained (51 tests OK). HTTP-only stubs excluded, not misrepresented as local implementations. | [Human ledger](../api/coverage.md), [machine ledger](../api/coverage.json), [validator](../scripts/inventory_completeness.py), [regressions](../tests/test_inventory_api.py). All runtime qualification slots remain unqualified; sixty later grammars are proposals. Existing Python research is historical development reference, not mandatory parity/oracle. |
| Authored binary semantics and repeatable inputs | **Passed — real x86 ELF.** Authored MIT source, GCC flags, hashes, symbols, entry bytes `f3 0f 1e fa`/four-byte ENDBR64 and completed nonfallback `x * 3 + 7` semantics retained. | [Fixture provenance/commands](../tests/fixtures/README.md), [hash manifest](../tests/fixtures/SHA256SUMS), [qualification](evidence/fixture-qualification.log). Direct native probes, not nonempty pseudocode alone. |
| Real analyzed-project semantics | **Passed — supported no-FileBytes external ELF override route.** Real Ghidra 12.1.3 ProgramDB generated with Java 21.0.12.1, autoanalysis/reference index. Completed nonfallback arithmetic; exact leaves 0x401106/0x40113c (not main), call xref to 0x401106, native comment roundtrip and discovered DWORD at 0x404010/size 4. Missing project fails despite valid ELF override. | [Generator/provenance](../tests/fixtures/README.md), [generation log](evidence/fixture-generation.log), [direct probe](../tests/project_probe.cpp), [qualification](evidence/fixture-qualification.log), [negative](evidence/fixture-missing-project.log). Native names/leaves imported, not all Ghidra prototypes/comments/data; arithmetic may show `unaff_EDI`. Comment is native mutation; data is native discovery. No reconstructed FileBytes/raw-route success claimed. |
| Tooling migration and retained-generator exceptions | **Deferred — mandatory before release.** Migrate project-owned Python tools/tests to Lua; retained Python needs compelling reason, alternatives and explicit operator acceptance. Upstream embedding generator is only a candidate exception, not permanently approved. | [Current policy](../workflows/LAUNCH.md#operator-update--lua-based-deliverable-no-python-binding-dependency), [SPEC](SPEC.md), M5 below. No upstream Python-binding dependency may be introduced. Not an instruction to erase historical scripts/evidence or block bounded M0 source accounting. |
| Integrated M0 acceptance | **Open — pending review.** This matrix and card status supply the R1 exit report/root handoff. Scoped prerequisites above have evidence; reviewer re-review and owning-session acceptance remain outstanding. | Original review `record:///review.md?card=card-a&v=3` R1; root handoff in [[card:card-a-d]] status. No root brief edited and no reviewer approval invented. |

### Historical failures and later obligations

Retained [NATIVE-READINESS](NATIVE-READINESS.md) distinguishes unmodified-engine
explicit-hint/raw failures from authorized patched-profile passes, the initial
spec-overlay integrity comparison failure from its corrected check, and the
masked unreadable-root command from its corrected actual-open failure. Retained
`fixture-*-attempt.log` files record generator/compilation/xref attempts; later
success does not erase them. The raw-memory limitation above remains current.

M0's bounded passes do not satisfy M1 ownership/value/longjmp/sanitizer gates,
M2 both Lua surfaces/first-slice semantics, M3 core positives/state persistence,
M4 full local operation positives or M5 release/install/offline/embedded and
notices/source qualification. All later exits below remain required. Distribution
compliance and Lua tooling migration/any retained exception approval are separate
later obligations without waiver. Publication still requires operator direction.

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
M0 fixtures. Use Lua acceptance tests and direct native probes with identical
pin/architecture/specs and authored expected results. Optional development Python
comparisons are nonauthoritative and not a gate. Test false/zero, optional/nested values,
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
headers against LocalClient overrides; each omission has a tier/reason. Python
bindings are optional historical reference, not a required dependency or target.
Test ignored mutation fields (DeleteSymbol name, CreateType/AddTypeMember size,
CreateTypeEnum width/is_signed) and unsupported CreateType kinds; preserve the
documented limits rather than promising enforcement of ignored arguments.

Exit: every local operation accounted for and supported cases demonstrated.

## M5 — Required for every release tier

From clean directories run CMake/LuaRocks offline install, standalone/embedded
hosts, values, lifecycle/fault injection/sanitizers, pagination, real binary and
analyzed fixtures through Lua tests and direct native probes as needed. Verify
required tests/build/runtime do not depend on upstream Python bindings. Finish
migration of project-owned tooling to Lua; retain Python only with a documented
compelling reason and operator acceptance, including any upstream generator
exception. Run both DESIGN
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

Settled decisions: Linux x86-64/Lua 5.4, two public layers over one owner,
core then full, wrapper MIT, upstream license accepted for project planning,
and the narrowly authorized engine patch profile (see matrix above). They are
not awaiting renewed approval. Still outstanding: M0 review/acceptance, later
implementation qualification, packaging/distribution compliance and intended
shipment details, tooling migration or expressly accepted exceptions, and any
publication direction. Technical passes do not substitute for these later gates.
