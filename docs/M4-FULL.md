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

All rows except the four List* reads and ListPerfBenchmarks are mutations/lifecycle:
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
though wrapper conversion preserves its full length. Saved=true retains existing
category-loss limitations; no new persistence promise.

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
Independent review, exhaustive field/negative reconciliation, additional partial
native-failure and persistence qualification remain separate from passing the
surface reproducer. Do not infer full release acceptance from method availability.
Preserve M2 extreme-address/raw FileBytes and M3 producer/category limitations.
No upstream patch, generator authority decision or new distribution right.
