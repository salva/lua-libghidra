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

`api/coverage.json` remains the exact native field/type/default ledger. Every
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
