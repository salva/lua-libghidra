# Lua API reference

Native-local libghidra at `d51ca813ae1b6b59519551a9be8c0b1ad74d862d`.
Original wrapper Copyright 2026 Salvador Fandiño, MIT. Supported host: ordinary
PUC Lua 5.4, signed int64 integers/eight-byte double numbers, Linux x86-64;
qualified runtime 5.4.6. No second VM or independent-engine mixing in-process.
See the [guide](EXAMPLES.md) and [notices](NOTICES.md).

## Construction and return shapes

`require('libghidra.lowlevel').local_client(client_options)` returns owner or
`nil,error`. Omitted/nil options means `{}`. Client keys: `ghidra_root`,
`state_path`, `default_arch` (strings default empty), `pool_size` (integer, only
1 accepted, default 1). Configuration strings reject embedded NULs.

`require('libghidra').open{client=client_options,program=program_options}` returns
`session,nil,open_response` or `nil,error`; a newly created owner is released on
open failure, including Lua publication errors. Only client/program outer keys
are accepted. Program is required. The six Session program keys are
`program_path`, `project_path`, `language_id`, `compiler_spec_id`, `format`
(strings default empty), `base_address` (exact uint64 default zero).
At least one path must be nonempty; nonempty project_path selects project loading.
Lowlevel `owner:open_program(program_options)` additionally accepts `project_name`
(string default empty) and `read_only` (boolean default false), both **ignored**.
Session factory and retained `session:open_program` reject these extra keys.
Native open metadata echoes language/compiler request/defaults, not authoritative
detection. Supply explicit supported hints.

All calls use colon syntax. Lowlevel returns complete detached native values or
`nil,error`. Session forwards complete page/mutation/lifecycle envelopes, except
these reads unwrap a field as `value,nil,response`:

| Session read | Field |
| --- | --- |
| get_function | `response['function']` |
| get_instruction | instruction |
| get_symbol | symbol |
| get_type | type |
| get_function_signature | signature |
| get_decompilation | decompilation |
| read_bytes | data |

Optional absence yields `nil,NOT_FOUND,response`; native failure has no invented
third response. False, zero, empty strings and empty tables are not absence.
Both modules export `check(value,err,response)`: returns value,response or raises
err only if value is nil. **It checks presence, not outcome flags.** A present
`completed=false` or `is_fallback=true` decompilation is inspectable, not success;
inspect error_message and pseudocode separately. Mutation booleans/counters are
acknowledgements, not independently verified effects.

Errors have code/message/operation/backend and optional upstream_code; backend
is `local` for SDK failures, `binding` for boundary errors. Preserve native codes;
notably CLOSED, NO_PROGRAM, NOT_FOUND, INVALID_ARGUMENT, NOT_SUPPORTED,
NO_STATE_PATH and native resource failures differ. C++ exceptions are contained;
Lua allocation/runtime errors still raise. Iterators raise structured errors.

## Values and validation

Every native uint64 output is immutable UInt64, even small IDs, addresses,
revision numbers, sizes and ordinals. `u64(nonnegative_integer_or_strict_string)`
returns exact value or nil,error; uint64 arguments also accept UInt64. Strings
are decimal or `0x` hexadecimal, without sign/whitespace/trailing bytes. Floats
and overflow are rejected. `nm`'s unprefixed hex must be prefixed with `0x`.
Methods: `hex()` (0x plus 16 lowercase digits), `decimal()`, checked
`to_integer()`, `add(nonnegative_integer)`, `sub(nonnegative_integer)`.
`tostring` equals hex. Equality compares UInt64 values; unrelated types compare
false. Ordered comparisons require UInt64 operands and raise on wrong types.
No arithmetic metamethods. Use string keys, not distinct value-equal userdata keys.
Signed/narrow integers are checked Lua integers; finite double fields are Lua
numbers. Arrays are dense 1-based tables; native offsets/ordinals stay zero-based.
Bytes are binary strings (NUL preserved); text is not transcoded. Known enums use
documented names, unknown **response** enums retain numeric values. Request
comment kinds accept only the documented names. Optional absence is nil.

Unknown request keys, sparse arrays, wrong types and out-of-range values fail
before dispatch. Defaults use omission, never truthiness. Required positional
arguments stay required despite native model defaults. [FIELDS](../api/FIELDS.md)
is generated native field/type/default and conversion authority; excluded-only
schemas are not Lua support claims. Source reachability is not producer evidence.

`range_page` defaults to `{range_start=0,range_end=UINT64_MAX,limit=100,offset=0}`;
`count_page` accepts only limit/offset with the same defaults. Omitted/nil pages
use defaults. Limit/page_size is positive, offset nonnegative, each <= INT_MAX
and offset+limit <= INT_MAX. Ranges are inclusive. Explicit range_end=0 means
UINT64_MAX for function/instruction/symbol/comment/data families and function
candidates used by batch decompilation, not a singleton zero upper bound. Do not
infer this sentinel for every range-bearing native operation.

## Common client and Session operations

All following methods are on both views except those explicitly marked native-only.

| Method | Arguments | Complete lowlevel result |
| --- | --- | --- |
| get_status | `()` | health table |
| get_capabilities | `()` | capability array (coarse advertisement, not support oracle) |
| get_revision | `()` | program_id/modification_number: UInt64; program_path/file_id: strings; file_version:int32 and file_last_modified_time:int64: Lua integers |
| open_program | `(program_options)` | full OpenProgramResponse; same owner on reopen |
| close_program | `({policy='save' or 'discard'})` | closed:boolean |
| shutdown | `({policy='save' or 'discard'})` | accepted:boolean, **not closed** |
| save_program | `()` | saved:boolean |
| discard_program (native-only) | `()` | discarded:boolean |
| get_function, get_instruction, get_symbol | `(address)` | optional function/instruction/symbol |
| get_type | `(path:string)` | optional type |
| get_function_signature | `(address)` | optional signature |
| get_decompilation | `(address, options={})` | optional decompilation |
| read_bytes | `(address, size:integer)` | data:binary string |
| write_bytes | `(address, binary_string)` | bytes_written:uint32 integer |
| rename_function, rename_symbol | `(address, new_name:string)` | renamed:boolean, name:string |
| list_functions, list_instructions | `(range_page)` | functions / instructions array |
| list_basic_blocks, list_cfg_edges | `(range_page)` | blocks / edges array |
| list_symbols, list_xrefs | `(range_page)` | symbols / xrefs array |
| get_comments | `(range_page)` | comments array |
| list_function_signatures | `(range_page)` | signatures array |
| list_defined_strings (native-only) | `(range_page)` | strings array, constant-empty stub |
| list_memory_blocks | `(count_page)` | blocks array |
| list_types, list_type_aliases, list_type_unions, list_type_enums | `(query:string, count_page)` | types / aliases / unions / enums array |
| list_type_enum_members, list_type_members | `(type_id_or_path:string, count_page)` | members array |
| close | `()` | true, idempotent binding owner release |

Lowlevel get_decompilation options accepts only timeout_ms integer 0..INT_MAX,
default 30000, **ignored** by the pinned engine. Session permits only omitted/nil
or empty options, rejects a timeout key, and promises no deadline/cancellation.
ReadBytes size is 0..INT32_MAX before buffer allocation/dispatch (native uint32
width does not override downstream signed int4). WriteBytes length <= INT_MAX.
Bounds are not promises of memory availability; never probe multi-GB allocations
just to check a limit. GetType forwards findByName input: returned name works;
leading-slash path_name is not normalized into a successful lookup.

Session-only `native()` returns the same lowlevel owner. Session-only
`iter_functions(options)`, `iter_symbols(options)`, `iter_memory_blocks(options)`
return lazy zero-argument record iterators; options replace limit with page_size
(default 100), preserve offset/range defaults, except memory accepts counts only.
They retain one page, advance by actual returned count, and check shared generation
before every yield, including buffered records. Short pages need not end traversal;
duplicate, reversed, oversized or nonadvancing pages fail rather than sort/dedup.
Functions order by entry address; symbols by native traversal symbol_id with
address/name/namespace identity; memory blocks by start/name. These bounded serial
orders are not arbitrary-engine snapshots. No other iterator exists. Signature
offsets count candidates **before filtering**;
empty signature pages do not prove exhaustion. Types have anonymous identity
collisions; block order is structural, xrefs concatenate phases: these remain
pages-only, as do CFG/subtypes/comments and specialist families.
ListInstructions linearly decodes exactly from range_start and stops at a decode
gap; default zero can return empty despite code elsewhere.

## Specialist operations through the native view

Use lowlevel or `session:native()` (shutdown also has the guarded Session method).
No other specialist Session convenience is added. In the table,
s is a required exact string, u exact uint64, i signed int64 Lua integer and n
integer 0..INT_MAX. Page means range_page. No implicit positional defaults.
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
Request construction failures do not dispatch or invalidate. Shutdown is also available directly on Session with the save guard described
below. It is logical program access closure, not owner destruction; lowlevel save
policy retains the native empty-state-path caveat. These specialist operations require an open program except
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

## Ownership, persistence and effective limits

One live binding-owned client per process across states/module copies; second
construction returns CLIENT_IN_USE. Do not mix independent engines. `native()`
aliases the same owner. `close()`/Lua 5.4 __close release it permanently, invalidate
iterators and release the process slot; GC destroys it once and never saves.
__close preserves an active scope error. Detached tables remain valid.

Logical close_program/shutdown reset program access, not slot engines: reads
return NO_PROGRAM, status stays usable and the process slot remains occupied.
Session reopen returns the complete native open envelope on the same owner;
old open metadata stays historical. A closed owner returns CLOSED and cannot
reopen. Both Session close_program and shutdown reject policy=save without a
construction state_path as NO_STATE_PATH before dispatch; lowlevel faithfully
retains the native caveat that empty-path save-close may close without saving.
No automatic save, rollback or unloading guarantee. Dispatched mutations/lifecycle
calls increment shared generation **even on failure/partial effect**; validation-
only failures do not. Iteration is not a universal snapshot of external changes.

Function-symbol rename/save/reopen is observed on the supported profile; do not
generalize to all categories. On exercised binary/project state reload, struct
name/kind survives only as an empty shell; members, aliases, enums, comments,
named data and benchmark records disappear; signature/parameter edits reset and
original bytes return. Project true-local rename is observed before save and
resets after reload; binary int-signature evidence is parameter-only, not local
persistence. Member/enum comment persistence cannot be isolated from their lost
containers. Save flags acknowledge requests, not durable category completeness.
Byte overlays survive no-op discard but not save/reopen. No transactional batch
or partial-failure recovery: patch batches apply in order and counters total
requested bytes without confirming native writes. Decompilation batches may
contain complete, fallback and incomplete entries; inspect each, not just array.

Important pinned engine limitations:

- Discovery is lazy. Decompile a known mapped function before assuming lookup or
  pages are populated; NOT_FOUND does not imply no code. Many fields/tokens remain
  default/empty. Revision observation confirms representation (file_version zero),
  not a populated file-version producer or persistence contract.
- Extreme/unmapped addresses can crash native code; UInt64 validation establishes
  exactness, not safe mapping. Do not scan arbitrary/extreme addresses in-process.
  Lua cleanup cannot recover from a native process crash.
- Ordinary raw/FileBytes project loading is incomplete. The supported analyzed
  project fixture is a special no-FileBytes project referring to external ELF;
  its success is not general project-loader qualification. Leaf-functions query
  works on that analyzed project; raw ELF returns NOT_SUPPORTED.
- CreateType supports only struct; size is ignored. AddTypeMember ignores size,
  appends using referenced type. Generic struct length may be zero even with a
  four-byte member: query members for actual member sizes. Public union creation
  is unsupported; empty union pages are not populated producer evidence.
- CreateTypeEnum width/is_signed are not passed into native defineEnum. Observed
  width is eight despite requested 123/1. A false request/output alone does **not**
  establish ignored signedness experimentally; keep source and measured claims
  distinct. Enum get_type can report kind int, length eight.
- True-local rename is observed by stable id/kind after decompilation. Char retype
  of those true locals returns native DECOMPILE_FAILED and leaves type unchanged;
  true-local retyping is unqualified, not successful because a parameter changed.
- DeleteSymbol ignores name_filter, selects by address. Deleting a named data
  definition can reveal reconstructed inferred data at the same address/size;
  it does not promise permanent disappearance from discovery.
- ListDefinedStrings ignores ranges/counts on a loaded program and always returns
  empty success, even with known loaded strings; it is not a scanner.
- Ignored read_only/project_name/timeouts do not protect writes or impose deadlines.
  Text conversion preserves NUL, but native text consumers need not roundtrip it.
- Wrapper allocation/lifetime safety does not guarantee dependency-internal OOM
  cleanup, retention, global-state recovery or exhaustive fault recovery.

See [guide](EXAMPLES.md) for a checked own-input sequence. Adapter availability,
source field accounting and native success on one fixture do not establish all
input support or release/distribution clearance.
