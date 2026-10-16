# M3 core adapter batch — implementation, not complete M3 qualification

Original wrapper MIT, Copyright 2026 Salvador Fandiño. Locked native-local
profile unchanged. No new dependency patch or distribution permission.

The single owner dispatch now implements all 22 previously absent core methods.
Packet owns each complete response before protected conversion. All new converter
frames hold only borrowed references/scalars. Request parsing holds only borrowed
Lua-rooted text and scalar Page/address fields; text and byte-vector copies occur
inside the caught native phase with no Lua calls. Exceptions/locks end before
publication, Packet destruction precedes Lua error rethrow. Existing generation
predicate and iterator entry/post-publication/buffered-yield checks are unchanged.
Generation increments before dispatched save/discard/rename/write calls, including
native failures; validation failures do not increment. Text is length preserving,
including NUL; bytes are binary strings. No replacement backend results.

## Grammar and field manifest

`api/coverage.json` (generated source facts; original M3 runtime/manual annotations retained in `api/history/coverage-m3.json`, runtime index in `api/runtime-evidence-m3.json`) remains the exact native field/type/default ledger. Every
response field of the following native models is converted explicitly by
`src/core_convert.hpp`, including all booleans, empty strings, nested parameters,
UInt64 identifiers/ordinals and signed offsets/enum values. Response envelopes in
`src/owner.cpp` preserve all fields; known CommentKind values use lowercase names,
unknown values numeric. No renaming or ordinal adjustment.

| Calls | Grammar (both lowlevel and facade unless noted) | Complete response |
| --- | --- | --- |
| save_program, discard_program | `()`; discard native() only | saved / discarded |
| rename_function, rename_symbol | `(address, new_name)` | renamed, name |
| get_symbol | `(address)` | optional symbol: SymbolRecord |
| get_type | `(path)` | optional type: TypeRecord |
| get_function_signature | `(address)` | optional signature: FunctionSignatureRecord + ParameterRecord |
| list_basic_blocks, list_cfg_edges | `(range_page)` | blocks: BasicBlockRecord / edges: CFGEdgeRecord |
| list_symbols, list_xrefs | `(range_page)` | symbols: SymbolRecord / xrefs: XrefRecord |
| get_comments | `(range_page)` | comments: CommentRecord |
| list_function_signatures | `(range_page)` | signatures: FunctionSignatureRecord + ParameterRecord |
| list_defined_strings | `(range_page)`; native() only | strings: DefinedStringRecord (native constant-empty) |
| list_memory_blocks | `(count_page)` | blocks: MemoryBlockRecord |
| list_types, list_type_aliases, list_type_unions, list_type_enums | `(query, count_page)` | types: TypeRecord / aliases: TypeAliasRecord / unions: TypeUnionRecord / enums: TypeEnumRecord |
| list_type_enum_members, list_type_members | `(type_id_or_path, count_page)` | members: TypeEnumMemberRecord / TypeMemberRecord |
| write_bytes | `(address, binary_string)` | bytes_written (uint32 integer) |

Text arguments are required strings, including empty strings as native inputs.
Count pages accept **only** limit/offset; range pages additionally accept
range_start/range_end. Omitted page defaults to limit=100, offset=0 and full range;
positive sizes and compound INT_MAX bounds use the existing checked primitive.
Write data length is bounded by INT_MAX before vector allocation/dispatch.
Facade lookups unwrap optional records and preserve the third envelope; missing
records yield NOT_FOUND. Mutation/page conveniences preserve complete responses.
No new iterators are claimed by this batch. Signature candidate filtering remains
pages-only; DefinedStrings has no scanner or iterator.

Facade save-close consults an immutable construction-time nonallocating owner
predicate for state_path, not a facade program cache. With no state_path it returns
binding NO_STATE_PATH before native dispatch/generation change. Unknown options
still return INVALID_ARGUMENT. Closed owners defer to dispatch for CLOSED.
Lowlevel save-close behavior is unchanged (can close without saving).

## Evidence and observed limitations

- Original `tests/m3_core_reproducer.lua` preserved unchanged, now passes against
  installed real module for authored ELF and analyzed project.
- `tests/m3_core.lua` exercises real loaded reads/pages, signature, symbol/type
  lookup, rename outcomes, NUL byte overlay/readback, no-op discard, unloaded
  errors, validation/compound limits and mutation invalidation of buffered function
  iteration. Runs installed standalone and shared/static existing Lua VMs.
- `boundary_host` sweeps all 15 core record converters with persistent Lua refusal,
  same-VM retries, detached false/zero/NUL, uint64 max, int64 min, signed offset,
  nested parameter and unknown-enum assertions. This is fidelity, not native
  production evidence for populated subtype records.
- `read_order_host` adds real loaded M3 result/error Lua refusal and three boundary
  exception kinds with same-owner retries for every new core adapter except save
  (save positive/state path remains outstanding). No dependency OOM sweep.
- GetType's `path` is passed faithfully to native findByName. Initial test used
  ListTypes.path_name (leading slash) and got NOT_FOUND. Using returned name
  succeeds. This is the pinned lookup contract, not wrapper path normalization.
- Current warmed fixtures produce blocks/symbols/xrefs/signatures and memory/type
  records; CFG edges and comments are empty. Subtype pages currently prove empty
  success only. Rename produces native overlap warnings; outcomes/readback are
  retained, no engine repair. Existing M2 extreme-address crash, missing producer
  fields/tokens, raw FileBytes and dependency-internal OOM limits still apply.

## Unmet consolidated M3 acceptance

This batch fixes the reproduced absent-adapter/save-policy gap, not every M3 exit.
Still required: populated supported subtype/CFG/comment evidence where available
(or proportionate practical-limit attribution), signature candidate-filter cases,
known-string fidelity fixture assertions, per-family serial order/qualified
iterators and stalled/capped/error/finalizer-mutation paths, per-category disposable
persistence/reopen/destructor tests and installed mutation example. Request-copy
fault injection and loaded finalizer coverage for newly allocating M3 requests
need extension beyond existing M2 coverage. Reconcile per-operation runtime slots
in api/coverage.* as those gates settle, and obtain independent workflow review.
No global snapshot, full M3 approval or release acceptance inferred.

## Serial iterator batch

`lua/libghidra/iterator.lua` owns bounded progression and failure handling for
**functions, symbols and memory blocks only**. Symbols compare native traversal
symbol_id (assigned before pagination), identity address + length-delimited
name/namespace; memory compares start/name; functions compare entry address.
No sorting or deduplication is applied. Qualified authored serial pool_size=1
paths are not arbitrary-engine snapshots; nonadvancing/duplicate pages fail.

**R1 correction: blocks, CFG and xrefs are pages-only.** The block numeric tuple
is disproved by actual conditional structural order; xrefs concatenate calls then
load/store phases, with no qualified faithful comparator. Both public iterator
descriptors were removed, not disguised as safe-stall traversal qualification.
DESIGN requires qualifying order before enablement. No ordinals, history cache,
sorting or engine patch is introduced. Repeated full/singleton/end native pages
remain covered; block/CFG/xref iterator absence is asserted on real Sessions.

The shared primitive checks generation at entry, after fetch publication and
before buffered yield, including after identity/key allocations. It retains
only one page's identity set and last tuple; no unbounded history. An offending
page/error ends traversal. Offset advances by actual count, short/capped pages
continue, and arithmetic stays within compound INT_MAX bounds.

**ListTypes remains pages-only with real limitation evidence:** an attempted
iter_types failed the duplicate-identity guard. Both real warmed fixture routes
return multiple anonymous records with path_name="/"; native dependentOrder
constructs path_name as "/" + getName(), while type_id is only a traversal counter.
DESIGN's canonical path identity is therefore insufficient. Do not substitute
that ephemeral counter as identity, silently deduplicate or fabricate paths.
`tests/m3_iterators.lua` asserts the collisions and absence of iter_types; this is
a practical native identity limitation, not a wrapper-positive iterator claim.
Other unqualified subtype/CFG/comment families remain pages-only pending their
original qualification/limitation disposition. Signatures/DefinedStrings retain
their explicit no-iterator contracts.

`tests/m3_iterators.lua` compares two serial scans to real full pages at page
sizes 1/2/100 on ELF/project, covers empty offsets, validation, early exit and
native discard invalidation of each family. Primitive fixtures cover short caps,
duplicate/reversed/oversized pages, no retry after error, structured native errors,
and actual Lua finalizers mutating generation during publication/key/buffer phases.
These primitive fixtures are not real-backend operation positives. Installed
qualification executes the test with standalone and shared/static existing VMs.

## Persistence/signature/string follow-through

`tests/m3_persistence.lua` requires a caller-supplied disposable directory for
state, never writes fixture state. Real save/reopen restores renamed function
symbol; separately, a NUL byte overlay survives DiscardProgram but does not survive
owner destruction/reopen even after saved=true. An unsaved subsequent rename is
not autosaved by destructor. Positive configured facade save-close is exercised.
This is **function-symbol category evidence only**, not proof all categories
persist. Type/comment/signature/data/benchmark category probes remain outstanding.
The installed qualification script executes it when the active card work root is
provided. `examples/core_mutation.lua` is now installed/executed and asserts the
native renamed flag and buffered function-iterator invalidation.

`tests/m3_core.lua` now asserts actual .interp bytes at 0x400318 equal
"/lib64/ld-linux-x86-64.so.2" + NUL on both real fixture routes before asserting
DefinedStrings empty success. This is a known loaded string, no discovery claim.
Signature singleton pages are compared with candidate-function offsets, including
past-end emptiness. Missing-signature filter cases remain unqualified; all exercised
candidates produce signatures, not evidence the producer never filters.

## Wrapper request-copy and loaded finalizer batch

All allocating M3 text requests now copy to owned request_text before taking the
engine lock/incrementing generation, just as WriteBytes already owns its vector.
No Lua calls occur in that phase; copy exceptions return NATIVE_EXCEPTION before
SDK dispatch. This settles the request-allocation edge at its owning primitive,
not in per-method symptom handlers. Request strings remain Lua-rooted during
parsing, and owned text/vector storage is destroyed before protected publication.

`read_order_host` refuses the first non-SSO wrapper copy for rename function/symbol,
write bytes, GetType and every type page family. For each it asserts no adapter
boundary was reached, exact outstanding C++ block/byte balance, structured native
exception or actual Lua refusal, then normal known-byte/status use on the same
owner. Persistent Lua error-publication refusal is swept too; early Lua table
allocation refusal before the copy is distinguished, not miscounted as a copy
fault. No dependency allocation is faulted. Initial host attempts exposed two
fixture errors: stale ReadBytes observer counters in recovery calls, and assuming
the C++ copy is reached despite earlier Lua page-table OOM. Corrected assertions
preserve both distinct paths rather than disabling balance/no-dispatch gates.

`reentry_host` adds all newly allocating M3 request families and core loaded
reads/pages/mutations (except save) on ELF and project. Actual allocation-driven
finalizers must run in post-dispatch protected-publication phase 3, close the owner
and construct/destroy a replacement. Detached response tables remain rooted;
read generation=2 and mutation generation=3 prove open/dispatch/release ordering.
Existing M2 nested-content assertions still run. Empty subtype responses prove
publication/lifetime safety only, not populated subtype acceptance. Initial
GetComments trial incorrectly supplied address scalar instead of range options,
so never reached native conversion; corrected grammar then observed phase 3.
Save success/finalizer publication with configured state still needs extension.

## Direct native category persistence limitation probe

`tests/m3_category_probe.cpp` (installed-SDK consumer target) isolates categories
whose mutation adapters are full-tier, without shipping new M4 Lua mutations.
On the locked x86 ELF profile, actual native outcome flags are true for struct,
member, alias, enum/member, signature, comment, data and benchmark edits. Before
save: aliases/enums/struct-members/enum-members/comments/data/benchmarks each have
one record. SaveProgram returns saved=true. After owner release/new owner/open with
the same state path: every counted category is empty. State XML exists; OpenProgram
calls pool loadState best-effort without propagating reload failure. This directly
reproduces loss without Lua/wrapper and is a practical persistence limitation of
this exercised native profile, not proof of all causes or that every signature
field is lost. Function-symbol restoration separately passes the Lua regression.
No upstream repair or blanket category-persistence promise follows. Real Lua
populated subtype/comment evidence still requires a seeded input route that
survives load or an in-process fixture host; this native-only probe does not satisfy
that gate. Missing signature-filter, union/CFG and remaining Lua evidence stay open.
Build/run with tests/installed-sdk and a caller-supplied disposable state path;
never use fixture directories for mutable state. Initial generated flag assertions
had a parenthesis compile error; corrected before running, no ignored build failure.

## Real populated Lua fixture host

`m3_seeded_host` uses a compile-guarded `LLG_CORE_FIXTURE` callback after successful
native open, with no Lua calls during setup, to seed the same real native owner
through public C++ mutations. It does not mock IClient, alter responses or export
M4 adapters in production. `tests/m3_seeded.lua` calls the actual core Lua methods
on ELF and analyzed project and checks populated alias/enum/enum-member/struct-member,
comment and signature data, zero UInt64 ordinals, signed member offsets, booleans
and first/end singleton pages. This closes the previous populated Lua evidence
for those families without relying on the lossy state reload. The host has no
persistent state and closes all owners; fixture files remain unchanged. CTest now
includes m3_seeded_core. Production owner compilation excludes the seed callback.
The direct category probe now asserts both populated pre-save counts and observed
empty post-reopen counts and saved=true, instead of merely logging them. Unexpected
future persistence changes fail rather than being normalized into this limitation.

Still open: populated union and nonempty CFG, missing-signature filtering,
remaining iterator family dispositions, category-specific signature persistence,
configured save-success finalizer and final runtime ledger/review closure. No
broad native persistence or new Lua full-tier mutation support is claimed.

## Conditional CFG and real iterator/save publication follow-through

`tests/fixtures/branch.c` builds only in a purpose-named disposable work child.
`tests/m3_branch.lua` exercises the installed module on this authored x86 ELF:
four real blocks and four edges (TRUE/FALSE/FALL_THROUGH), repeated singleton
pages in exact native serial order, including end offset. Native structured block
order is 0x40110a, 0x401125, 0x401117, 0x401131, **not numeric address order**.
The former enabled numeric comparator stalled after two singleton records, or
before any full-page record: original reviewer R1 correctly rejected that as
pre-enable qualification. Blocks and CFG now remain pages-only without a qualified
structural comparator; tests preserve the counterexample and positive full and
singleton repeatability. Xrefs likewise remain pages-only for call/load phase order.

The seeded native host now tries union construction through public CreateType:
locked profile returns NOT_SUPPORTED. Lua union page remains successful empty.
This is a proportionate producer-input limitation, **not populated union evidence**
or a claim that no imported union can exist. No alternate engine/private factory
or upstream change is needed to document this limitation. Initial trial returned
a table error printed as null; the host now prints structured message and explicitly
asserts the observed native status instead of treating it as an unrelated failure.

`reentry_host` now requires real allocation-triggered owner-closing/reconstructing
finalizers during both empty and populated publication for all three currently enabled
iterator families (functions, symbols, memory blocks), ELF/project, on the same invocation. Configured SaveProgram
success is also included in loaded publication finalizers, asserts saved=true and
generation=3, with disposable state removed on completion. Real full owner release
and fresh-owner reuse are asserted; no mock substitutes for these runtime paths.

### Category-specific signature persistence

The direct-native probe now seeds a distinctive `int` parameter name and asserts
it before save. Reopen without prior decompile yields `void func_0x00401106()`
with no parameters (asserted), not the seeded signature; saved=true is not proof
of signature restoration. This observes immediate reload semantics, not a claim
that later analysis cannot recover inferred parameter types. Attempts using
`unsigned int` and `uint` both returned native SET_PROTOTYPE_FAILED parse errors;
the existing supported `int` grammar plus unique parameter name was sufficient
to observe loss, without extending/repairing the native prototype parser.

## Seed-disabled real Lua persistence reconciliation

The same native-seeded real Lua host now saves configured disposable state, closes
and releases its owner, explicitly disables the seeding callback, and reopens a
new real owner with the saved path on ELF and project. Alias/enum/type-member/
enum-member/comment pages change from one to zero despite saved=true. Signature
changes from one named parameter to no parameters/void, asserted after actual
Lua GetFunctionSignature (which asks native decompilation before extraction).
State files are removed on normal completion. A host-global switch is test-only,
not production API or altered response; disabling it is crucial to avoid false
restoration positives by reseeding after reload. The function-symbol/overlay tests
remain the positive-restoration and nonpersistent-overlay evidence respectively.
Native-only data/benchmark category observations are not claimed as Lua core rows:
those operations are full-tier outside delivered core adapters.

### Signature candidate filter disposition

Locked local_client.cpp ListFunctionSignatures first paginates listFunctions,
then decompiles each candidate and pushes a signature only when optional lookup
succeeds. listFunctions enumerates native function symbols; signature lookup
queries that same global scope for Funcdata. On all exercised real candidates
(including conditional fixture and seeded/reloaded routes), signatures exist;
no honest empty-filtered-output-before-later-candidates case has been produced.
Candidate offset tests therefore establish actual candidate indexing, not a
populated missing-signature branch. That branch remains a native-producer
coverage limitation, not a requirement to inject an impossible mock into the
real operation or repair upstream. The wrapper forwards offset/limit unchanged,
never treats output length/empty page as candidate exhaustion, and exposes no
signature iterator. This preserves filter semantics without a fake positive.

## Complete-field author qualification (not independent approval)

Compared each of 15 core record converters field-for-field against the locked
native models.hpp and manifest types fields: all 108 members match, none omitted
or extra. Owning protected response branches reviewed for saved/discarded/renamed/
name/bytes_written, optional symbol/type/signature and all page extraction fields.
`tests/boundary_host.cpp` now explicitly initializes and asserts **every scalar or
text field**, not merely representative records: UInt64 max, uint32 max, signed
-1/INT64_MIN, false, embedded NUL, nested parameter vector, all six known comment
names and unknown numeric value. Fixture ownership remains outside the protected
conversion frame; no owning locals added to Lua-longjmp frames. Persistent Lua
allocation refusal and same-VM retries still run. This is synthetic full detached
fidelity, not invented native field population or independent review.

The field/row audit found one ledger omission in d72275a: ListDefinedStrings is
classified `core compatibility`, not exactly `core`, so the 22-row update had left
its implemented surface/runtime evidence stale. Reconciled that explicit row too,
with verified real known-string empty fidelity and no discovery/populated claim.
The other full-tier/M2 classifications remain unchanged. One edit initially
inserted comment-kind fixture initialization into SliceOwned instead of CoreOwned;
build failed, initialization moved to its actual owner, build/focused sweep pass.

Audit tooling attempts initially matched a nested response-model object rather
than the top-level types dictionary (BasicBlockRecord indentation appeared twice).
The failed assertion prevented file writes. Scoped comparison/insertion to the
actual types section, then JSON parse and exact field comparison passed; no
successful suite status is used to erase those earlier tooling assertion failures.

## Descriptor-finalizer error precedence repair

A targeted author check found that a finalizer during identity/order construction
could invalidate the owner, then a duplicate/nonadvancing record would raise
PAGINATION_STALLED before the final pre-yield generation guard. No stale record
was yielded, but the invocation reported stale-page diagnostics rather than the
required ITERATOR_INVALIDATED. The shared iterator primitive now checks its
nonallocating generation predicate immediately after each descriptor call, before
using the result in page validation. tests/m3_iterators.lua reproduces both
identity and ordering finalizer mutation combined with duplicate records; both
must report invalidation. The new test failed on prior installed source, passes
with the owning primitive fix, and runs in installed standalone/static/shared
qualification. This does not upgrade synthetic descriptor cases to new native
operation positives; existing actual native publication coverage remains.

## Terminal compound-bound page repair

A valid request at offset=INT_MAX-2, limit=2 could return records, but the iterator
checked whether its *next* request would fit before yielding this already-valid
page. This discarded legitimate terminal-bound data. The primitive now checks
the actual pending request at refill entry, advances by actual count (bounded by
the validated current limit), and yields the complete valid page. If another
refill would exceed offset+limit<=INT_MAX, it raises PAGINATION_STALLED without
fetching; no wraparound, fabricated exhaustion, or loss of buffered records.
Regression covers full terminal page, capped singleton progression to the bound,
empty terminal page and no retry/dispatch after overflow. Prior installed source
failed before first yield; repaired source passes in all three installed Lua hosts.
Synthetic near-INT_MAX cursor cases test arithmetic without claiming a native
collection of that size, which remains outside the supported profile.

## Original reviewer R1 correction

Public basic-block/xref iterator descriptors removed under DESIGN pages-only rule.
Shared primitive stall/generation/finalizer regressions unchanged; loaded real
publication finalizer loops now cover exactly the three remaining enabled families.
Native list_basic_blocks/list_cfg_edges/list_xrefs response conversion and loaded
publication tests remain intact. tests/m3_branch.lua preserves four-block/four-edge
native-order reproducer, but replaces the rejected safe-stall acceptance with
absence and repeated full/singleton page assertions. tests/m3_iterators.lua keeps
positive block/xref pages on both ELF/project and generic stall/boundary tests.
This correction is submitted for original reviewer re-review, not self-approval.
