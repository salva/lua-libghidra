# M4 native-local writer implementation and qualification

Original wrapper Copyright 2026 Salvador Fandiño, MIT. This extends the core API;
not M5/release approval. The pinned Elias Bachaalany libghidra engine, license,
local-only profile and notices remain unchanged. Independent review is required.

## Call grammar and dispatch manifest

All calls below are on the lowlevel owner, or `session:native()` on the **same**
owner. No specialist Session convenience or iterator is added. Responses are
complete detached envelopes; native status/errors are preserved. Required
positional arguments have no invented defaults. `s` below means an exact Lua
string (NUL preserved at the boundary, native consumers may interpret it);
`u` means exact uint64 input (UInt64, nonnegative integer or strict string),
`i` signed int64 Lua integer; parameter ordinal `n` is integer 0..INT_MAX.
Response uint64 fields are always UInt64, narrow integers Lua integers.
Native model field facts remain in [FIELDS](../api/FIELDS.md).

| Native / lowlevel name | Arguments in order | Response fields |
| --- | --- | --- |
| CreateType / create_type | name:s, kind:s, size:u | updated:bool |
| DeleteType / delete_type | type_id_or_path:s | deleted:bool |
| RenameType / rename_type | type_id_or_path:s, new_name:s | updated:bool, name:s |
| CreateTypeAlias / create_type_alias | name:s, target_type:s | updated:bool |
| DeleteTypeAlias / delete_type_alias | type_id_or_path:s | deleted:bool |
| SetTypeAliasTarget / set_type_alias_target | type_id_or_path:s, target_type:s | updated:bool |
| CreateTypeEnum / create_type_enum | name:s, width:u, is_signed:bool | updated:bool |
| AddTypeEnumMember / add_type_enum_member | type_id_or_path:s, name:s, value:i | updated:bool |
| DeleteTypeEnumMember / delete_type_enum_member | type_id_or_path:s, ordinal:u | deleted:bool |
| RenameTypeEnumMember / rename_type_enum_member | type_id_or_path:s, ordinal:u, new_name:s | updated:bool |
| SetTypeEnumMemberValue / set_type_enum_member_value | type_id_or_path:s, ordinal:u, value:i | updated:bool |
| SetTypeEnumMemberComment / set_type_enum_member_comment | type_id_or_path:s, ordinal:u, comment:s | updated:bool |
| AddTypeMember / add_type_member | parent_type_id_or_path:s, member_name:s, member_type:s, size:u | updated:bool |
| DeleteTypeMember / delete_type_member | parent_type_id_or_path:s, ordinal:u | deleted:bool |
| RenameTypeMember / rename_type_member | parent_type_id_or_path:s, ordinal:u, new_name:s | updated:bool |
| SetTypeMemberType / set_type_member_type | parent_type_id_or_path:s, ordinal:u, member_type:s | updated:bool |
| SetTypeMemberComment / set_type_member_comment | parent_type_id_or_path:s, ordinal:u, comment:s | updated:bool |
| SetFunctionSignature / set_function_signature | address:u, prototype:s | updated:bool, function_name:s, prototype:s |
| RenameFunctionParameter / rename_function_parameter | address:u, ordinal:n, new_name:s | updated:bool, name:s |
| SetFunctionParameterType / set_function_parameter_type | address:u, ordinal:n, data_type:s | updated:bool, data_type:s |
| RenameFunctionLocal / rename_function_local | address:u, local_id:s, new_name:s | updated:bool, local_id:s, name:s |
| SetFunctionLocalType / set_function_local_type | address:u, local_id:s, data_type:s | updated:bool, local_id:s, data_type:s |
| ApplyDataType / apply_data_type | address:u, data_type:s | updated:bool, data_type:s |
| ListDecompilations / list_decompilations | page={}, options={timeout_ms=30000} | decompilations:DecompilationRecord[] |
| ListLeafFunctions / list_leaf_functions | page={} | functions:FunctionRecord[] |
| DeleteSymbol / delete_symbol | address:u, name_filter:s | deleted:bool, deleted_count:uint32 |
| SetComment / set_comment | address:u, kind:comment-kind, text:s | updated:bool |
| DeleteComment / delete_comment | address:u, kind:comment-kind | deleted:bool |
| ListDataItems / list_data_items | page={} | data_items:DataItemRecord[] |
| RenameDataItem / rename_data_item | address:u, new_name:s | updated:bool, name:s |
| DeleteDataItem / delete_data_item | address:u | deleted:bool |
| AddPerfBenchmark / add_perf_benchmark | record (below) | added:bool |
| ListPerfBenchmarks / list_perf_benchmarks | none | records:PerfBenchmarkRecord[] |
| ClearPerfBenchmarks / clear_perf_benchmarks | none | cleared:bool, removed_count:uint32 |
| DeletePerfBenchmark / delete_perf_benchmark | bench_id:s | deleted:bool |
| PatchBytesBatch / patch_bytes_batch | dense array of {address:u,data:binary string} | patch_count:uint32, bytes_written:uint32 |
| Shutdown / shutdown (existing) | {policy='save' or 'discard'} | accepted:bool |

All rows except the three paged List* reads and ListPerfBenchmarks are mutations/lifecycle:
shared generation increments immediately before dispatch, including native failure.
Request construction failures do not dispatch or invalidate. Shutdown is logical
program access closure, not owner destruction; lowlevel save policy retains the
native empty-state-path caveat. All operations require an open program except
Shutdown's native lifecycle behavior. Closed binding owners return CLOSED.

Page fields match core range grammar: range_start=UInt64 zero,
range_end=UInt64 max, limit=100, offset=0. Zero end is native maximum sentinel for
functions/data items and the function candidates used by decompilation. Strict
positive limit and nonnegative offset, sum <= INT_MAX. Collections above INT_MAX
unsupported. timeout_ms is integer 0..INT_MAX and **ignored** by native batch.
Comment kinds: unspecified/eol/pre/post/plate/repeatable (native zero through five).
Unknown keys, sparse patch arrays, wrong types and numeric overflows are rejected.
Patch count and summed bytes <= UINT32_MAX; each patch <= INT_MAX bytes. These are
bounds, not memory availability guarantees. Empty patch arrays remain native calls.

PerfBenchmarkRecord has four strings default empty: bench_id, query_family,
dataset_profile, status; six finite double/Lua-number fields default 0:
cold_ms_p50, cold_ms_p95, warm_ms_p50, warm_ms_p95, throughput_qps, regression_pct.
No truthiness defaults: zero, false and empty strings preserved. Native rejects
empty bench_id. Output has all ten fields, including zero and negative numbers.
DataItemRecord has address/end_address/size:uint64, name/data_type/value_repr:s;
end is inclusive. Decompilation and function records use existing converters.

## Fidelity, safety and evidence

`tests/m4_full_reproducer.lua` is unchanged: installed binary/project six checks
now report zero missing methods, real bytes and shutdown/status/reopen controls
pass. This resolves the reproduced absence, not by no-op registrations: each
method dispatches exactly one corresponding IClient call, including native batch.
`tests/m4_services.lua` exercises all new methods against real installed Lua on
both ELF and analyzed project. On raw ELF, functions become candidates after
explicit decompilation seeds; assuming they already existed initially produced
an empty batch and exhausted iterator, corrected at fixture setup.

Service assertions include populated native batch and project leaves (raw ELF
NOT_SUPPORTED), type/alias/enum/member edits, signature/parameter/local edits,
data/symbol/comment edits, byte patch NUL roundtrip and benchmark CRUD. Type size
999 does not control struct creation/member size; member size follows referenced
int (4). Enum width 123 and false are accepted, not enforced. DeleteSymbol's
mismatched name deletes by address. Unsupported type kinds remain native
NOT_SUPPORTED. Existing M2 publication guard and M3 pages-only policy unchanged.
Native comment/type text storage is not promised to roundtrip arbitrary NUL even
though wrapper conversion preserves its full length. Save/reload results for new categories are explicitly qualified below;
no complete persistence promise is made.

Patch batch forwards a single vector, in order, without rollback/preflight of
native effects; no atomicity is invented. Native implementation applies every
patch sequentially and totals requested bytes, ignoring write return values.
Counters are not readback confirmation. Partial failure recovery is not promised.
The wrapper validates all input before dispatch; validation failure is not a
native partial failure experiment. No extreme address crash probe is introduced.

Protected conversion uses outer Packet ownership. Text request copies are made
before dispatch/generation; all allocating Lua frames have trivial automatic
storage. Batch vector is outer-owned, filled by a protected trivial thunk with
caught C++ allocation failure. Lua error unwinds via pcall before vector/Packet
destruction and trivial rethrow. Owner rechecked after this Lua-running phase.
`read_order_host` extends result/error allocation refusal and three boundary
exception/retry checks to batch/leaves/types/enums/comments/data/perf/patch,
and first wrapper-copy allocation refusal for type/perf/patch. No dependency
allocation sweep. Empty/error result sweeps now allow a structured native error
(e.g. raw leaf NOT_SUPPORTED); normal positive service tests remain separate.

Qualification evidence is recorded in the card status with exact commands and
logs. Existing field ledger generated runtime slots intentionally remain
unqualified; this grammar/evidence supplement is not retroactive generator output.
The completed writer reconciliation and new persistence/native batch evidence
are below. Independent review remains separate from writer qualification. Do not infer full release acceptance from method availability.
Preserve M2 extreme-address/raw FileBytes and M3 producer/category limitations.
No upstream patch, generator authority decision or new distribution right.

Additional affected-path checks cover failed native CreateType invalidation,
validation-only rejection without invalidation, patch buffered-iterator
invalidation, exact max uint64 ordinal failure, overlapping native patch order
(later writes win) and ignored enum width through actual resulting type length.
Deterministic finalizer closure/reconstruction recheck includes type, patch and
benchmark adapters. Installed qualification script includes M4 in all three hosts.

## Completed writer reconciliation (pinned native headers and LocalClient)

The table above is the operation manifest for **all 37 full rows**, not a proposal.
Reconciliation used `cpp/include/libghidra/{types,symbols,functions,decompiler,
listing,memory,session,models}.hpp`, LocalClient overrides and `src/owner.cpp`
at the SPEC pin/authorized SDK. There are no additional included full operations
hidden behind interface defaults: DeleteTypeEnum/ParseDeclarations and all other
excluded defaults remain excluded as COVERAGE specifies. Core M3 mappings and
M2/M3 limitations are reused, not regenerated as full evidence. All full specialist
calls, including Shutdown, use native(); none creates a Session convenience.

Field-by-field result: type/alias/enum/member mutation responses contain only the
listed bools, except RenameType also has name. Signature response also preserves
empty function_name and requested prototype; parameter/local/data mutations retain
name/data_type/local_id exactly as declared. DeleteSymbol has both deleted and
uint32 deleted_count; patch has two uint32 counters; clear benchmark has bool and
uint32 removed_count. Shutdown has accepted, **not** closed. No optional response
fields occur in these mutation envelopes. The only arrays are native function,
decompilation, data-item and performance arrays. Every nested output field uses
the existing FunctionRecord/DecompilationRecord converters, explicit DataItemRecord
and all ten PerfBenchmarkRecord fields; models/defaults/types are enumerated in
[FIELDS](../api/FIELDS.md). Empty arrays are tables, not nil. Known enums use names;
unknown response enum numbers use existing converter numeric fallback.

Request reconciliation: all positional scalar fields are required, despite native
model zero/empty defaults. No invented request tables or flags. The sole full
native struct inputs are BytePatch[] and PerfBenchmarkRecord; all of their fields
are accounted for above (benchmark fields optional with exact native defaults;
patch fields required). CommentKind mapping covers all six native constants.
Shutdown intentionally accepts only explicit save/discard as specified, not native
unspecified/none. Narrow parameter ordinals are nonnegative int, enum/member
ordinals and sizes exact uint64, enum values signed int64. All string lengths are
preserved at conversion. Finite doubles are accepted without integer coercion;
NaN/infinity are rejected. The only optional argument tables are pages/batch timeout.
Page bounds and zero-end sentinel match the actual downstream function/data paths.
No timeout deadline, read-only, size or signed-enum-width enforcement is fabricated.
Native batch timeout ignores the field. Included non-full fields remain governed
by M2/M3 contracts, not silently replaced by this extension.

`tests/m4_contract.lua` provides an operation-wide negative/dispatch matrix for
**every 36 new adapters**: unloaded NO_PROGRAM through valid inputs, closed CLOSED,
wrong first argument on every argument-taking method, no generation change for
validation rejection, increment before every dispatched mutation even NO_PROGRAM,
and no increment for reads. Shutdown validation/logical reopen uses both surfaces;
existing core save-policy/failure tests remain applicable. Paged negatives cover
unknown keys/zero limit/negative offset/compound overflow; timeout wrong/unknown
fields; false benchmark delete, empty native benchmark ID error; every benchmark
field including embedded NUL, defaults, zero and negative/fractional values;
all comment kinds with NUL text roundtrip; signed enum INT64_MIN/MAX/zero readback;
empty patch and a nonempty-plus-empty patch. `m4_services.lua` supplies supported
positive mutations in both profiles (including project-required leaves), ignored
fields, exact max ordinal native rejection and iterator invalidation. Together
these cover the declared grammar/error/field classes without an invented claim
that every arbitrary engine input is supported. Actual engine type/category
limitations are retained below. No wrapper defect found in this reconciliation.

## New-category persistence qualification

`tests/m4_persistence.lua PREFIX ROOT WORK` uses purpose-named disposable XML files,
never writes source ELF/project fixtures, and runs both raw ELF and analyzed-project
profiles. On each it creates struct/member/comment, alias, enum/member/comment,
function signature/parameter/local names, EOL comment, typed/renamed data,
benchmark and byte patch; requires each mutation acknowledgement, SaveProgram
saved=true, DiscardProgram discarded=true without overlay rollback and local
Shutdown(save) accepted=true. It releases owner and reopens with the same state.

**Observed pinned limitation (asserted, not silently skipped):** struct name/kind
survives as a zero-length shell, with zero members; alias and enum are absent;
comments/data items/benchmarks are empty; changed signature/parameter/local names
are absent/reset; patched bytes return original ELF bytes. This applies to these
specific new-category profiles; not a promise that every possible state is lost
or every type persists. Native load is best-effort primary-slot reload:
LocalClient OpenProgram line 144 calls pool loadState; SaveProgram lines 164–182
saves state; decompiler_pool.cpp lines 87–95 forwards save/load to slot 0 and
rebuilds its adapter. Logical close clears benchmark records. The binding forwards
all of these, stores no parallel persistence layer. Attribution is to the native
state path/limited persistence contract, not an unexplored wrapper conversion
failure. Existing M3 function-name/overlay/discard/no-autosave and seeded type
category evidence remains applicable only to its exercised categories. This closes
the writer evidence gap, **not** the native persistence limitations.

## Native batch semantics and safe failure evidence

LocalClient ListDecompilations lines 323–346 paginates candidate functions, calls
pool decompileMany once and preserves result array. decompiler_pool.cpp lines
148–170 (pool_size=1) iterates candidates serially: success populates code/locals
and completed=true; ordinary failure leaves completed=false and accurate error
text, then continues loop. Prototype/tokens/fallback stay model defaults on that
batch path; the wrapper does not invent single-call token/prototype output.
`m4_contract.lua` creates a finite unmapped function at 0x500000 using supported
RenameFunction (the bounded address already qualified by M2), and requests a batch
containing authored completed code plus that incomplete record. It asserts both
completed and failed records, error text, arrays and false fallback in the same
successful native batch response. Diagnostics are expected evidence, not erased.

PatchBytesBatch lines 1639–1654 sequentially applies each write, ignores each
write's boolean result, increments revision once, returns requested count/bytes.
No per-item status or rollback. Tests prove overlap last-write-wins, binary NUL
readback and nonempty followed by empty patch while retaining first effect and
requested counters. **No safe supported ordinary mid-patch Status error exists
in this source path after ensure_loaded**: it neither checks write results nor
returns per-patch errors. Therefore no injected dependency OOM or extreme-address
crash is required to manufacture one. Native C++ exceptions are separately handled
and tested at the wrapper boundary, not evidence of dependency recovery. There
is no added recovery acceptance gate; partial effects on an exceptional native
failure remain possible, generation already invalidated.

One exploratory attempt to obtain a *later success after incomplete decompilation*
using RET plus 511 NOP overlay at 0x500100 still caused the native decoder to request
bytes at 0x5001f0 and returned incomplete. No source was changed or upstream repair
started; the final bounded fixture asserts mixed success/failure, and source
establishes continuation without a fabricated later-success claim.

## Safety/regression boundary and delivery disposition

Extended existing wrapper allocator/publication/three boundary-exception sweeps
also exercise signature, parameter/local, data, alias and benchmark delete/clear
families. Each direct operation has no setup calls that could consume the fault.
Existing type/enum/comment/patch sweeps, deterministic finalizer rechecks and M2/M3
publication/iterator guards remain relevant; no new owner or Lua-allocating RAII
frame was introduced. Broader installed standalone/static/shared checks now include
contract matrix; disposable persistence runs at the existing installed boundary.
Build/CTest and wrapper sanitizer results are recorded in current card status.

Writer M4 qualification is complete within these explicitly supported native
semantics and limitations: all included full operations/fields/defaults/dispositions
reconciled, real supported positives and negatives, persistence limits and safe
batch behavior evidenced. Independent review is still required, not writer work
silently delegated to reviewers. Generated source ledger runtime slots remain
unqualified by design, with this hand-maintained runtime supplement as evidence.
M5 source-build generator permission, license/distribution authorization, other
release gates and retained M2/M3 limitations are unchanged.

Persistence fixture nuance: the raw ELF decompiler may expose only parameter
local IDs after setting the prototype. The test always executes RenameFunctionLocal,
using a genuine local ID when available and the supported parameter local ID
otherwise (never silently skips the operation). Its reload assertion checks absence
of both edited names. This qualifies local-ID edit persistence in those profiles,
not a guarantee of a stable stack/register-local producer across engine versions.
