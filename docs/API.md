# Lua API reference

Native-local libghidra at `d51ca813ae1b6b59519551a9be8c0b1ad74d862d`.
Original wrapper Copyright 2026 Salvador Fandiño, MIT. Supported host: ordinary
PUC Lua 5.4, signed int64 integers/eight-byte double numbers, Linux x86-64;
qualified runtime 5.4.6. No second VM or independent-engine mixing in-process.
See the [guide](EXAMPLES.md) and [notices](NOTICES.md).

## Method index

Surface legend: **both** means Session and lowlevel owner; **lowlevel** also means
`session:native()` access. Module helpers are labeled separately. Native calls
return full detached envelopes or nil,error; Session differences are adjacent.
Arguments shown without defaults are required. `s` means exact string, `u` exact
uint64, `i` signed int64 Lua integer, `n` integer 0..INT_MAX; bool is boolean.
Calls use colon syntax except module functions. String/u64/integer bounds and
[shared pagination](#values-and-validation) apply to every entry.

- Module helpers: [open](#open), [local_client](#local_client), [check](#check), [u64](#u64), [native](#native), [close](#close), [iter_functions](#iter_functions), [iter_symbols](#iter_symbols), [iter_memory_blocks](#iter_memory_blocks)
- Lifecycle status and capabilities: [get_status](#get_status), [get_capabilities](#get_capabilities), [get_revision](#get_revision), [open_program](#open_program), [close_program](#close_program), [shutdown](#shutdown), [save_program](#save_program), [discard_program](#discard_program)
- Functions and decompilation: [get_function](#get_function), [list_functions](#list_functions), [rename_function](#rename_function), [list_basic_blocks](#list_basic_blocks), [list_cfg_edges](#list_cfg_edges), [get_decompilation](#get_decompilation), [list_decompilations](#list_decompilations), [list_leaf_functions](#list_leaf_functions), [get_function_signature](#get_function_signature), [list_function_signatures](#list_function_signatures), [set_function_signature](#set_function_signature), [rename_function_parameter](#rename_function_parameter), [set_function_parameter_type](#set_function_parameter_type), [rename_function_local](#rename_function_local), [set_function_local_type](#set_function_local_type)
- Instructions comments and defined data: [get_instruction](#get_instruction), [list_instructions](#list_instructions), [get_comments](#get_comments), [set_comment](#set_comment), [delete_comment](#delete_comment), [list_defined_strings](#list_defined_strings), [list_data_items](#list_data_items), [apply_data_type](#apply_data_type), [rename_data_item](#rename_data_item), [delete_data_item](#delete_data_item)
- Symbols and cross references: [get_symbol](#get_symbol), [list_symbols](#list_symbols), [rename_symbol](#rename_symbol), [delete_symbol](#delete_symbol), [list_xrefs](#list_xrefs)
- Memory and byte patches: [read_bytes](#read_bytes), [write_bytes](#write_bytes), [list_memory_blocks](#list_memory_blocks), [patch_bytes_batch](#patch_bytes_batch)
- Types aliases enums and members: [add_type_enum_member](#add_type_enum_member), [add_type_member](#add_type_member), [create_type](#create_type), [create_type_alias](#create_type_alias), [create_type_enum](#create_type_enum), [delete_type](#delete_type), [delete_type_alias](#delete_type_alias), [delete_type_enum_member](#delete_type_enum_member), [delete_type_member](#delete_type_member), [get_type](#get_type), [list_type_aliases](#list_type_aliases), [list_type_enum_members](#list_type_enum_members), [list_type_enums](#list_type_enums), [list_type_members](#list_type_members), [list_type_unions](#list_type_unions), [list_types](#list_types), [rename_type](#rename_type), [rename_type_enum_member](#rename_type_enum_member), [rename_type_member](#rename_type_member), [set_type_alias_target](#set_type_alias_target), [set_type_enum_member_comment](#set_type_enum_member_comment), [set_type_enum_member_value](#set_type_enum_member_value), [set_type_member_comment](#set_type_member_comment), [set_type_member_type](#set_type_member_type)
- Performance records: [add_perf_benchmark](#add_perf_benchmark), [clear_perf_benchmarks](#clear_perf_benchmarks), [delete_perf_benchmark](#delete_perf_benchmark), [list_perf_benchmarks](#list_perf_benchmarks)

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

## Module helpers and owner views

### open

Session module function `open{client=client_options, program=program_options}`.
No existing owner required; creates one process owner and opens the required
program. Returns `session,nil,response` with [OpenProgramResponse](../api/FIELDS.md#openprogramresponse)
or `nil,error`; failure releases a newly constructed owner, including publication
errors. See [construction keys](#construction-and-return-shapes). Client omitted/nil
means defaults. Program must be a table with at least one nonempty input path.

### local_client

Lowlevel module function `local_client(client_options)`; omitted/nil means `{}`.
No program needed. Creates unique owner or returns `nil,error`; CLIENT_IN_USE for
a second live owner. Keys/defaults are in [construction](#construction-and-return-shapes)
and [LocalClientOptions](../api/FIELDS.md#localclientoptions). Returns owner userdata, not a model envelope.

### check

Both module functions `check(value,err,response)` return `value,response` when
value is not nil, otherwise raise err. Pure Lua presence helper: no dispatch,
owner/state requirement or outcome validation. False/zero are present.

### u64

Both modules export `u64(nonnegative_integer_or_strict_string)`: exact UInt64 or
`nil,error`, no owner/state/dispatch. See [values](#values-and-validation).
No model envelope. UInt64 methods `hex()`, `decimal()` return strings;
`to_integer()` returns a checked Lua integer or nil,error; `add(n)`, `sub(n)`
require nonnegative Lua integer and return exact UInt64 or nil,error on overflow.
No mutation of the immutable value, no float arithmetic.

### native

Session-only `native()` returns the same lowlevel owner alias (even when closed),
not another engine or model envelope. No dispatch/mutation; shares lifetime/state.

### close

Both owner views `close()` return scalar true idempotently; release native owner
and process slot, permanently mark aliases CLOSED and invalidate iterators.
No save. Lua 5.4 __close preserves an active scope error. Detached values survive.

### iter_functions

Session-only `iter_functions(options)` returns a lazy zero-argument iterator yielding [FunctionRecord](../api/FIELDS.md#functionrecord). Requires an open program at fetch time; closed/generation changes raise structured errors. Omitted/nil options use page_size=100, offset=0, range_start=0, range_end=UINT64_MAX. Uses shared [pagination](#values-and-validation); no mutation or eager snapshot.

### iter_symbols

Session-only `iter_symbols(options)` returns a lazy zero-argument iterator yielding [SymbolRecord](../api/FIELDS.md#symbolrecord). Requires an open program at fetch time; closed/generation changes raise structured errors. Omitted/nil options use page_size=100, offset=0, range_start=0, range_end=UINT64_MAX. Uses shared [pagination](#values-and-validation); no mutation or eager snapshot.

### iter_memory_blocks

Session-only `iter_memory_blocks(options)` returns a lazy zero-argument iterator yielding [MemoryBlockRecord](../api/FIELDS.md#memoryblockrecord). Requires an open program at fetch time; closed/generation changes raise structured errors. Omitted/nil options use page_size=100, offset=0; counts only. Uses shared [pagination](#values-and-validation); no mutation or eager snapshot.

### Iteration guarantees

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

## Lifecycle status and capabilities

### get_status

**both** — `get_status()`. Requires live owner; no open program prerequisite. Read-only dispatch; no iterator invalidation.

Lowlevel result: [HealthStatus](../api/FIELDS.md#healthstatus). Session retains the complete result unchanged. Result fields: health table.

Direct status result, not a response envelope; available without a program. See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### get_capabilities

**both** — `get_capabilities()`. Requires live owner; no open program prerequisite. Read-only dispatch; no iterator invalidation.

Lowlevel result: dense array of [Capability](../api/FIELDS.md#capability). Session retains the complete result unchanged. Result fields: capability array (coarse advertisement, not support oracle).

Dense array of Capability elements, not an invented response envelope. Coarse native advertisement is not an operation support oracle. See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### get_revision

**both** — `get_revision()`. Requires live owner; no open program prerequisite. Read-only dispatch; no iterator invalidation.

Lowlevel result: [RevisionResponse](../api/FIELDS.md#revisionresponse). Session retains the complete result unchanged. Result fields: program_id/modification_number: UInt64; program_path/file_id: strings; file_version:int32 and file_last_modified_time:int64: Lua integers.

Owner-level revision snapshot; file_version is checked int32, not UInt64. Zero/default metadata is not a populated durable producer. See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### open_program

**both** — `open_program(program_options)`. Requires live owner; no open program prerequisite. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [OpenProgramResponse](../api/FIELDS.md#openprogramresponse). Session retains the complete result unchanged. Result fields: full OpenProgramResponse; same owner on reopen.

Required program_options table; [construction keys](#construction-and-return-shapes) apply. Successful reopen replaces logical program context on the same owner; request metadata is echoed, not authoritative detection. See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### close_program

**both** — `close_program({policy='save' or 'discard'})`. Requires live owner; no open program prerequisite. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [CloseProgramResponse](../api/FIELDS.md#closeprogramresponse). Session retains the complete result unchanged. Result fields: closed:boolean.

Required options table with explicit policy save/discard; unloaded native program returns NO_PROGRAM. response.closed does not prove engine unloading. Session rejects save without state_path as NO_STATE_PATH before dispatch; lowlevel retains the empty-path save caveat. See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### shutdown

**both** — `shutdown({policy='save' or 'discard'})`. Requires live owner; no open program prerequisite. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [ShutdownResponse](../api/FIELDS.md#shutdownresponse). Session retains the complete result unchanged. Result fields: accepted:boolean, **not closed**.

Required policy table as for close_program; response.accepted is not response.closed. Session applies the same NO_STATE_PATH guard. Logical local program closure, not remote host termination or owner release. See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### save_program

**both** — `save_program()`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [SaveProgramResponse](../api/FIELDS.md#saveprogramresponse). Session retains the complete result unchanged. Result fields: saved:boolean.

Requires construction state_path; saved=true is not complete category persistence. No binary patch persistence guarantee. See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### discard_program

**lowlevel** — `discard_program()`. Requires live owner; no open program prerequisite. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [DiscardProgramResponse](../api/FIELDS.md#discardprogramresponse). Result fields: discarded:boolean.

Owner-only discarded=true acknowledgment, usable before opening a program and
after logical program closure. Does not revert mutations or byte overlay. No rollback. See [ownership/persistence limits](#ownership-persistence-and-effective-limits).


## Functions and decompilation

### get_function

**both** — `get_function(address)`. Requires live owner and open program. Read-only dispatch; no iterator invalidation.

Lowlevel result: [GetFunctionResponse](../api/FIELDS.md#getfunctionresponse). Session returns `response['function']`, nil, complete response; optional absence is nil,NOT_FOUND,response. Nested values: [FunctionRecord](../api/FIELDS.md#functionrecord). Result fields: optional function.

Session returns response['function']; `function` is a Lua keyword. Discovery is lazy; absence does not imply no code. See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### list_functions

**both** — `list_functions(range_page)`. Requires live owner and open program. Read-only dispatch; no iterator invalidation.

Lowlevel result: [ListFunctionsResponse](../api/FIELDS.md#listfunctionsresponse). Session retains the complete result unchanged. Nested values: [FunctionRecord](../api/FIELDS.md#functionrecord). Result fields: functions array.

Omitted/nil page uses [range/count defaults and compound bounds](#values-and-validation). See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### rename_function

**both** — `rename_function(address, new_name:string)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [RenameFunctionResponse](../api/FIELDS.md#renamefunctionresponse). Session retains the complete result unchanged. Result fields: renamed:boolean, name:string.

See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### list_basic_blocks

**both** — `list_basic_blocks(range_page)`. Requires live owner and open program. Read-only dispatch; no iterator invalidation.

Lowlevel result: [ListBasicBlocksResponse](../api/FIELDS.md#listbasicblocksresponse). Session retains the complete result unchanged. Nested values: [BasicBlockRecord](../api/FIELDS.md#basicblockrecord). Result fields: blocks array.

Omitted/nil page uses [range/count defaults and compound bounds](#values-and-validation). See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### list_cfg_edges

**both** — `list_cfg_edges(range_page)`. Requires live owner and open program. Read-only dispatch; no iterator invalidation.

Lowlevel result: [ListCFGEdgesResponse](../api/FIELDS.md#listcfgedgesresponse). Session retains the complete result unchanged. Nested values: [CFGEdgeRecord](../api/FIELDS.md#cfgedgerecord). Result fields: edges array.

Omitted/nil page uses [range/count defaults and compound bounds](#values-and-validation). See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### get_decompilation

**both** — `get_decompilation(address, options={})`. Requires live owner and open program. Read-only dispatch; no iterator invalidation.

Lowlevel result: [GetDecompilationResponse](../api/FIELDS.md#getdecompilationresponse). Session returns `response.decompilation`, nil, complete response; optional absence is nil,NOT_FOUND,response. Nested values: [DecompilationRecord](../api/FIELDS.md#decompilationrecord), [DecompileLocalRecord](../api/FIELDS.md#decompilelocalrecord), [DecompileTokenRecord](../api/FIELDS.md#decompiletokenrecord). Result fields: optional decompilation.

Lowlevel options only timeout_ms integer 0..INT_MAX, default 30000, ignored by native engine. Session only omitted/nil/empty options. Present incomplete/fallback/error_message output must be inspected, not treated as success. See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### list_decompilations

**lowlevel** — `list_decompilations(page={}, options={timeout_ms=30000})`. Requires live owner and open program. Read-only dispatch; no iterator invalidation.

Lowlevel result: [ListDecompilationsResponse](../api/FIELDS.md#listdecompilationsresponse). Nested values: [DecompilationRecord](../api/FIELDS.md#decompilationrecord), [DecompileLocalRecord](../api/FIELDS.md#decompilelocalrecord), [DecompileTokenRecord](../api/FIELDS.md#decompiletokenrecord). Result fields: decompilations:DecompilationRecord[].

Omitted/nil page uses [range/count defaults and compound bounds](#values-and-validation). Native batch, not a Lua loop. options only timeout_ms integer 0..INT_MAX default 30000, ignored. Inspect every completed/is_fallback/error_message record; mixed outcomes are possible. See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### list_leaf_functions

**lowlevel** — `list_leaf_functions(page={})`. Requires live owner and open program. Read-only dispatch; no iterator invalidation.

Lowlevel result: [ListFunctionsResponse](../api/FIELDS.md#listfunctionsresponse). Nested values: [FunctionRecord](../api/FIELDS.md#functionrecord). Result fields: functions:FunctionRecord[].

Omitted/nil page uses [range/count defaults and compound bounds](#values-and-validation). Analyzed-project reference index required. Raw ELF returns NOT_SUPPORTED. See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### get_function_signature

**both** — `get_function_signature(address)`. Requires live owner and open program. Read-only dispatch; no iterator invalidation.

Lowlevel result: [GetFunctionSignatureResponse](../api/FIELDS.md#getfunctionsignatureresponse). Session returns `response.signature`, nil, complete response; optional absence is nil,NOT_FOUND,response. Nested values: [FunctionSignatureRecord](../api/FIELDS.md#functionsignaturerecord), [ParameterRecord](../api/FIELDS.md#parameterrecord). Result fields: optional signature.

See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### list_function_signatures

**both** — `list_function_signatures(range_page)`. Requires live owner and open program. Read-only dispatch; no iterator invalidation.

Lowlevel result: [ListFunctionSignaturesResponse](../api/FIELDS.md#listfunctionsignaturesresponse). Session retains the complete result unchanged. Nested values: [FunctionSignatureRecord](../api/FIELDS.md#functionsignaturerecord), [ParameterRecord](../api/FIELDS.md#parameterrecord). Result fields: signatures array.

Omitted/nil page uses [range/count defaults and compound bounds](#values-and-validation). Pages-only: offset/limit select candidate functions before missing signatures are filtered; empty pages and returned count do not establish exhaustion. See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### set_function_signature

**lowlevel** — `set_function_signature(address:u, prototype:s)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [SetFunctionSignatureResponse](../api/FIELDS.md#setfunctionsignatureresponse). Result fields: updated:bool, function_name:s, prototype:s.

See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### rename_function_parameter

**lowlevel** — `rename_function_parameter(address:u, ordinal:n, new_name:s)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [RenameFunctionParameterResponse](../api/FIELDS.md#renamefunctionparameterresponse). Result fields: updated:bool, name:s.

See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### set_function_parameter_type

**lowlevel** — `set_function_parameter_type(address:u, ordinal:n, data_type:s)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [SetFunctionParameterTypeResponse](../api/FIELDS.md#setfunctionparametertyperesponse). Result fields: updated:bool, data_type:s.

See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### rename_function_local

**lowlevel** — `rename_function_local(address:u, local_id:s, new_name:s)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [RenameFunctionLocalResponse](../api/FIELDS.md#renamefunctionlocalresponse). Result fields: updated:bool, local_id:s, name:s.

local_id is the stable decompiled id/kind, not an array index; rename can reset on reload. See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### set_function_local_type

**lowlevel** — `set_function_local_type(address:u, local_id:s, data_type:s)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [SetFunctionLocalTypeResponse](../api/FIELDS.md#setfunctionlocaltyperesponse). Result fields: updated:bool, local_id:s, data_type:s.

local_id is stable id from decompilation, not an array index. True-local char retyping returns DECOMPILE_FAILED on exercised profile and leaves type unchanged; parameter-only evidence does not qualify it. See [ownership/persistence limits](#ownership-persistence-and-effective-limits).


## Instructions comments and defined data

### get_instruction

**both** — `get_instruction(address)`. Requires live owner and open program. Read-only dispatch; no iterator invalidation.

Lowlevel result: [GetInstructionResponse](../api/FIELDS.md#getinstructionresponse). Session returns `response.instruction`, nil, complete response; optional absence is nil,NOT_FOUND,response. Nested values: [InstructionRecord](../api/FIELDS.md#instructionrecord). Result fields: optional instruction.

Use a caller-confirmed mapped instruction entry with complete bytes; exact UInt64 alone does not prove safety. See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### list_instructions

**both** — `list_instructions(range_page)`. Requires live owner and open program. Read-only dispatch; no iterator invalidation.

Lowlevel result: [ListInstructionsResponse](../api/FIELDS.md#listinstructionsresponse). Session retains the complete result unchanged. Nested values: [InstructionRecord](../api/FIELDS.md#instructionrecord). Result fields: instructions array.

Omitted/nil page uses [range/count defaults and compound bounds](#values-and-validation). Decodes linearly from range_start until first gap, not mapped-region enumeration; default zero start can return empty despite code elsewhere. See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### get_comments

**both** — `get_comments(range_page)`. Requires live owner and open program. Read-only dispatch; no iterator invalidation.

Lowlevel result: [GetCommentsResponse](../api/FIELDS.md#getcommentsresponse). Session retains the complete result unchanged. Nested values: [CommentRecord](../api/FIELDS.md#commentrecord). Result fields: comments array.

Omitted/nil page uses [range/count defaults and compound bounds](#values-and-validation). See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### set_comment

**lowlevel** — `set_comment(address:u, kind:comment-kind, text:s)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [SetCommentResponse](../api/FIELDS.md#setcommentresponse). Result fields: updated:bool.

See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### delete_comment

**lowlevel** — `delete_comment(address:u, kind:comment-kind)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [DeleteCommentResponse](../api/FIELDS.md#deletecommentresponse). Result fields: deleted:bool.

See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### list_defined_strings

**lowlevel** — `list_defined_strings(range_page)`. Requires live owner and open program. Read-only dispatch; no iterator invalidation.

Lowlevel result: [ListDefinedStringsResponse](../api/FIELDS.md#listdefinedstringsresponse). Nested values: [DefinedStringRecord](../api/FIELDS.md#definedstringrecord). Result fields: strings array, constant-empty stub.

Omitted/nil page uses [range/count defaults and compound bounds](#values-and-validation). Constant-empty compatibility stub: ignores ranges/counts on a loaded program. No string database, scanner or iterator. See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### list_data_items

**lowlevel** — `list_data_items(page={})`. Requires live owner and open program. Read-only dispatch; no iterator invalidation.

Lowlevel result: [ListDataItemsResponse](../api/FIELDS.md#listdataitemsresponse). Nested values: [DataItemRecord](../api/FIELDS.md#dataitemrecord). Result fields: data_items:DataItemRecord[].

Omitted/nil page uses [range/count defaults and compound bounds](#values-and-validation). See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### apply_data_type

**lowlevel** — `apply_data_type(address:u, data_type:s)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [ApplyDataTypeResponse](../api/FIELDS.md#applydatatyperesponse). Result fields: updated:bool, data_type:s.

See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### rename_data_item

**lowlevel** — `rename_data_item(address:u, new_name:s)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [RenameDataItemResponse](../api/FIELDS.md#renamedataitemresponse). Result fields: updated:bool, name:s.

See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### delete_data_item

**lowlevel** — `delete_data_item(address:u)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [DeleteDataItemResponse](../api/FIELDS.md#deletedataitemresponse). Result fields: deleted:bool.

See [ownership/persistence limits](#ownership-persistence-and-effective-limits).


## Symbols and cross references

### get_symbol

**both** — `get_symbol(address)`. Requires live owner and open program. Read-only dispatch; no iterator invalidation.

Lowlevel result: [GetSymbolResponse](../api/FIELDS.md#getsymbolresponse). Session returns `response.symbol`, nil, complete response; optional absence is nil,NOT_FOUND,response. Nested values: [SymbolRecord](../api/FIELDS.md#symbolrecord). Result fields: optional symbol.

See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### list_symbols

**both** — `list_symbols(range_page)`. Requires live owner and open program. Read-only dispatch; no iterator invalidation.

Lowlevel result: [ListSymbolsResponse](../api/FIELDS.md#listsymbolsresponse). Session retains the complete result unchanged. Nested values: [SymbolRecord](../api/FIELDS.md#symbolrecord). Result fields: symbols array.

Omitted/nil page uses [range/count defaults and compound bounds](#values-and-validation). See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### rename_symbol

**both** — `rename_symbol(address, new_name:string)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [RenameSymbolResponse](../api/FIELDS.md#renamesymbolresponse). Session retains the complete result unchanged. Result fields: renamed:boolean, name:string.

See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### delete_symbol

**lowlevel** — `delete_symbol(address:u, name_filter:s)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [DeleteSymbolResponse](../api/FIELDS.md#deletesymbolresponse). Result fields: deleted:bool, deleted_count:uint32.

name_filter is required but ignored upstream; address selects deletion. Named data deletion can reveal inferred data at the same address/size. See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### list_xrefs

**both** — `list_xrefs(range_page)`. Requires live owner and open program. Read-only dispatch; no iterator invalidation.

Lowlevel result: [ListXrefsResponse](../api/FIELDS.md#listxrefsresponse). Session retains the complete result unchanged. Nested values: [XrefRecord](../api/FIELDS.md#xrefrecord). Result fields: xrefs array.

Omitted/nil page uses [range/count defaults and compound bounds](#values-and-validation). See [ownership/persistence limits](#ownership-persistence-and-effective-limits).


## Memory and byte patches

### read_bytes

**both** — `read_bytes(address, size:integer)`. Requires live owner and open program. Read-only dispatch; no iterator invalidation.

Lowlevel result: [ReadBytesResponse](../api/FIELDS.md#readbytesresponse). Session returns `response.data`, nil, complete response; optional absence is nil,NOT_FOUND,response. Result fields: data:binary string.

Required size integer 0..INT32_MAX before requested-buffer allocation/dispatch; zero allowed. Session returns binary string, not a record. Upper bound is not a memory-availability promise. See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### write_bytes

**both** — `write_bytes(address, binary_string)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [WriteBytesResponse](../api/FIELDS.md#writebytesresponse). Session retains the complete result unchanged. Result fields: bytes_written:uint32 integer.

Required length-preserving binary string, length <= INT_MAX. Copy-on-write overlay, not durable binary editing. See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### list_memory_blocks

**both** — `list_memory_blocks(count_page)`. Requires live owner and open program. Read-only dispatch; no iterator invalidation.

Lowlevel result: [ListMemoryBlocksResponse](../api/FIELDS.md#listmemoryblocksresponse). Session retains the complete result unchanged. Nested values: [MemoryBlockRecord](../api/FIELDS.md#memoryblockrecord). Result fields: blocks array.

Omitted/nil page uses [range/count defaults and compound bounds](#values-and-validation). See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### patch_bytes_batch

**lowlevel** — `patch_bytes_batch(patches)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [PatchBytesBatchResponse](../api/FIELDS.md#patchbytesbatchresponse). Result fields: patch_count:uint32, bytes_written:uint32.

Required dense array of [BytePatch](../api/FIELDS.md#bytepatch) inputs with required address and binary data. Count and total bytes <= UINT32_MAX; each data length <= INT_MAX. Empty arrays still dispatch. Applies in order, not atomic; counters total requested bytes without confirming writes. See [ownership/persistence limits](#ownership-persistence-and-effective-limits).


## Types aliases enums and members

### add_type_enum_member

**lowlevel** — `add_type_enum_member(type_id_or_path:s, name:s, value:i)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [AddTypeEnumMemberResponse](../api/FIELDS.md#addtypeenummemberresponse). Result fields: updated:bool.

See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### add_type_member

**lowlevel** — `add_type_member(parent_type_id_or_path:s, member_name:s, member_type:s, size:u)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [AddTypeMemberResponse](../api/FIELDS.md#addtypememberresponse). Result fields: updated:bool.

size required but ignored; native appends using referenced type. Query members for actual sizes; generic struct length can be zero. See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### create_type

**lowlevel** — `create_type(name:s, kind:s, size:u)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [CreateTypeResponse](../api/FIELDS.md#createtyperesponse). Result fields: updated:bool.

All positional arguments required, including ignored size. Only kind="struct" supported; other kinds return NOT_SUPPORTED. See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### create_type_alias

**lowlevel** — `create_type_alias(name:s, target_type:s)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [CreateTypeAliasResponse](../api/FIELDS.md#createtypealiasresponse). Result fields: updated:bool.

See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### create_type_enum

**lowlevel** — `create_type_enum(name:s, width:u, is_signed:bool)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [CreateTypeEnumResponse](../api/FIELDS.md#createtypeenumresponse). Result fields: updated:bool.

width and is_signed are required but not passed into native defineEnum. Observed width eight is distinct from unqualified experimental signedness claims. See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### delete_type

**lowlevel** — `delete_type(type_id_or_path:s)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [DeleteTypeResponse](../api/FIELDS.md#deletetyperesponse). Result fields: deleted:bool.

See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### delete_type_alias

**lowlevel** — `delete_type_alias(type_id_or_path:s)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [DeleteTypeAliasResponse](../api/FIELDS.md#deletetypealiasresponse). Result fields: deleted:bool.

See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### delete_type_enum_member

**lowlevel** — `delete_type_enum_member(type_id_or_path:s, ordinal:u)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [DeleteTypeEnumMemberResponse](../api/FIELDS.md#deletetypeenummemberresponse). Result fields: deleted:bool.

See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### delete_type_member

**lowlevel** — `delete_type_member(parent_type_id_or_path:s, ordinal:u)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [DeleteTypeMemberResponse](../api/FIELDS.md#deletetypememberresponse). Result fields: deleted:bool.

See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### get_type

**both** — `get_type(path:string)`. Requires live owner and open program. Read-only dispatch; no iterator invalidation.

Lowlevel result: [GetTypeResponse](../api/FIELDS.md#gettyperesponse). Session returns `response.type`, nil, complete response; optional absence is nil,NOT_FOUND,response. Nested values: [TypeRecord](../api/FIELDS.md#typerecord). Result fields: optional type.

findByName input: returned name works; leading-slash path_name is not normalized for this lookup. See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### list_type_aliases

**both** — `list_type_aliases(query:string, count_page)`. Requires live owner and open program. Read-only dispatch; no iterator invalidation.

Lowlevel result: [ListTypeAliasesResponse](../api/FIELDS.md#listtypealiasesresponse). Session retains the complete result unchanged. Nested values: [TypeAliasRecord](../api/FIELDS.md#typealiasrecord). Result fields: aliases array.

Omitted/nil page uses [range/count defaults and compound bounds](#values-and-validation). See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### list_type_enum_members

**both** — `list_type_enum_members(type_id_or_path:string, count_page)`. Requires live owner and open program. Read-only dispatch; no iterator invalidation.

Lowlevel result: [ListTypeEnumMembersResponse](../api/FIELDS.md#listtypeenummembersresponse). Session retains the complete result unchanged. Nested values: [TypeEnumMemberRecord](../api/FIELDS.md#typeenummemberrecord). Result fields: members array.

Omitted/nil page uses [range/count defaults and compound bounds](#values-and-validation). See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### list_type_enums

**both** — `list_type_enums(query:string, count_page)`. Requires live owner and open program. Read-only dispatch; no iterator invalidation.

Lowlevel result: [ListTypeEnumsResponse](../api/FIELDS.md#listtypeenumsresponse). Session retains the complete result unchanged. Nested values: [TypeEnumRecord](../api/FIELDS.md#typeenumrecord). Result fields: enums array.

Omitted/nil page uses [range/count defaults and compound bounds](#values-and-validation). See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### list_type_members

**both** — `list_type_members(type_id_or_path:string, count_page)`. Requires live owner and open program. Read-only dispatch; no iterator invalidation.

Lowlevel result: [ListTypeMembersResponse](../api/FIELDS.md#listtypemembersresponse). Session retains the complete result unchanged. Nested values: [TypeMemberRecord](../api/FIELDS.md#typememberrecord). Result fields: members array.

Omitted/nil page uses [range/count defaults and compound bounds](#values-and-validation). See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### list_type_unions

**both** — `list_type_unions(query:string, count_page)`. Requires live owner and open program. Read-only dispatch; no iterator invalidation.

Lowlevel result: [ListTypeUnionsResponse](../api/FIELDS.md#listtypeunionsresponse). Session retains the complete result unchanged. Nested values: [TypeUnionRecord](../api/FIELDS.md#typeunionrecord). Result fields: unions array.

Omitted/nil page uses [range/count defaults and compound bounds](#values-and-validation). See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### list_types

**both** — `list_types(query:string, count_page)`. Requires live owner and open program. Read-only dispatch; no iterator invalidation.

Lowlevel result: [ListTypesResponse](../api/FIELDS.md#listtypesresponse). Session retains the complete result unchanged. Nested values: [TypeRecord](../api/FIELDS.md#typerecord). Result fields: types array.

Omitted/nil page uses [range/count defaults and compound bounds](#values-and-validation). See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### rename_type

**lowlevel** — `rename_type(type_id_or_path:s, new_name:s)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [RenameTypeResponse](../api/FIELDS.md#renametyperesponse). Result fields: updated:bool, name:s.

See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### rename_type_enum_member

**lowlevel** — `rename_type_enum_member(type_id_or_path:s, ordinal:u, new_name:s)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [RenameTypeEnumMemberResponse](../api/FIELDS.md#renametypeenummemberresponse). Result fields: updated:bool.

See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### rename_type_member

**lowlevel** — `rename_type_member(parent_type_id_or_path:s, ordinal:u, new_name:s)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [RenameTypeMemberResponse](../api/FIELDS.md#renametypememberresponse). Result fields: updated:bool.

See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### set_type_alias_target

**lowlevel** — `set_type_alias_target(type_id_or_path:s, target_type:s)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [SetTypeAliasTargetResponse](../api/FIELDS.md#settypealiastargetresponse). Result fields: updated:bool.

See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### set_type_enum_member_comment

**lowlevel** — `set_type_enum_member_comment(type_id_or_path:s, ordinal:u, comment:s)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [SetTypeEnumMemberCommentResponse](../api/FIELDS.md#settypeenummembercommentresponse). Result fields: updated:bool.

See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### set_type_enum_member_value

**lowlevel** — `set_type_enum_member_value(type_id_or_path:s, ordinal:u, value:i)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [SetTypeEnumMemberValueResponse](../api/FIELDS.md#settypeenummembervalueresponse). Result fields: updated:bool.

See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### set_type_member_comment

**lowlevel** — `set_type_member_comment(parent_type_id_or_path:s, ordinal:u, comment:s)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [SetTypeMemberCommentResponse](../api/FIELDS.md#settypemembercommentresponse). Result fields: updated:bool.

See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### set_type_member_type

**lowlevel** — `set_type_member_type(parent_type_id_or_path:s, ordinal:u, member_type:s)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [SetTypeMemberTypeResponse](../api/FIELDS.md#settypemembertyperesponse). Result fields: updated:bool.

See [ownership/persistence limits](#ownership-persistence-and-effective-limits).


## Performance records

### add_perf_benchmark

**lowlevel** — `add_perf_benchmark(record)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [AddPerfBenchmarkResponse](../api/FIELDS.md#addperfbenchmarkresponse). Result fields: added:bool.

Required [PerfBenchmarkRecord](../api/FIELDS.md#perfbenchmarkrecord) table; omitted known fields use generated defaults. Native rejects empty bench_id. No durable benchmark-storage promise. See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### clear_perf_benchmarks

**lowlevel** — `clear_perf_benchmarks()`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [ClearPerfBenchmarksResponse](../api/FIELDS.md#clearperfbenchmarksresponse). Result fields: cleared:bool, removed_count:uint32.

See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### delete_perf_benchmark

**lowlevel** — `delete_perf_benchmark(bench_id:s)`. Requires live owner and open program. Dispatched mutation/lifecycle invalidates iterators even on failure/partial effect; validation-only failure does not.

Lowlevel result: [DeletePerfBenchmarkResponse](../api/FIELDS.md#deleteperfbenchmarkresponse). Result fields: deleted:bool.

See [ownership/persistence limits](#ownership-persistence-and-effective-limits).

### list_perf_benchmarks

**lowlevel** — `list_perf_benchmarks()`. Requires live owner and open program. Read-only dispatch; no iterator invalidation.

Lowlevel result: [ListPerfBenchmarksResponse](../api/FIELDS.md#listperfbenchmarksresponse). Nested values: [PerfBenchmarkRecord](../api/FIELDS.md#perfbenchmarkrecord). Result fields: records:PerfBenchmarkRecord[].

See [ownership/persistence limits](#ownership-persistence-and-effective-limits).


## Shared operation caveats

Lowlevel get_decompilation options accepts only timeout_ms integer 0..INT_MAX,
default 30000, **ignored** by the pinned engine. Session permits only omitted/nil
or empty options, rejects a timeout key, and promises no deadline/cancellation.
ReadBytes size is 0..INT32_MAX before buffer allocation/dispatch (native uint32
width does not override downstream signed int4). WriteBytes length <= INT_MAX.
Bounds are not promises of memory availability; never probe multi-GB allocations
just to check a limit. GetType forwards findByName input: returned name works;
leading-slash path_name is not normalized into a successful lookup.

Page fields match core range grammar: range_start=UInt64 zero,
range_end=UInt64 max, limit=100, offset=0. Zero end is native maximum sentinel for
functions/data items and the function candidates used by decompilation. Strict
positive limit and nonnegative offset, sum <= INT_MAX. Collections above INT_MAX
unsupported. timeout_ms is integer 0..INT_MAX and **ignored** by native batch.
Comment kinds ([CommentKind](../api/FIELDS.md#commentkind)): unspecified/eol/pre/post/plate/repeatable (native zero through five).
Unknown keys, sparse patch arrays, wrong types and numeric overflows are rejected.
Patch count and summed bytes <= UINT32_MAX; each patch <= INT_MAX bytes. These are
bounds, not memory availability guarantees. Empty patch arrays remain native calls.

Benchmark input field defaults and conversion types are defined by
[PerfBenchmarkRecord](../api/FIELDS.md#perfbenchmarkrecord). Native rejects empty
bench_id. DataItemRecord ends are inclusive. All ten benchmark fields are
returned, including zero and negative numbers; no truthiness defaults.

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
