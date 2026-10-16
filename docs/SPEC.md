# Lua bindings for libghidra — specification

Requirements baseline, 2026-10-15. Implementation and bounded runtime evidence
are tracked separately in [current qualification](INSTALLED-CORE.md); no M5
release approval is implied. See [design](DESIGN.md), [plan](PLAN.md),
[coverage](COVERAGE.md) and [review dispositions](reviews/00-INDEX.md).

## 1. Scope

Wrap native LocalClient of [0xeb/libghidra](https://github.com/0xeb/libghidra)
at `d51ca813ae1b6b59519551a9be8c0b1ad74d862d` (reports 0.0.9; not a release-tag
equivalence claim). Initial target: Linux x86-64, PUC Lua 5.4 with 64-bit integers,
C++20, CMake and LuaRocks source installation. Lua 5.3 requires later independent
qualification. HTTP, remote lifecycle, async APIs and SWIG are excluded.
Installed operation requires no Python, Java, Ghidra application or network.
Development fixture generation may use Java/Ghidra.
The pinned upstream source build currently uses Python >=3.10 with zlib for spec
embedding; consuming the installed native SDK need not run that generator.
Project-owned deliverable tooling and qualification are Lua-based.
The finished Lua/C++ binding must not depend on upstream Python bindings for
execution, building or required tests. Project-owned scripts, generators and
acceptance tests should be Lua-based by release. Any retained Python use needs a
documented compelling reason, alternatives and operator acceptance. The operator
approved one narrow exception: the unchanged pinned upstream `cpp/embed_specs.py`
generator, invoked by `cpp/cmake/EmbedSpecs.cmake`, may use Python >=3.10 and its
standard-library modules (including zlib/XML) during native source builds only.
This does not permit Python bindings, project-owned Python tooling/test oracles,
or any Python requirement in SDK-consumer builds or installed Lua runtime.
The native C++ adapter, CMake/LuaRocks and native compiler/sanitizer tooling remain
part of the design. See DESIGN's two spec-loading profiles.

Calls are synchronous. Initial `pool_size` is exactly 1; reject other values.
Only one live binding-owned native client per process is supported, including
across independent Lua states. A second construction returns `CLIENT_IN_USE`.
All engine construction, calls and destruction are process-serialized; each Lua
state remains confined to its invoking thread. Sequential clients must work.
Do not combine this release with independently managed Ghidra engines in the
same process. These are binding restrictions, not proven native safety claims.

## 2. Two public surfaces

- `require("libghidra.lowlevel").local_client(options)` returns an owning client.
  Snake-case methods map native operations to complete detached response tables,
  preserving optional fields, metadata, outcomes and errors. `_native` is private.
- `require("libghidra").open(options)` constructs a client, opens its program and
  returns `session, nil, open_response`; on factory/open failure it returns
  `nil, error` and releases any newly created client. The detached response is
  from that exact open, not refreshed state after later native close/reopen.
  Preserve every field, including `has_entry_point=false`, zero addresses and
  empty strings; no second open is needed to retrieve it. Architecture metadata
  remains echoed, not authoritative detection. Factory/open keys are separated
  as specified below, never silently forwarded.
  Session offers direct records, byte strings and lazy iterators for common reads.
  `session:native()` returns the low-level view of the **same** owning handle.
  It does not allocate another engine. A Session is mutable program context,
  not an immutable Program object. Records are plain tables, not Function objects.

First slice ships both surfaces, using one dispatch/conversion path.
The coverage inventory identifies the complete local target and facade subset.
Native batches remain native batches, not Lua loops; no atomicity is invented.

Low-level calls return `response` or `nil, error`. Only binding-owned void
operations such as `close()` return `true`; native outcome tables remain intact.
Unwrapped facade reads return `value, nil, response` on success;
`nil, error, response` when an optional result is absent (`NOT_FOUND`). Native
failure returns `nil, error` without an invented response. `get_function(address)`
unwraps `response["function"]` (Lua reserves `function`); `get_decompilation`
unwraps `decompilation`; `read_bytes` unwraps `data`. Mutations and page methods
retain full responses and flags, including false flags. A present decompilation
with `completed=false` is still returned for inspection. `check(value, err, response)`
raises only when value is nil, otherwise returns value and response; it checks
presence, not decompilation quality or mutation success.

Error tables have `code`, `message`, `operation`, `backend` (`"local"` for SDK
failures, `"binding"` for validation/lifecycle/conversion errors), and optional
`upstream_code`. Preserve unknown native codes/messages; distinguish `CLOSED`,
`INVALID_ARGUMENT`, `NOT_FOUND`, `NOT_SUPPORTED`, resource failures and internal
exceptions. No SDK exception escapes C++. Allocation/runtime errors remain Lua
errors. Iterators raise structured errors: generic `for` cannot convey a second
error result reliably.

### Current call grammar

[API](API.md) is the single current signature/default/envelope authority for both
surfaces, including guarded Session reopen/shutdown and native escape-hatch calls.
The requirements below constrain safety and semantics, not a second signature list.

## 3. Values and validation

Collections are dense 1-based Lua arrays, including empty tables. Native ordinals
and offsets stay zero-based **inside records and requests**; never add one to a
member or parameter ordinal. Optional absence is nil; preserve false and zero.
Bytes are length-preserving Lua strings (including NUL); text is not transcoded.
Enums use documented lowercase names; unknown response values retain their
numeric native value. Ranges retain native inclusive end semantics.
The zero-end sentinel documented in API is an explicit exception; it also applies to native
symbol, comment and data-item range queries. The manifest records applicability
per operation rather than inferring it for every method with range fields.

Every native `uint64_t` field uses exact UInt64 outputs: addresses, IDs,
revision counters, sizes, lengths, offsets and ordinals, even when small.
Signed int64 and narrower integral fields use checked Lua integers. Thus a native
uint64 member ordinal is UInt64 while an `int` parameter ordinal is a Lua integer;
array positions are unrelated. The field manifest must record native type and
Lua representation for every request/response field, including nested records,
before its adapter ships.
Public field width does not override narrower downstream restrictions:
ReadBytes passes length to signed 32-bit `int4` after allocating a native buffer.
Both surfaces must reject size above INT32_MAX as binding `INVALID_ARGUMENT`
before dispatch or requested-buffer allocation. Zero is allowed. The upper
allowed value is a validation boundary, not a promise of memory availability or
a required multi-gigabyte successful read.

Concrete pinned model examples (the native field name is preserved):

| Fields | Lua representation |
| --- | --- |
| FunctionRecord entry_address/start_address/end_address/size | UInt64 |
| FunctionRecord parameter_count; WriteBytesResponse bytes_written | Lua integer (uint32) |
| MemoryBlockRecord start_address/end_address/size | UInt64 |
| TypeEnumRecord type_id/width; TypeEnumMemberRecord type_id/ordinal | UInt64 |
| TypeEnumMemberRecord value | Lua integer (int64) |
| TypeMemberRecord parent_type_id/ordinal/size | UInt64 |
| TypeMemberRecord offset | Lua integer (int64, not UInt64) |
| ParameterRecord ordinal | Lua integer (int, zero-based) |
| ReadBytesResponse data | Binary Lua string |

`u64(integer_or_string)` accepts nonnegative Lua integers and strict decimal or
`0x` hexadecimal strings; uint64 inputs also accept UInt64. Reject floats,
signs, whitespace, trailing bytes and overflow. No float intermediary.
Immutable UInt64 provides `hex()` (0x plus 16 lowercase digits), `decimal()`,
checked `to_integer()`, and checked `add(nonnegative_integer)` /
`sub(nonnegative_integer)`. Constructors and named helpers return value or
`nil, error` with backend `binding`, including overflow and wrong types.
`tostring` equals `hex`; comparison metamethods accept UInt64 operands only and
raise structured binding errors for invalid ordered operands. Equality follows
Lua dispatch (unrelated types compare false); two UInt64 values compare by value.
No arithmetic metamethods are provided. Use hex/decimal strings for table keys:
value-equal userdata are not identical Lua table keys.

Reject unknown request keys, wrong types, sparse arrays and out-of-range values
before dispatch. Omission uses documented defaults, never Lua truthiness.
Pagination defaults: limit/page_size 100, offset 0; sizes strictly positive,
offsets nonnegative, each within native `INT_MAX`, and **offset + limit <=
INT_MAX**, checked without performing overflowing arithmetic. Zero/unbounded
pages are disallowed on both surfaces, including instruction scans: native
zero-limit scanning has a finite scan cap and is not reliable exhaustion.

## 4. Lifecycle, persistence and limitations

`close()` is idempotent, resets the native owner and makes all aliases return
`CLOSED`. Lua 5.4 `__close` does the same without raising or replacing an active
scope error; `__gc` finally destroys the userdata exactly once. An alias can
survive scope exit but stays closed. Detached responses survive all closure.
`close_program` and local `shutdown` close program context, not the client owner.
Neither client release nor GC saves state.
Here program close is **logical access closure**, not engine unloading:
upstream resets adapters, clears benchmark records and marks no program loaded,
but retains slot-owned engines and their architecture until owner release or
subsequent native replacement. Only binding `close()`/`__close`/GC releases the
native owner and the process client slot.

The two public views share owner-closed state and dispatch generation; they do
not maintain independent facade program state. After successful close_program
or shutdown through either view, program-dependent reads through either return
native `NO_PROGRAM` (backend local), not `CLOSED`. Owner-level status/capabilities
remain usable. `session:open_program(...)` and `session:native():open_program(...)` may reopen the same owner;
the existing Session then reads that new program. Previously created iterators
stay invalidated and prior open-response tables remain historical. After binding
owner close, SDK calls through both views return binding `CLOSED`; reopening that
owner is impossible. Native close failures preserve their native error/outcome,
not a fabricated successful-close state; generation still invalidates iterators
for dispatched lifecycle calls. Do not infer resource release from response.closed.

The following are pinned source observations, not experimental acceptance:

| Operation | Native behavior | Facade policy |
| --- | --- | --- |
| `save_program` | Requires open program and state_path; reports save failure | Preserve response/error; never promise binary patch persistence |
| `discard_program` | Returns discarded=true without reverting anything | Available through native(); no rollback convenience |
| `close_program(save)` | With empty state_path can close without saving | Reject missing state_path with binding `NO_STATE_PATH` before dispatch |
| `close_program(discard)` | Logically closes context; engines retained; no transactional restore | Access closure only; preserve outcome |
| `shutdown` | Local program close policy, not remote host termination | Session supports it with the same NO_STATE_PATH guard as close_program; native keeps the caveat |
| Open with state_path | Best-effort reload into slot 0, types/symbols only | Same limited reload; pool_size=1; no complete restoration promise |
| `write_bytes` / patch batch | Copy-on-write overlay, not persisted patches | Preserve per-call outcomes; no invented atomicity |
| Client destructor | No save | No autosave or rollback promise |

Low-level remains faithful even where convenience policy is stricter.
Native open ignores `read_only` and `project_name`; low-level accepts documented
native fields with this caveat, facade rejects either key rather than promising
protection. Open language/compiler metadata echoes request/default, not detected
architecture. Supply explicit language/compiler hints for reproducibility;
Python detection may otherwise differ. Get/list decompilation ignores
`timeout_ms` at this pin. Low-level retains that field as ignored; facade rejects
an explicitly supplied timeout, makes no deadline promise, and passes the native
default internally. No coroutine cancellation claim.

Additional pinned limitations (low-level accepts and validates these native
fields, but does not pretend they affect execution):

| Operation | Limitation |
| --- | --- |
| DeleteSymbol | name ignored; deletion selects by address, not an address/name guard |
| CreateType | size ignored; only kind="struct" supported; other kinds return NOT_SUPPORTED |
| AddTypeMember | size ignored; native appends after existing members, using referenced type |
| CreateTypeEnum | width and is_signed ignored by native defineEnum call |
| ListDefinedStrings | Ignores ranges/limit/offset; loaded program always returns empty success; no defined-string database |

These mutation operations are specialist native() calls, with no facade promise
of enforcing ignored fields. GetCapabilities is a faithful coarse upstream
subsystem advertisement, not an operation-level support oracle; its strings/full
CRUD claims do not override the qualified coverage inventory. ListDefinedStrings
is core low-level compatibility only, with no facade iterator or string scanner.

## 5. Iteration

Iterators retain the shared handle, fetch lazily without prefetch, and check
closed state and generation **before every yield**, including buffered records.
Shared native dispatch increments generation before every dispatched mutation,
program open/close, discard, shutdown or owner close, even if the operation
fails or has partial effects. Validation-only failures do not increment it.
Both surfaces invalidate existing iterators (`ITERATOR_INVALIDATED`).
Records already returned remain detached. Iteration is not a universal snapshot
and cannot detect externally changed files or engines.

Per-operation identity/order and bounded progress rules are in DESIGN.
For families whose offset domain is the returned-record sequence, advance by
actual returned count; short pages alone do not prove exhaustion.
ListFunctionSignatures is **pages-only** initially: native offset/limit select
candidate functions before missing signatures are filtered out. Neither returned
count nor an empty signature page measures consumed candidates or exhaustion.
Preserve the native response without invented continuation metadata.
Native serial ordering must be qualified before enabling each iterator; sorting
individual pages cannot repair unstable global ordering.

## 6. Acceptance and provenance

Every supported operation needs a positive real-backend case, not just a
`NOT_SUPPORTED` test. Authored binary and analyzed-project fixtures must be ready
at M0. Verify known bytes/instructions and completed, nonfallback decompilation
with expected semantic content. Preserve/test incomplete and fallback results
separately. Required acceptance uses Lua tests against the real native library,
authored expected results and direct C++ probes where needed. Python-binding
comparisons may inform initial development but are optional, nonauthoritative
and never a release gate or dependency. Core and full releases both pass M5;
absent evidence is an open gate, never a pass.
Exception to populated discovery acceptance: ListDefinedStrings must return
faithful empty success on an open real fixture containing known strings, plus
the unloaded-program error and binding validation tests. This qualifies envelope
fidelity only, not discovery; populated-page/order tests do not apply to this stub.

Boundary coverage includes uint64 0, 2^53±1, 2^63±1, 2^64−1, overflow, false/zero,
NULs, nested optionals, ordinals, compound pagination limits, stale iterators,
serial order, allocator failures and repeated independent-state lifecycles.
Standalone and shared/static embedded Lua hosts must use the existing VM.

### Upstream defects and wrapper responsibility

The deliverable is a Lua binding, not a repaired libghidra/Ghidra distribution.
Investigate a failure only far enough to distinguish a wrapper defect from an
upstream limitation and describe its practical impact; exhaustive upstream root
cause analysis is not required. Record the affected operation/profile, observed
behavior, available evidence and user-visible limitation in the owning coverage
or qualification document, then continue independent wrapper delivery. Upstream
defects are not wrapper qualification blockers solely because they remain unfixed.
Do not add an upstream repair campaign to milestone acceptance.

A small, well-understood wrapper-side workaround is permitted when its delivery
benefit justifies its implementation, tests and maintenance. Keep it isolated,
test the affected real-backend path, document the behavior and preserve public
contracts; do not invent results, hide corruption or claim the dependency fixed.
Workarounds are optional, not a new prerequisite or reason to defer the binding.
Dependency source changes remain subject to the separately authorized patch policy.

Wrapper defects, unsafe boundary handling and incorrect claims remain our
responsibility. A known upstream limitation must be labelled as such, not passed
off as supported functionality or a successful test. Ordinary positive tests still
apply where upstream provides the operation; preserve upstream-limited outcomes
and reconcile incompatible delegated expectations with their owner instead of
silently weakening tests or insisting on an upstream fix.

### Allocation-failure application

Operator scope clarification: allocation-failure qualification covers wrapper-owned
storage, ownership transfer, Lua allocation/longjmp safety, conversion/publication,
and wrapper handling of exceptions returned across the native boundary. Allocation
failures inside libghidra, Ghidra or other dependencies are upstream limitations:
document observed behavior and evidence, then exclude their internal cleanup,
retention, global-state recovery and exhaustive fault sweeps from M1/release gates.
Do not investigate or repair those internals further merely to qualify this wrapper.
Do not claim upstream OOM recovery is guaranteed. This exclusion does not excuse
wrapper-caused leaks, invalid lifetimes, double destruction, escaping exceptions or
unsafe Lua frames; ordinary real-backend functional/lifecycle tests remain required.

Upstream's Human-Origin Source License v1.0 explicitly includes bindings/wrappers
in its derivative definition **when** copied, materially derived or substantially
informed by protected expression (§§1.14–1.15); mere compatibility/public behavior
is not enough. Unmodified dependency use is expressly allowed (§1.10, §2.1).
The operator accepted the existing upstream license as valid **for project
planning**, closing the licensing research by disposition; see
[M0-LICENSE.md](M0-LICENSE.md). This supersedes the earlier open planning gate,
not the factual uncertainty: it is not legal clearance, compatibility proof,
new rightsholder permission or an automatic wrapper exemption. Do not repeat
the same applicability/permission question as a research-completion blocker.
The operator selected MIT for this wrapper's original code and documentation;
see [LICENSE](../LICENSE). Third-party components retain their own licenses.
Record intended use and retain the operator planning disposition at M0. Distribution must
preserve notices, provide exact applicable license and corresponding source
links, visible author/origin attribution and third-party notices (§§3–4, §8).
Do not include operator credentials or runtime state in source or evidence.
