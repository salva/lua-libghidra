# Core Lua API reference

Original wrapper Copyright 2026 Salvador Fandiño, MIT. Native engine integration
uses [libghidra by Elias Bachaalany](https://github.com/0xeb/libghidra); no endorsement
is implied. This is a **core** local binding, not full-tier qualification or release
approval. Linux x86-64, ordinary C-built PUC Lua 5.4 with 64-bit integers only.
No HTTP, SWIG, upstream Python bindings, second VM or runtime Java/Python/network.

## Entry points and exact values

`require('libghidra.lowlevel').local_client(client_options)` returns owner or
`nil,error`. `require('libghidra').open{client=...,program=...}` returns
`session,nil,open_response` or `nil,error`, releasing a newly created owner on
open failure. See [SPEC §§2–3](SPEC.md) for the complete first-slice grammar,
defaults, validation, errors and UInt64 behavior. `check(value,err,response)`
returns value,response or raises when value is nil; it does not inspect outcome
flags. Both modules export the same `check` and `u64` helpers.

All native uint64 fields are immutable UInt64, including small values; use
`hex()`, `decimal()`, checked `to_integer()`, `add(n)`, `sub(n)`. Strings/integers
construct exact values without floating-point conversion. Signed/narrow integers
are checked Lua integers. Bytes are binary strings. Optional absence is nil;
false, zero and empty strings are preserved. Arrays are dense 1-based tables;
ordinals and offsets inside records remain native zero-based values.

## Calls and response contract

The [first-slice table](SPEC.md#first-slice-call-grammar) defines status,
capabilities, open/close, function, instruction, bytes, decompilation and function
pages. The [core grammar table](M3-CORE.md#grammar-and-field-manifest) defines
every additional core method, positional arguments, page kinds and envelopes.
These tables, not the sixty inventory proposals, define accepted call syntax.
The [field manifest](../api/FIELDS.md) lists exact native types, Lua representations,
optionality and native defaults; [coverage.json](../api/coverage.json) additionally
records request/response expansion and source provenance. A native default is
not permission to omit a required positional Lua argument.

Lowlevel returns complete detached response tables or nil,error. Session unwraps
`get_function`, `get_instruction`, `get_symbol`, `get_type`,
`get_function_signature`, `get_decompilation` and `read_bytes` as
`value,nil,response`; optional absence is `nil,NOT_FOUND,response`.
Mutations and pages keep complete responses, including false flags. Errors have
code/message/operation/backend and optional upstream_code. Lua allocation/runtime
errors remain Lua errors. No SDK exception is allowed to escape C++.

Core calls are available on both views except `discard_program` and
`list_defined_strings`, which use `session:native()`. The latter is an always-empty
compatibility envelope, not string discovery. Full-tier specialist mutations
used by fixture tests do not imply a full-tier public acceptance claim.

Only `iter_functions`, `iter_symbols` and `iter_memory_blocks` are enabled.
They are lazy, bounded and check shared generation before every yield. All other
core families are pages-only, including types, blocks, CFG, xrefs and signatures.
Page sizes are positive, offset nonnegative and offset+limit <= INT_MAX. Iterator
options use page_size instead of limit. Empty signature pages do not prove
exhaustion: native offsets count candidates before signature filtering. Zero
range_end means UINT64_MAX only for the explicitly documented range families.
Instructions decode contiguously from the supplied start, stopping at gaps.

## Ownership and persistence

One live binding-owned client per process, even across states/module copies;
second construction returns CLIENT_IN_USE. `native()` shares the same owner.
`close()` is idempotent and permanently closes all aliases, releases the process
slot and invalidates iterators. `__close` preserves an active scope error; GC does
not save. Logical `close_program`/`shutdown` do not unload the engine or release
the slot: reads return NO_PROGRAM, status remains usable, and native reopen makes
the same Session see the new context. Old detached tables remain historical.
Dispatched mutations/lifecycle calls invalidate iterators even on failure;
validation-only failures do not. No universal snapshot or cancellation promise.

Save flags are acknowledgements, not complete persistence. Byte overlays do not
persist; discard is not rollback. Native saved=true can lose categories on reload.
See [category evidence](M3-CORE.md), [M2 limitations](M2-SLICE.md) and
[SPEC persistence matrix](SPEC.md#4-lifecycle-persistence-and-limitations).
Union/signature production, raw FileBytes loading and extreme-address crash
limitations remain. Do not probe unsupported extreme addresses in-process.
Ignored read_only/project_name/timeouts do not provide protection/deadlines;
architecture metadata echoes input, not authoritative detection.

## Evidence and runnable examples

[EXAMPLES](EXAMPLES.md) gives installed commands for first_slice.lua and the core
mutation extension; fixture_manifest is authored test data, not SDK API. Supply
LIBGHIDRA_FIXTURE_ROOT to the retained project fixture tree. Examples require
those fixtures, not just the installed module.

Generated inventory runtime slots deliberately remain unqualified. Historical
M3 annotations are provenance-pinned by [runtime index](../api/runtime-evidence-m3.json)
and [api/README](../api/README.md); they are not generation inputs or new acceptance.
Current installed evidence and remaining gates are summarized in
[qualification](INSTALLED-CORE.md). Source/converter coverage alone does not prove
real native behavior. Independent review and operator decisions remain required.

## Full-tier native adapter extension

The writer implementation now exposes all full-tier methods through lowlevel and
Session native(). See [M4 exact grammar, dispatch/field mapping and bounded
qualification](M4-FULL.md). This extends the core surface; it does not upgrade
historical core evidence or grant M5/release approval. No new facade convenience
or iterator is enabled.
