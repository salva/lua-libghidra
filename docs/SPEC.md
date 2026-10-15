# Lua bindings for libghidra — specification

Status: proposed baseline for operator review, 2026-10-15. This specifies the
product; it does not authorize an autonomous run. Architecture is in
[DESIGN.md](DESIGN.md); delivery gates are in [PLAN.md](PLAN.md).

## 1. Goal and reference

Provide a maintainable, idiomatic Lua SDK for **0xeb/libghidra**, reusing its
native C++ SDK. Lua scripts must be able to inspect and annotate programs,
decompile functions, and manage supported program/project lifecycle operations.
Both the offline LocalClient and live HTTP LibGhidraHost backend are product goals.

Research baseline: <https://github.com/0xeb/libghidra>, commit
`d51ca813ae1b6b59519551a9be8c0b1ad74d862d`, reporting version `0.0.9`.
This is a commit pin, not a claim that it equals the v0.0.9 release tag.
Python's synchronous client, records and examples inspire coverage and naming;
the C++ public interface defines callable native functionality. Python, Java and
Ghidra installations must not be runtime dependencies for offline operation.

## 2. Supported scope

- Initial release platform: Linux x86-64, standard PUC Lua 5.4 with 64-bit
  integers. Lua 5.3 is a subsequent compatibility target. LuaJIT, Lua 5.1/5.2,
  Windows and macOS are deferred until separately built and tested.
- Synchronous calls, usable from standalone Lua and an existing embedded Lua
  state. No hidden interpreter, event loop, global client or Python bridge.
- HTTP and local build profiles; a local-enabled build also includes HTTP.
  An HTTP-only build reports local construction as `BACKEND_UNAVAILABLE`.
- Source installation using CMake and LuaRocks. Prebuilt binaries are optional
  later work, not an initial release condition.
- Explicit language/compiler hints are supported. Native format detection is
  used where it works; uncertain/raw formats require explicit options rather
  than invented architecture guesses.

### Coverage tiers

| Tier | Required scope |
| --- | --- |
| First usable slice | Construct/close client; status/capabilities; open/close program; function listing/lookup; memory reads; instruction listing; one-function decompilation |
| Core release | Above plus revisions, save/discard; symbols, xrefs, memory blocks, types/members/signatures, strings, comments, basic blocks and CFG; rename function/symbol and write bytes |
| Broad synchronous coverage | Remaining public synchronous operations: project/import, analysis jobs, type/signature edits, data edits, structural analysis, tags, bookmarks, breakpoint metadata, program options and other shared SDK methods |

The first usable slice is not completion. Core release and broad coverage are
separate milestones. Every public Python synchronous operation and C++ IClient
operation must appear in a coverage manifest with its Lua mapping, backend
support, test evidence, or explicit deferral. Python-only CLI helpers, async
clients and headless-process launching are deferred. Do not implement missing
upstream analysis functionality inside the binding.

## 3. Lua contract

### Surface and data

- `local ghidra = require("libghidra")`; no writes to `_G`.
- Factories: `ghidra.connect{base_url=...}` and `ghidra.local_client{...}`.
  `local_client` avoids Lua's reserved keyword `local`.
- Client methods use `client:snake_case(...)`. Requests use plain option tables;
  simple identities can be positional, e.g. `get_function(address)` and
  `rename_function(address, name)`. Do not expose C++ overload sets.
- Responses are detached ordinary tables with Python-style snake_case field
  names and response envelopes, e.g. `response.functions` and
  `response.decompilation`. Collections are dense 1-based arrays, including
  empty `{}` arrays. Absent optional fields are `nil`; false and zero survive.
- Preserve response metadata, decompiler tokens, completion/fallback/status
  fields and backend errors. Nonempty pseudocode does not imply exact successful
  decompilation. Table edits do not mutate the program; mutations are explicit calls.
- Bytes are length-preserving Lua strings, including embedded NULs, never byte
  arrays by default. Preserve text as supplied rather than silently transcoding it.
- Enums use documented lowercase symbolic strings; unknown response enum values
  retain a numeric representation instead of being mislabelled.
- Unknown request keys, wrong types, sparse input arrays and out-of-range values
  fail before dispatch. Omitted options use documented defaults; `false` does
  not mean omitted. Address ranges retain upstream **inclusive** end semantics.

### Exact integers

All uint64 outputs, including addresses, IDs and revision counters, use immutable
`UInt64` userdata consistently. `ghidra.u64("0xffffffffffffffff")` constructs it;
decimal strings are also accepted. Inputs accept UInt64, nonnegative Lua integers
or strictly validated decimal/hex strings. Floating-point inputs are rejected.

Provide value comparison, `:hex()` (fixed-width lowercase `0x` plus 16 digits),
`:decimal()`, checked `:to_integer()`, and checked `:add(integer)` /
`:sub(integer)` with nonnegative integer operands. No wraparound or float fallback.
`tostring(value)` equals `value:hex()`. Use string forms as table keys: userdata
value equality does not make distinct userdata identical Lua table keys.
Signed int64 fields remain Lua integers; bounded counts/offsets use checked Lua
integers. Never route uint64 through `lua_Number`.

### Errors

Calls return `result` on success or `nil, error` on expected failure; successful
void operations return `true`. Error objects are tables with `code`, `message`,
`operation`, `backend`, and optional `upstream_code`; `tostring(error)` is useful.
Normalize known upstream statuses while preserving their original code. Keep
unknown codes and messages. Distinguish invalid arguments, closed handles,
unsupported operations, unavailable builds, timeout/transport errors and internal
exceptions. `ghidra.check(result, err)` raises the error object for callers who
prefer `pcall`/`xpcall` or terse scripts. Allocation failures and Lua runtime
errors remain Lua errors; ordinary SDK failures must not escape as C++ exceptions.

### Ownership and iteration

- `client:close()` is idempotent and releases the native client. Further calls
  return `CLOSED`. `__gc` and Lua 5.4 `__close` release resources without raising.
- Releasing a client is distinct from `close_program`, saving, discarding and
  shutting down a remote host. Save/discard/shutdown policies are explicit.
  Local persistence configured upstream may affect destructor behavior; document
  verified behavior rather than claiming cleanup is a transaction rollback.
- Results survive client closure and garbage collection.
- `list_*{limit=..., offset=...}` exposes one page; offsets stay zero-based as
  upstream specifies. Default page size is 100; zero/unbounded requests require
  explicit selection and documentation.
- Convenience `iter_functions{page_size=...}` and equivalent core-list iterators
  fetch lazily, retain the client, stop on exhaustion and raise structured errors
  on failure (generic `for` cannot return `nil, err` without hiding the error).
  No implicit prefetch; early loop exit requires no remote cursor cleanup.
  Iteration is not a snapshot of a mutating remote program.
- Calls block their invoking thread. A client/Lua state is not concurrently
  shareable across OS threads. Coroutines do not make blocking calls asynchronous.

## 4. Example target API

This is an acceptance example, not runnable implementation yet. The fixture
address must come from its build manifest, not a hard-coded compiler assumption.

```lua
local ghidra = require("libghidra")
local client <close> = ghidra.check(ghidra.local_client{})
ghidra.check(client:open_program{program_path = "fixture.elf"})
local page = ghidra.check(client:list_functions{limit = 10})
for _, fn in ipairs(page.functions) do
  print(fn.entry_address:hex(), fn.name)
end
local result = ghidra.check(client:get_decompilation(
  ghidra.u64("0x401000"), {timeout_ms = 30000}))
local dec = result.decompilation
if dec then
  print(dec.pseudocode) -- inspect completion/fallback metadata before accepting
end
ghidra.check(client:close_program{policy = "discard"})
```

## 5. Acceptance

1. Clean installation loads via `require` from outside the source/build tree;
   both build profiles and an embedded-host smoke test pass.
2. A locally compiled, redistributable fixture supports real local reads and
   decompilation at known addresses without Java/network at runtime.
3. A pinned real LibGhidraHost passes project/program lifecycle, reads, edits,
   save/reopen verification and pagination. A mock server alone is insufficient.
4. Boundary tests cover uint64 0, 2^53±1, 2^63±1, 2^64−1, overflow, bad strings,
   binary NULs, optional false/zero, nested arrays, unknown enums and bad requests.
5. Close/GC/error paths pass ASan/UBSan where available, repeated-state lifecycle
   tests, and use-after-close tests. No borrowed response storage is exposed.
6. Pagination tests cover empty/exact/partial pages, backend page caps, midstream
   error, no-progress responses and early exit. Failure cannot look like success.
7. Representative Python and Lua executions against the same pinned backend and
   fixtures agree on normalized semantic results. Differences are explained;
   unstable addresses/order/text formatting are not blindly compared.
8. API reference, examples, limitations, dependency pins/notices and coverage
   manifest ship with the source package. Missing live infrastructure is reported
   as unverified, not a passing release gate.

## 6. Provenance

Upstream currently uses **Human-Origin Source License v1.0**, not a standard
permissive license. It explicitly discusses unchanged dependency use and
restrictions on derivative implementations. This project wraps the dependency;
it does not translate its implementation. Preserve upstream attribution and
license notices, record packaging obligations, and resolve the intended binding
distribution's applicability before publication. The binding's own license is
an operator decision, not inferred from Python examples.
