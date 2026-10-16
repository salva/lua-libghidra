# Lua API reference

Use this reference to find a method's arguments, return values and limits. For a
first working script, start with the [tutorial](TUTORIAL.md) or
[examples](EXAMPLES.md). Links to the field reference describe each result table
in detail.

`libghidra` provides the Session interface. `libghidra.lowlevel` exposes the
native client's complete responses and additional operations. You can access
that same client with `session:native()`; this does not create another engine.
Only one client may be live in a process.

This reference describes libghidra at
`d51ca813ae1b6b59519551a9be8c0b1ad74d862d` on Linux x86-64 with ordinary PUC
Lua 5.4: signed 64-bit integers and eight-byte double numbers, tested with 5.4.6.
The module uses the existing Lua VM. Do not mix independently managed engines
in the same process. Original wrapper Copyright 2026 Salvador Fandiño, MIT;
dependency terms are in [NOTICES](NOTICES.md).

## Method index

Entries marked **both** are available on Session and the lowlevel client.
**lowlevel** methods are also accessible through `session:native()`. Module
functions are labeled separately; all other calls use Lua's colon syntax.
The **read** and **change** labels refer to the shared
[state and iterator rules](#lifecycle-status-and-capabilities).

Arguments without a default are required. Signatures use these abbreviations:
`s` for a string, `u` for an exact unsigned 64-bit value, `i` for a signed 64-bit
Lua integer, `n` for an integer from 0 to INT_MAX, and `bool` for a boolean.
The [value and pagination rules](#values-and-validation) apply throughout.

A response **envelope** is the complete table returned by the native API. Its
records are detached copies, not handles into the engine. Lowlevel calls return
that complete response or `nil,error`. Session unwraps a few common reads, as
described below and beside each method.

- Module helpers: [open](#open), [local_client](#local_client), [check](#check), [u64](#u64), [native](#native), [close](#close), [iter_functions](#iter_functions), [iter_symbols](#iter_symbols), [iter_memory_blocks](#iter_memory_blocks)
- Lifecycle status and capabilities: [get_status](#get_status), [get_capabilities](#get_capabilities), [get_revision](#get_revision), [open_program](#open_program), [close_program](#close_program), [shutdown](#shutdown), [save_program](#save_program), [discard_program](#discard_program)
- Functions and decompilation: [get_function](#get_function), [list_functions](#list_functions), [rename_function](#rename_function), [list_basic_blocks](#list_basic_blocks), [list_cfg_edges](#list_cfg_edges), [get_decompilation](#get_decompilation), [list_decompilations](#list_decompilations), [list_leaf_functions](#list_leaf_functions), [get_function_signature](#get_function_signature), [list_function_signatures](#list_function_signatures), [set_function_signature](#set_function_signature), [rename_function_parameter](#rename_function_parameter), [set_function_parameter_type](#set_function_parameter_type), [rename_function_local](#rename_function_local), [set_function_local_type](#set_function_local_type)
- Instructions comments and defined data: [get_instruction](#get_instruction), [list_instructions](#list_instructions), [get_comments](#get_comments), [set_comment](#set_comment), [delete_comment](#delete_comment), [list_defined_strings](#list_defined_strings), [list_data_items](#list_data_items), [apply_data_type](#apply_data_type), [rename_data_item](#rename_data_item), [delete_data_item](#delete_data_item)
- Symbols and cross references: [get_symbol](#get_symbol), [list_symbols](#list_symbols), [rename_symbol](#rename_symbol), [delete_symbol](#delete_symbol), [list_xrefs](#list_xrefs)
- Memory and byte patches: [read_bytes](#read_bytes), [write_bytes](#write_bytes), [list_memory_blocks](#list_memory_blocks), [patch_bytes_batch](#patch_bytes_batch)
- Types aliases enums and members: [add_type_enum_member](#add_type_enum_member), [add_type_member](#add_type_member), [create_type](#create_type), [create_type_alias](#create_type_alias), [create_type_enum](#create_type_enum), [delete_type](#delete_type), [delete_type_alias](#delete_type_alias), [delete_type_enum_member](#delete_type_enum_member), [delete_type_member](#delete_type_member), [get_type](#get_type), [list_type_aliases](#list_type_aliases), [list_type_enum_members](#list_type_enum_members), [list_type_enums](#list_type_enums), [list_type_members](#list_type_members), [list_type_unions](#list_type_unions), [list_types](#list_types), [rename_type](#rename_type), [rename_type_enum_member](#rename_type_enum_member), [rename_type_member](#rename_type_member), [set_type_alias_target](#set_type_alias_target), [set_type_enum_member_comment](#set_type_enum_member_comment), [set_type_enum_member_value](#set_type_enum_member_value), [set_type_member_comment](#set_type_member_comment), [set_type_member_type](#set_type_member_type)
- Performance records: [add_perf_benchmark](#add_perf_benchmark), [clear_perf_benchmarks](#clear_perf_benchmarks), [delete_perf_benchmark](#delete_perf_benchmark), [list_perf_benchmarks](#list_perf_benchmarks)

## Construction and return shapes

`require('libghidra.lowlevel').local_client(client_options)` creates the client
that owns the native engine. It returns that owner or `nil,error`. Omit the
options, pass nil, or use `{}` for defaults:

| Client option | Type and default |
| --- | --- |
| `ghidra_root` | String, default empty. Supply an external specification root, or leave empty to use embedded specifications. |
| `state_path` | String, default empty. The path used for saved state. |
| `default_arch` | String, default empty. Default architecture selection. |
| `pool_size` | Integer, default 1. Only 1 is accepted. |

Configuration strings cannot contain embedded NUL bytes.

`require('libghidra').open{client=client_options,program=program_options}` returns
`session,nil,open_response` or `nil,error`. If opening fails, it releases the new
owner, including when an error occurs while returning values to Lua. The outer
table accepts only `client` and `program`; `program` is required.

The Session program options are `program_path`, `project_path`, `language_id`,
`compiler_spec_id` and `format` (strings, default empty), and `base_address`
(exact uint64, default zero). At least one path must be nonempty. A nonempty
`project_path` selects project loading.

Supply explicit supported language and compiler hints. The open response echoes
the requested or default values; it does not confirm automatic detection.
Lowlevel `owner:open_program(program_options)` also accepts `project_name`
(string, default empty) and `read_only` (boolean, default false), but the engine
**ignores both**. Neither Session construction nor `session:open_program` accepts
these two extra keys.

Session returns complete responses for page queries, edits and lifecycle calls.
The following reads instead return `value,nil,response`, giving you the useful
field first while preserving the full response as the third return value:

| Session read | Field |
| --- | --- |
| get_function | `response['function']` |
| get_instruction | instruction |
| get_symbol | symbol |
| get_type | type |
| get_function_signature | signature |
| get_decompilation | decompilation |
| read_bytes | data |

If an optional field is absent, Session returns `nil,error,response` with error
code `NOT_FOUND`. A native failure returns `nil,error` without a third response.
False, zero, empty strings and empty tables all count as present values.

Both modules export `check(value,err,response)`. It returns `value,response`
when value is not nil, and otherwise raises `err`. **It checks presence, not
success flags.** A decompilation with `completed=false` or `is_fallback=true`
can still be inspected, but is not complete. Also inspect `error_message` and
`pseudocode`. Likewise, a mutation's boolean or counter acknowledges the request;
it does not independently verify the effect.

Error tables contain `code`, `message`, `operation`, `backend` and sometimes
`upstream_code`. The backend is `local` for SDK failures and `binding` for errors
in argument or value handling. Check the code rather than treating all failures
alike: `CLOSED`, `NO_PROGRAM`, `NOT_FOUND`, `INVALID_ARGUMENT`, `NOT_SUPPORTED`
and `NO_STATE_PATH` describe different conditions, as do native resource errors.
C++ exceptions are caught at the binding boundary. Lua allocation and runtime
errors still raise normally; iterators raise structured errors.

## Values and validation

**Addresses and other unsigned 64-bit values.** Every native uint64 output is an
immutable `UInt64`, even for small IDs, sizes, revision numbers and ordinals.
This preserves the full range without rounding. Use
`u64(nonnegative_integer_or_strict_string)` to construct one; it returns the exact
value or `nil,error`. A uint64 argument also accepts an existing UInt64.

Strings must contain decimal digits or hexadecimal digits prefixed with `0x`,
with no sign, whitespace or trailing bytes. Floating-point values and overflow
are rejected. Prefix `nm`'s hexadecimal output with `0x` before passing it in.

| UInt64 method | Result |
| --- | --- |
| `hex()` | `0x` followed by 16 lowercase hexadecimal digits. `tostring` uses the same form. |
| `decimal()` | The exact decimal string. |
| `to_integer()` | A Lua integer, or `nil,error` if the value does not fit. |
| `add(n)`, `sub(n)` | A new UInt64, or `nil,error` on overflow. `n` must be a nonnegative Lua integer. |

Equality compares UInt64 values; comparison with an unrelated type is false.
Ordered comparisons require two UInt64 operands and raise on other types.
Arithmetic operators are not provided. For table keys, use `hex()` or `decimal()`:
distinct UInt64 objects do not become the same key merely because their values
are equal.

**Other values.** Signed and narrower integers are range-checked Lua integers;
finite double fields are Lua numbers. Arrays are dense tables indexed from 1,
while native offsets and ordinals still start at 0. Bytes are binary strings
that preserve NUL bytes. Text is not transcoded. Known enum values use documented
names; unknown enum values in **responses** remain numeric. Comment-kind inputs
accept only the documented names. Absent optional values are nil.

Unknown keys, sparse arrays, wrong types and out-of-range values fail before a
request reaches the engine. Omit an option to use its default; false and zero do
not trigger defaults. Required positional arguments remain required even when
the underlying native model has defaults. The generated [field reference](../api/FIELDS.md)
lists native types, defaults and conversions. A listed field may remain empty in
practice, and models in its native-only appendix are not supported Lua operations.

**Pages.** `range_page` defaults to
`{range_start=0,range_end=UINT64_MAX,limit=100,offset=0}`. `count_page` accepts
only `limit` and `offset`, with the same defaults. Omit a page or pass nil to use
these defaults. Ranges include both endpoints. `limit` (or iterator `page_size`)
must be positive; `offset` must be nonnegative. Each value and their sum must be
at most INT_MAX.

For function, instruction, symbol, comment and data queries, and for the function
candidates in batch decompilation, an explicit `range_end=0` means UINT64_MAX.
It does **not** restrict the query to address zero. Other operations with ranges
do not necessarily interpret zero this way.

## Module helpers and owner views

### open

Session module function `open{client=client_options, program=program_options}`.
Creates an owner and opens a program, returning `session,nil,response` with an
[OpenProgramResponse](../api/FIELDS.md#openprogramresponse), or `nil,error`.
On failure it releases the newly created owner, including errors while returning
values to Lua. Omit `client` or pass nil for defaults. `program` must be a table
with at least one nonempty input path. See [construction options](#construction-and-return-shapes).

### local_client

Lowlevel module function `local_client(client_options)`. Creates the native owner
without opening a program. Returns owner userdata or `nil,error`; a second live
owner fails with `CLIENT_IN_USE`. Omit the options or pass nil for `{}`. See
[construction options](#construction-and-return-shapes) and
[LocalClientOptions](../api/FIELDS.md#localclientoptions) for keys and defaults.

### check

Both modules provide `check(value,err,response)`. It returns `value,response`
when value is not nil and otherwise raises `err`. It needs no owner and makes no
native call. False and zero count as present values. This helper does not validate
success flags such as a decompilation's `completed` field.

### u64

Both modules provide `u64(nonnegative_integer_or_strict_string)`. It returns an
exact UInt64 or `nil,error`, without needing an owner or calling the engine.
See [values and validation](#values-and-validation) for accepted text and the
`hex()`, `decimal()`, `to_integer()`, `add(n)` and `sub(n)` methods. These values
are immutable and never use floating-point arithmetic.

### native

Session-only `native()` returns the underlying lowlevel owner, even if it has
already closed. This is an alias, not a new engine. Both views share the same
state and lifetime; obtaining the alias makes no native call and changes nothing.

### close

Both views provide `close()`, which releases the native owner and the process's
client slot, permanently closes all aliases and invalidates iterators. It returns
true, including on repeated calls. It does not save. Lua 5.4 `__close` preserves
an error already being raised from the scope. Detached results remain usable.

### iter_functions

Session-only `iter_functions(options)` yields
[FunctionRecord](../api/FIELDS.md#functionrecord) values. Call the returned
iterator with no arguments to get the next record. It fetches pages as needed,
so the program must remain open and its generation must remain unchanged.
Otherwise it raises a structured error.

Omitted or nil options use `page_size=100`, `offset=0`, `range_start=0` and
`range_end=UINT64_MAX`. Shared [pagination limits](#values-and-validation) apply.
The iterator does not mutate the program or take an eager snapshot.

### iter_symbols

Session-only `iter_symbols(options)` yields
[SymbolRecord](../api/FIELDS.md#symbolrecord) values through a zero-argument
iterator. It uses the same lazy fetching, state checks and options as
`iter_functions`: `page_size=100`, `offset=0`, `range_start=0` and
`range_end=UINT64_MAX` when options are omitted or nil. Shared
[pagination limits](#values-and-validation) apply. It does not mutate the program
or take an eager snapshot.

### iter_memory_blocks

Session-only `iter_memory_blocks(options)` yields
[MemoryBlockRecord](../api/FIELDS.md#memoryblockrecord) values through a
zero-argument iterator. It uses the same lazy fetching and state checks as
`iter_functions`, but accepts only count options: `page_size=100` and `offset=0`
when omitted or nil. It has no address range options. Shared
[pagination limits](#values-and-validation) apply; there is no mutation or eager
snapshot.

### Iteration guarantees

These are the only three iterators. Each keeps one page in memory and advances
by the number of records actually returned. Before every yield, including a
buffered record, it checks the owner's shared generation. A short page does not
necessarily end traversal. Duplicate, reversed, oversized or nonadvancing pages
raise an error rather than being silently sorted or deduplicated.

Functions are ordered by entry address. Symbols follow the native `symbol_id`
order and are identified by address, name and namespace. Memory blocks are ordered
by start address and name. These traversal rules do not provide a snapshot of
arbitrary engine changes.

Other collections are **pages-only**. Signature offsets count candidate functions
before missing signatures are filtered, so an empty page does not prove exhaustion.
Types can have colliding anonymous identities; basic blocks follow structural
order; cross-reference results combine multiple phases. There are no iterators
for these, control-flow edges, subtypes, comments or specialist collections.
Instruction pages decode sequentially from `range_start` and stop at a decode
gap. A default start of zero can therefore produce an empty page despite code
elsewhere.

## Lifecycle status and capabilities

The entries below identify **read** and **change** operations. Both require a live
owner. Reads leave iterators valid. Changes invalidate iterators once sent to the
engine, even if they fail or only partly succeed; argument validation failures
do not. Unless an entry says otherwise, a program must be open. See
[ownership and persistence](#ownership-persistence-and-effective-limits) for how
closing, saving and reopening affect the owner and edits.

### get_status

**both** · read — `get_status()`. No open program required.

Returns the [HealthStatus](../api/FIELDS.md#healthstatus) table directly on both
interfaces. Use it to check the client even when no program is open.

### get_capabilities

**both** · read — `get_capabilities()`. No open program required.

Returns a dense array of [Capability](../api/FIELDS.md#capability) records directly
on both interfaces. These are broad native capability labels, not a guarantee
that a particular operation works with your input. Consult the method's limits.

### get_revision

**both** · read — `get_revision()`. No open program required.

Both interfaces return [RevisionResponse](../api/FIELDS.md#revisionresponse).
`program_id` and `modification_number` are UInt64 values; `program_path` and
`file_id` are strings. `file_version` is a signed 32-bit Lua integer and
`file_last_modified_time` is a signed 64-bit Lua integer.

Returns the owner's current revision metadata. `file_version` is a checked
32-bit Lua integer, not UInt64. Fields can be zero or default-valued; do not use
them as proof that a file version was detected or saved persistently.

### open_program

**both** · change — `open_program(program_options)`. No open program required.

Both interfaces return the complete [OpenProgramResponse](../api/FIELDS.md#openprogramresponse).

Pass the required `program_options` table using the
[construction keys](#construction-and-return-shapes). A successful reopen
replaces the program on the same owner. The response echoes requested language
and compiler settings; it does not confirm automatic detection.

### close_program

**both** · change — `close_program({policy='save' or 'discard'})`. Callable without an open program.

Both interfaces return [CloseProgramResponse](../api/FIELDS.md#closeprogramresponse),
with the boolean acknowledgment `closed`.

The options table and its `policy` are required. Without a loaded program, the
native call returns `NO_PROGRAM`. A true `response.closed` means program access
has closed, not that the engine has unloaded or the owner has been released.
Session rejects `policy='save'` without a construction `state_path`, returning
`NO_STATE_PATH` before calling the engine. The lowlevel interface can close
without saving when that path is empty. See the
[lifecycle and persistence limits](#ownership-persistence-and-effective-limits).

### shutdown

**both** · change — `shutdown({policy='save' or 'discard'})`. Callable without an open program.

Both interfaces return [ShutdownResponse](../api/FIELDS.md#shutdownresponse),
with the boolean acknowledgment `accepted`.

Requires the same policy table as `close_program`, and Session applies the same
`NO_STATE_PATH` check. This closes access to the local program; it does not release
the owner or terminate a remote host. The acknowledgment is `response.accepted`,
not `response.closed`.

### save_program

**both** · change — `save_program()`.

Both interfaces return [SaveProgramResponse](../api/FIELDS.md#saveprogramresponse),
with the boolean acknowledgment `saved`.

Set `state_path` when constructing the client. `saved=true` acknowledges the
request, but does not mean every edit was preserved. In particular, binary byte
patches are not guaranteed to survive. Read the
[category-specific persistence limits](#ownership-persistence-and-effective-limits).

### discard_program

**lowlevel** · change — `discard_program()`.

Requires live owner; no open program prerequisite.

Returns [DiscardProgramResponse](../api/FIELDS.md#discardprogramresponse),
with the boolean acknowledgment `discarded`.

You can use this call before opening a program or after logical program closure.
It invalidates iterators when sent to the engine. `discarded=true` is only an
acknowledgment: it does not undo edits or byte overlays. **No rollback is provided.**


## Functions and decompilation

### get_function

**both** · read — `get_function(address)`.

Result fields: optional function.

Looks up a function at `address`. Lowlevel returns
[GetFunctionResponse](../api/FIELDS.md#getfunctionresponse), whose optional
`function` field is a [FunctionRecord](../api/FIELDS.md#functionrecord).
Session returns that record as `value,nil,response`, or `nil,error,response`
with code `NOT_FOUND` when it is absent.

Use `response['function']` to access the field yourself: `function` is a Lua
keyword. Discovery happens lazily, so decompile a known mapped function first.
An absent record does not mean there is no code at the address.

### list_functions

**both** · read — `list_functions(range_page)`.

Result fields: functions array.

Returns [ListFunctionsResponse](../api/FIELDS.md#listfunctionsresponse) on both
interfaces. Its `functions` array contains [FunctionRecord](../api/FIELDS.md#functionrecord)
values.

Omit the page or pass nil for the shared [page defaults](#values-and-validation).

### rename_function

**both** · change — `rename_function(address, new_name:string)`.

Renames the function at `address`. Both interfaces return
[RenameFunctionResponse](../api/FIELDS.md#renamefunctionresponse), with the boolean
acknowledgment `renamed` and string `name`.


### list_basic_blocks

**both** · read — `list_basic_blocks(range_page)`.

Result fields: blocks array.

Returns [ListBasicBlocksResponse](../api/FIELDS.md#listbasicblocksresponse) on both
interfaces. Its `blocks` array contains [BasicBlockRecord](../api/FIELDS.md#basicblockrecord)
values describing basic blocks: instruction sequences without internal branches.

Omit the page or pass nil for the shared [page defaults](#values-and-validation).

### list_cfg_edges

**both** · read — `list_cfg_edges(range_page)`.

Result fields: edges array.

Returns [ListCFGEdgesResponse](../api/FIELDS.md#listcfgedgesresponse) on both
interfaces. Its `edges` array contains [CFGEdgeRecord](../api/FIELDS.md#cfgedgerecord)
values describing connections in the control-flow graph (CFG).

Omit the page or pass nil for the shared [page defaults](#values-and-validation).

### get_decompilation

**both** · read — `get_decompilation(address, options={})`.

Decompiles the function at `address`. Lowlevel returns
[GetDecompilationResponse](../api/FIELDS.md#getdecompilationresponse), containing
an optional [DecompilationRecord](../api/FIELDS.md#decompilationrecord). Session
returns that record as `value,nil,response`, or `nil,error,response` with code
`NOT_FOUND` when absent. Nested record types are
[DecompileLocalRecord](../api/FIELDS.md#decompilelocalrecord) and
[DecompileTokenRecord](../api/FIELDS.md#decompiletokenrecord).

On Session, omit `options`, pass nil, or pass an empty table. Lowlevel accepts
only `timeout_ms`, an integer from 0 to INT_MAX with default 30000. The native
engine **ignores this timeout**; it does not impose a deadline.

Inspect `completed`, `is_fallback` and `error_message` before using the pseudocode
as a complete result. An incomplete or fallback record can still contain text.
The [decompile example](EXAMPLES.md#decompile-a-known-function) shows how to
classify these outcomes.

### list_decompilations

**lowlevel** · read — `list_decompilations(page={}, options={timeout_ms=30000})`.

Returns [ListDecompilationsResponse](../api/FIELDS.md#listdecompilationsresponse).
Its `decompilations` array contains [DecompilationRecord](../api/FIELDS.md#decompilationrecord)
values, which can include [DecompileLocalRecord](../api/FIELDS.md#decompilelocalrecord)
and [DecompileTokenRecord](../api/FIELDS.md#decompiletokenrecord) values.

Decompiles a page of function candidates in one native batch. An omitted or nil
page uses the [range defaults](#values-and-validation). The only option is
`timeout_ms`, an integer from 0 to INT_MAX, default 30000; the engine ignores it.
Inspect `completed`, `is_fallback` and `error_message` in **every** returned record.
A single batch can contain complete, fallback and incomplete results.

### list_leaf_functions

**lowlevel** · read — `list_leaf_functions(page={})`.

Returns [ListFunctionsResponse](../api/FIELDS.md#listfunctionsresponse), with a
`functions` array of [FunctionRecord](../api/FIELDS.md#functionrecord) values.

Requires an analyzed project's reference index. Raw ELF input returns
`NOT_SUPPORTED`. Omit the page or pass nil for the
[range defaults](#values-and-validation).

### get_function_signature

**both** · read — `get_function_signature(address)`.

Lowlevel returns [GetFunctionSignatureResponse](../api/FIELDS.md#getfunctionsignatureresponse).
Its optional `signature` is a [FunctionSignatureRecord](../api/FIELDS.md#functionsignaturerecord),
with nested [ParameterRecord](../api/FIELDS.md#parameterrecord) values. Session
returns `response.signature,nil,response`, or `nil,error,response` with code
`NOT_FOUND` when the signature is absent.


### list_function_signatures

**both** · read — `list_function_signatures(range_page)`.

Both interfaces return [ListFunctionSignaturesResponse](../api/FIELDS.md#listfunctionsignaturesresponse).
Its `signatures` array contains [FunctionSignatureRecord](../api/FIELDS.md#functionsignaturerecord)
values with nested [ParameterRecord](../api/FIELDS.md#parameterrecord) values.

Omit the page or pass nil for the [range defaults](#values-and-validation).
This query is pages-only: `offset` and `limit` select candidate functions
**before** functions with missing signatures are filtered out. An empty or short
result therefore does not tell you that you have reached the last candidate.

### set_function_signature

**lowlevel** · change — `set_function_signature(address:u, prototype:s)`.

Sets the function's prototype. Returns [SetFunctionSignatureResponse](../api/FIELDS.md#setfunctionsignatureresponse),
with boolean `updated` and strings `function_name` and `prototype`.


### rename_function_parameter

**lowlevel** · change — `rename_function_parameter(address:u, ordinal:n, new_name:s)`.

Renames the parameter selected by its zero-based `ordinal`. Returns
[RenameFunctionParameterResponse](../api/FIELDS.md#renamefunctionparameterresponse),
with boolean `updated` and string `name`.


### set_function_parameter_type

**lowlevel** · change — `set_function_parameter_type(address:u, ordinal:n, data_type:s)`.

Changes the type of the parameter selected by its zero-based `ordinal`. Returns
[SetFunctionParameterTypeResponse](../api/FIELDS.md#setfunctionparametertyperesponse),
with boolean `updated` and string `data_type`.


### rename_function_local

**lowlevel** · change — `rename_function_local(address:u, local_id:s, new_name:s)`.

Returns [RenameFunctionLocalResponse](../api/FIELDS.md#renamefunctionlocalresponse),
with boolean `updated` and strings `local_id` and `name`.

Use the stable `local_id` from decompilation to identify the local variable, not
its position in the array. A rename can reset when the program is reloaded; see
[persistence limits](#ownership-persistence-and-effective-limits).

### set_function_local_type

**lowlevel** · change — `set_function_local_type(address:u, local_id:s, data_type:s)`.

Returns [SetFunctionLocalTypeResponse](../api/FIELDS.md#setfunctionlocaltyperesponse),
with boolean `updated` and strings `local_id` and `data_type`.

Use the stable `local_id` from decompilation, not an array index. Changing a true
local variable's type to `char` returns `DECOMPILE_FAILED` on the tested profile
and leaves the type unchanged. Successful parameter edits do not establish
support for retyping local variables.


## Instructions comments and defined data

### get_instruction

**both** · read — `get_instruction(address)`.

Result fields: optional instruction.

Lowlevel returns [GetInstructionResponse](../api/FIELDS.md#getinstructionresponse),
with an optional [InstructionRecord](../api/FIELDS.md#instructionrecord) in
`instruction`. Session returns `response.instruction,nil,response`, or
`nil,error,response` with code `NOT_FOUND` when absent.

Supply a verified mapped instruction address and confirm that all its bytes are
mapped. An exact UInt64 value alone cannot make an address safe to read.

### list_instructions

**both** · read — `list_instructions(range_page)`.

Result fields: instructions array.

Both interfaces return [ListInstructionsResponse](../api/FIELDS.md#listinstructionsresponse),
with an `instructions` array of [InstructionRecord](../api/FIELDS.md#instructionrecord)
values.

Decodes instructions sequentially from `range_start` until the first decode gap.
It does not search across mapped regions. Set a known instruction start: the
default start of zero can return an empty page even when there is code elsewhere.
An omitted or nil page uses the [range defaults](#values-and-validation).

### get_comments

**both** · read — `get_comments(range_page)`.

Both interfaces return [GetCommentsResponse](../api/FIELDS.md#getcommentsresponse),
with a `comments` array of [CommentRecord](../api/FIELDS.md#commentrecord) values.

Omit the page or pass nil for the shared [page defaults](#values-and-validation).

### set_comment

**lowlevel** · change — `set_comment(address:u, kind:comment-kind, text:s)`.

Sets the text for the given address and [comment kind](../api/FIELDS.md#commentkind).
Returns [SetCommentResponse](../api/FIELDS.md#setcommentresponse) with boolean `updated`.


### delete_comment

**lowlevel** · change — `delete_comment(address:u, kind:comment-kind)`.

Deletes the comment of the given [kind](../api/FIELDS.md#commentkind) at `address`.
Returns [DeleteCommentResponse](../api/FIELDS.md#deletecommentresponse) with boolean `deleted`.


### list_defined_strings

**lowlevel** · read — `list_defined_strings(range_page)`.

Returns [ListDefinedStringsResponse](../api/FIELDS.md#listdefinedstringsresponse).
The `strings` field is an array of [DefinedStringRecord](../api/FIELDS.md#definedstringrecord)
values in the schema, but is always empty in this implementation.

This is a compatibility stub: with a loaded program it always returns an empty
`strings` array and ignores the requested range and count. It does not discover
strings, maintain a string database or provide an iterator. An empty result is
not evidence that the binary has no strings. Omitted or nil pages still use the
shared [page defaults](#values-and-validation).

### list_data_items

**lowlevel** · read — `list_data_items(page={})`.

Returns [ListDataItemsResponse](../api/FIELDS.md#listdataitemsresponse), with a
`data_items` array of [DataItemRecord](../api/FIELDS.md#dataitemrecord) values.

Omit the page or pass nil for the shared [page defaults](#values-and-validation).

### apply_data_type

**lowlevel** · change — `apply_data_type(address:u, data_type:s)`.

Applies the named data type at `address`. Returns
[ApplyDataTypeResponse](../api/FIELDS.md#applydatatyperesponse), with boolean
`updated` and string `data_type`.


### rename_data_item

**lowlevel** · change — `rename_data_item(address:u, new_name:s)`.

Renames the data item at `address`. Returns
[RenameDataItemResponse](../api/FIELDS.md#renamedataitemresponse), with boolean
`updated` and string `name`.


### delete_data_item

**lowlevel** · change — `delete_data_item(address:u)`.

Deletes the data item at `address`. Returns
[DeleteDataItemResponse](../api/FIELDS.md#deletedataitemresponse) with boolean `deleted`.



## Symbols and cross references

### get_symbol

**both** · read — `get_symbol(address)`.

Result fields: optional symbol.

Lowlevel returns [GetSymbolResponse](../api/FIELDS.md#getsymbolresponse), with an
optional [SymbolRecord](../api/FIELDS.md#symbolrecord) in `symbol`. Session returns
`response.symbol,nil,response`, or `nil,error,response` with code `NOT_FOUND`
when absent.


### list_symbols

**both** · read — `list_symbols(range_page)`.

Result fields: symbols array.

Both interfaces return [ListSymbolsResponse](../api/FIELDS.md#listsymbolsresponse),
with a `symbols` array of [SymbolRecord](../api/FIELDS.md#symbolrecord) values.

Omit the page or pass nil for the shared [page defaults](#values-and-validation).

### rename_symbol

**both** · change — `rename_symbol(address, new_name:string)`.

Renames the symbol at `address`. Both interfaces return
[RenameSymbolResponse](../api/FIELDS.md#renamesymbolresponse), with boolean
`renamed` and string `name`.


### delete_symbol

**lowlevel** · change — `delete_symbol(address:u, name_filter:s)`.

Returns [DeleteSymbolResponse](../api/FIELDS.md#deletesymbolresponse), with boolean
`deleted` and unsigned 32-bit integer `deleted_count`.

`name_filter` is required, but the engine ignores it and selects by `address`
alone. Deleting named data can reveal inferred data at the same address and size;
it does not guarantee that the location disappears from later queries.

### list_xrefs

**both** · read — `list_xrefs(range_page)`.

Result fields: xrefs array.

Both interfaces return [ListXrefsResponse](../api/FIELDS.md#listxrefsresponse),
with an `xrefs` array of [XrefRecord](../api/FIELDS.md#xrefrecord) values describing
cross references.

Omit the page or pass nil for the shared [page defaults](#values-and-validation).


## Memory and byte patches

### read_bytes

**both** · read — `read_bytes(address, size:integer)`.

Reads `size` bytes starting at `address`. Lowlevel returns
[ReadBytesResponse](../api/FIELDS.md#readbytesresponse), with the bytes in `data`.
Session returns `response.data,nil,response`. The data is a binary string that
preserves NUL bytes, not a record.

`size` is required and must be an integer from 0 to INT32_MAX; zero is allowed.
This bound is checked before allocating the requested buffer or calling the
engine. It is a numeric limit, not a promise that enough memory is available.
Use a mapped region you have verified.

### write_bytes

**both** · change — `write_bytes(address, binary_string)`.

Both interfaces return [WriteBytesResponse](../api/FIELDS.md#writebytesresponse),
with unsigned 32-bit integer `bytes_written`.

Supply a binary string no longer than INT_MAX bytes; embedded NUL bytes are
preserved. Writes create a copy-on-write overlay rather than editing the original
binary on disk. See [persistence limits](#ownership-persistence-and-effective-limits)
before relying on a saved patch.

### list_memory_blocks

**both** · read — `list_memory_blocks(count_page)`.

Both interfaces return [ListMemoryBlocksResponse](../api/FIELDS.md#listmemoryblocksresponse),
with a `blocks` array of [MemoryBlockRecord](../api/FIELDS.md#memoryblockrecord) values.

Omit the page or pass nil for the shared [page defaults](#values-and-validation).

### patch_bytes_batch

**lowlevel** · change — `patch_bytes_batch(patches)`.

Returns [PatchBytesBatchResponse](../api/FIELDS.md#patchbytesbatchresponse),
with unsigned 32-bit integers `patch_count` and `bytes_written`.

Pass a dense array of [BytePatch](../api/FIELDS.md#bytepatch) tables. Each must
contain `address` and binary `data`. The number of patches and total bytes must
each be at most UINT32_MAX; each data string must be at most INT_MAX bytes.
Even an empty array calls the engine.

Patches apply in order, **not atomically**. A later failure does not roll back
earlier changes. The counters total requested bytes without confirming native
writes. See [persistence limits](#ownership-persistence-and-effective-limits).


## Types aliases enums and members

### add_type_enum_member

**lowlevel** · change — `add_type_enum_member(type_id_or_path:s, name:s, value:i)`.

Adds a named value to the selected enum. Returns
[AddTypeEnumMemberResponse](../api/FIELDS.md#addtypeenummemberresponse) with boolean `updated`.


### add_type_member

**lowlevel** · change — `add_type_member(parent_type_id_or_path:s, member_name:s, member_type:s, size:u)`.

Appends a member to the selected parent type. Returns
[AddTypeMemberResponse](../api/FIELDS.md#addtypememberresponse) with boolean `updated`.

`size` is required but ignored. The engine appends a member using the referenced
type's size. Query members for their actual sizes: the enclosing struct's generic
length can be zero even when it has members.

### create_type

**lowlevel** · change — `create_type(name:s, kind:s, size:u)`.

Returns [CreateTypeResponse](../api/FIELDS.md#createtyperesponse) with boolean `updated`.

All three arguments are required, although `size` is ignored. Only
`kind="struct"` is supported; other kinds return `NOT_SUPPORTED`.

### create_type_alias

**lowlevel** · change — `create_type_alias(name:s, target_type:s)`.

Creates an alias named `name` for `target_type`. Returns
[CreateTypeAliasResponse](../api/FIELDS.md#createtypealiasresponse) with boolean `updated`.


### create_type_enum

**lowlevel** · change — `create_type_enum(name:s, width:u, is_signed:bool)`.

Creates an enum named `name`. Returns
[CreateTypeEnumResponse](../api/FIELDS.md#createtypeenumresponse) with boolean `updated`.

`width` and `is_signed` are required, but neither is passed to the engine's
`defineEnum` call. Tested results have width eight regardless of the requested
width. Do not rely on the requested signedness controlling the result.

### delete_type

**lowlevel** · change — `delete_type(type_id_or_path:s)`.

Deletes the selected type. Returns
[DeleteTypeResponse](../api/FIELDS.md#deletetyperesponse) with boolean `deleted`.


### delete_type_alias

**lowlevel** · change — `delete_type_alias(type_id_or_path:s)`.

Deletes the selected alias. Returns
[DeleteTypeAliasResponse](../api/FIELDS.md#deletetypealiasresponse) with boolean `deleted`.


### delete_type_enum_member

**lowlevel** · change — `delete_type_enum_member(type_id_or_path:s, ordinal:u)`.

Deletes the enum member at the zero-based `ordinal`. Returns
[DeleteTypeEnumMemberResponse](../api/FIELDS.md#deletetypeenummemberresponse) with boolean `deleted`.


### delete_type_member

**lowlevel** · change — `delete_type_member(parent_type_id_or_path:s, ordinal:u)`.

Deletes the parent type's member at the zero-based `ordinal`. Returns
[DeleteTypeMemberResponse](../api/FIELDS.md#deletetypememberresponse) with boolean `deleted`.


### get_type

**both** · read — `get_type(path:string)`.

Lowlevel returns [GetTypeResponse](../api/FIELDS.md#gettyperesponse), with an optional
[TypeRecord](../api/FIELDS.md#typerecord) in `type`. Session returns
`response.type,nil,response`, or `nil,error,response` with code `NOT_FOUND`
when absent.

The engine looks up the supplied string by name (`findByName`). Use a returned
type's `name`; a leading-slash `path_name` is not normalized for this lookup.

### list_type_aliases

**both** · read — `list_type_aliases(query:string, count_page)`.

Result fields: aliases array.

Both interfaces return [ListTypeAliasesResponse](../api/FIELDS.md#listtypealiasesresponse),
with an `aliases` array of [TypeAliasRecord](../api/FIELDS.md#typealiasrecord) values.

Omit the page or pass nil for the shared [page defaults](#values-and-validation).

### list_type_enum_members

**both** · read — `list_type_enum_members(type_id_or_path:string, count_page)`.

Both interfaces return [ListTypeEnumMembersResponse](../api/FIELDS.md#listtypeenummembersresponse),
with a `members` array of [TypeEnumMemberRecord](../api/FIELDS.md#typeenummemberrecord)
values for the selected enum.

Omit the page or pass nil for the shared [page defaults](#values-and-validation).

### list_type_enums

**both** · read — `list_type_enums(query:string, count_page)`.

Result fields: enums array.

Both interfaces return [ListTypeEnumsResponse](../api/FIELDS.md#listtypeenumsresponse),
with an `enums` array of [TypeEnumRecord](../api/FIELDS.md#typeenumrecord) values.

Omit the page or pass nil for the shared [page defaults](#values-and-validation).

### list_type_members

**both** · read — `list_type_members(type_id_or_path:string, count_page)`.

Both interfaces return [ListTypeMembersResponse](../api/FIELDS.md#listtypemembersresponse),
with a `members` array of [TypeMemberRecord](../api/FIELDS.md#typememberrecord)
values for the selected type.

Omit the page or pass nil for the shared [page defaults](#values-and-validation).

### list_type_unions

**both** · read — `list_type_unions(query:string, count_page)`.

Result fields: unions array.

Both interfaces return [ListTypeUnionsResponse](../api/FIELDS.md#listtypeunionsresponse),
with a `unions` array of [TypeUnionRecord](../api/FIELDS.md#typeunionrecord) values.

Omit the page or pass nil for the shared [page defaults](#values-and-validation).

### list_types

**both** · read — `list_types(query:string, count_page)`.

Result fields: types array.

Both interfaces return [ListTypesResponse](../api/FIELDS.md#listtypesresponse),
with a `types` array of [TypeRecord](../api/FIELDS.md#typerecord) values.

Omit the page or pass nil for the shared [page defaults](#values-and-validation).

### rename_type

**lowlevel** · change — `rename_type(type_id_or_path:s, new_name:s)`.

Renames the selected type. Returns [RenameTypeResponse](../api/FIELDS.md#renametyperesponse),
with boolean `updated` and string `name`.


### rename_type_enum_member

**lowlevel** · change — `rename_type_enum_member(type_id_or_path:s, ordinal:u, new_name:s)`.

Renames the enum member at the zero-based `ordinal`. Returns
[RenameTypeEnumMemberResponse](../api/FIELDS.md#renametypeenummemberresponse) with boolean `updated`.


### rename_type_member

**lowlevel** · change — `rename_type_member(parent_type_id_or_path:s, ordinal:u, new_name:s)`.

Renames the parent type's member at the zero-based `ordinal`. Returns
[RenameTypeMemberResponse](../api/FIELDS.md#renametypememberresponse) with boolean `updated`.


### set_type_alias_target

**lowlevel** · change — `set_type_alias_target(type_id_or_path:s, target_type:s)`.

Changes the type referred to by the selected alias. Returns
[SetTypeAliasTargetResponse](../api/FIELDS.md#settypealiastargetresponse) with boolean `updated`.


### set_type_enum_member_comment

**lowlevel** · change — `set_type_enum_member_comment(type_id_or_path:s, ordinal:u, comment:s)`.

Sets the comment on the enum member at the zero-based `ordinal`. Returns
[SetTypeEnumMemberCommentResponse](../api/FIELDS.md#settypeenummembercommentresponse) with boolean `updated`.


### set_type_enum_member_value

**lowlevel** · change — `set_type_enum_member_value(type_id_or_path:s, ordinal:u, value:i)`.

Sets the signed 64-bit value of the enum member at the zero-based `ordinal`.
Returns [SetTypeEnumMemberValueResponse](../api/FIELDS.md#settypeenummembervalueresponse)
with boolean `updated`.


### set_type_member_comment

**lowlevel** · change — `set_type_member_comment(parent_type_id_or_path:s, ordinal:u, comment:s)`.

Sets the comment on the parent type's member at the zero-based `ordinal`. Returns
[SetTypeMemberCommentResponse](../api/FIELDS.md#settypemembercommentresponse) with boolean `updated`.


### set_type_member_type

**lowlevel** · change — `set_type_member_type(parent_type_id_or_path:s, ordinal:u, member_type:s)`.

Changes the type of the parent type's member at the zero-based `ordinal`. Returns
[SetTypeMemberTypeResponse](../api/FIELDS.md#settypemembertyperesponse) with boolean `updated`.



## Performance records

### add_perf_benchmark

**lowlevel** · change — `add_perf_benchmark(record)`.

Returns [AddPerfBenchmarkResponse](../api/FIELDS.md#addperfbenchmarkresponse) with
boolean `added`.

Pass a [PerfBenchmarkRecord](../api/FIELDS.md#perfbenchmarkrecord) table. Omitted
known fields use the defaults in that reference. `bench_id` cannot be empty.
Benchmark records are not guaranteed to survive saving and reloading.

### clear_perf_benchmarks

**lowlevel** · change — `clear_perf_benchmarks()`.

Clears benchmark records. Returns [ClearPerfBenchmarksResponse](../api/FIELDS.md#clearperfbenchmarksresponse),
with boolean `cleared` and unsigned 32-bit integer `removed_count`.


### delete_perf_benchmark

**lowlevel** · change — `delete_perf_benchmark(bench_id:s)`.

Deletes the record identified by `bench_id`. Returns
[DeletePerfBenchmarkResponse](../api/FIELDS.md#deleteperfbenchmarkresponse) with boolean `deleted`.


### list_perf_benchmarks

**lowlevel** · read — `list_perf_benchmarks()`.

Returns [ListPerfBenchmarksResponse](../api/FIELDS.md#listperfbenchmarksresponse),
with a `records` array of [PerfBenchmarkRecord](../api/FIELDS.md#perfbenchmarkrecord)
values.



## Shared operation caveats

All method entries use the shared [value and page rules](#values-and-validation).
Collections larger than INT_MAX are unsupported. Numeric size bounds do not
promise that an allocation will succeed; do not attempt multi-gigabyte allocations
just to test a limit.

For comments, [CommentKind](../api/FIELDS.md#commentkind) accepts `unspecified`,
`eol`, `pre`, `post`, `plate` and `repeatable` (native values zero through five).
DataItemRecord end addresses are inclusive.

The [benchmark record](../api/FIELDS.md#perfbenchmarkrecord) defines all input
defaults and conversion types. All ten fields are returned, including zero and
negative values; these values are not replaced by defaults.

## Ownership, persistence and effective limits

### Client and program lifetime

Only one binding-owned client may be live per process, across all Lua states and
module copies. A second construction returns `CLIENT_IN_USE`. Do not mix
independent engines. `session:native()` is an alias for the existing owner.

Closing a **program** and closing its **owner** have different effects:

- `close_program` and `shutdown` close program access but retain the engines and
  the process's client slot. Reads return `NO_PROGRAM`; status calls still work.
  You can reopen a program on that same owner. The new open response describes
  the new request; previously returned metadata does not change.
- `close()` or Lua 5.4 `__close` permanently releases the owner and client slot,
  and invalidates iterators. All aliases then return `CLOSED`; the owner cannot
  reopen. Garbage collection destroys the handle once and never saves it.
  `__close` preserves an error already being raised from the scope.

Detached result tables remain valid after either kind of closure. They are
snapshots: changing them does not edit the native program.

For Session `close_program` and `shutdown`, `policy='save'` requires a `state_path`
set at construction. Otherwise Session returns `NO_STATE_PATH` before calling the
engine. Lowlevel preserves the native behavior: an empty-path save-close can
close without saving. Closing does not imply automatic save, rollback or engine
unloading.

Any mutation or lifecycle call that reaches the engine changes the shared
generation used to validate iterators, **even if the call fails or has only a
partial effect**. Argument validation failures do not. Iterators cannot provide
a universal snapshot or detect every change made outside the binding.

### What survives saving and reloading

Saving is not general project persistence. Function-symbol renames survive
save and reopen on the supported profile, but this does not extend to every edit.
The tested binary and project reload behavior is:

| Edit or record | After reload |
| --- | --- |
| Struct name and kind | Survive as an empty struct shell. |
| Struct members, aliases and enums | Disappear. |
| Comments, named data and benchmark records | Disappear. |
| Function signatures and parameter edits | Reset. |
| Renames of true local variables in projects | Reset, despite being visible before save. |
| Byte overlays | Original bytes return. |

Member and enum comments cannot survive independently of their missing
containers. Successful integer signature edits affect parameters; they do not
demonstrate persistence for true local variables. Save flags acknowledge requests,
not complete restoration of all categories.

`discard_program` is not rollback: byte overlays survive this no-op discard,
but not save and reopen. Patch batches are not transactions and provide no
partial-failure recovery. They apply in order, and their counters total requested
bytes without confirming writes. Decompilation batches likewise require checking
each entry's complete, fallback or incomplete outcome.

### Input and engine limits

- **Discovery is lazy.** Decompile a known mapped function before expecting
  lookups or pages to contain it. `NOT_FOUND` does not mean “no code”. Many fields,
  including tokens, remain empty or default-valued. Revision fields such as
  `file_version` can be zero and do not establish durable file-version tracking.
- **Address validity is your responsibility.** Extreme or unmapped addresses can
  cause a native process crash. UInt64 validation preserves the number exactly;
  it does not verify the mapping. Do not scan arbitrary addresses in-process.
  Lua cleanup cannot recover from such a crash.
- **Project loading is limited.** Ordinary raw/FileBytes project loading is
  incomplete. The working analyzed-project route uses a project without FileBytes
  that refers to an external ELF; it does not establish general project support.
  Leaf-function queries work with that analyzed project's reference index, while
  raw ELF returns `NOT_SUPPORTED`.
- **Type creation has restrictions.** Only structs can be created through
  `create_type`; public union creation is unsupported. Empty union pages do not
  demonstrate populated union results. `create_type` and `add_type_member` ignore
  size arguments. The latter appends using the referenced type. Query members for
  actual sizes: a struct's generic length can be zero even with a four-byte member.
- **Enum settings are not forwarded.** `create_type_enum` does not pass `width`
  or `is_signed` to native `defineEnum`. Tested widths are eight, even for requests
  of 123 or 1. A false signedness request and response alone do not establish the
  full signedness behavior. `get_type` can report an enum as kind `int`, length eight.
- **True-local retyping is not established.** Local renames work using the stable
  ID and kind from decompilation, but changing those locals to `char` returns
  `DECOMPILE_FAILED` and leaves their types unchanged. Parameter retyping does not
  prove that local retyping works.
- **Deletion may expose inferred data.** `delete_symbol` ignores `name_filter`
  and selects by address. Deleting named data can reveal inferred data at the
  same address and size rather than permanently removing the location from queries.
- **String discovery is a stub.** `list_defined_strings` always returns empty
  success for a loaded program, ignoring range and count, even if strings are
  present. It is not a scanner.
- **Protection and deadlines are ineffective.** The engine ignores `read_only`,
  `project_name` and timeouts; they neither protect against writes nor set a
  deadline. The binding preserves NUL bytes in text, but native text consumers
  may not return them unchanged.
- **Dependency allocation failures can be unrecoverable.** The wrapper's
  allocation and lifetime handling does not guarantee cleanup, retention of
  state, global-state recovery or recovery from every out-of-memory failure inside
  libghidra or its dependencies.

For a bounded reading sequence, use the [examples](EXAMPLES.md). A method's
availability does not guarantee support for every input. Distribution requirements
are separate and described in [NOTICES](NOTICES.md).
