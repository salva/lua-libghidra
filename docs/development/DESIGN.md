# Native binding architecture

The binding uses direct Lua C API, C++20 and a small Lua facade. There is no SWIG,
HTTP abstraction, upstream Python bridge, JSON/protobuf round-trip or record-object
hierarchy. [SPEC](SPEC.md) owns invariants; [API](../API.md) owns current grammar.

## Layers and shared ownership

`lua/libghidra/lowlevel.lua` exposes faithful envelopes; `lua/libghidra/init.lua`
implements Session factories, unwrapping and three iterators. Both use private
`libghidra._native`. `src/owner.cpp` holds the unique native IClient, owner-closed
state and generation; `src/boundary.{cpp,hpp}` supplies protected boundary and
UInt64 primitives. `src/{slice,core,full}_convert.hpp` publish detached values.
`lua/libghidra/iterator.lua` implements bounded traversal.

The userdata retains its C++ handle until GC. close/__close reset its unique
native owner; __gc destroys the enclosing handle exactly once. Publication uses
a construction marker. Aliases share the handle, generation and closed flag.
Session caches no independent program state that could hide native() transitions.
Native program close resets adapters/loaded state and benchmarks but retains
slot engines until owner release or replacement. Owner close releases the process
client slot; logical program closure does not.

The shared process guard serializes construction, dispatch and destruction across
Lua states and rejects a second owner. Never hold a mutex across allocating Lua
calls. Recheck closed state after Lua-running phases/finalizer reentrancy before
native dispatch. Lua states remain thread-confined.

## Protected phases

1. An outer owner holds requests, results and error storage. Raw Lua validation
   executes protected C API trampolines whose automatic locals are trivial.
2. Native request construction and dispatch use RAII without allocating/raising
   Lua calls. Catch SDK exceptions into owned error data and leave catch frames.
3. Protected response/error trampolines publish Lua values. After pcall returns,
   destroy native storage normally. Raise only from a trivial outer frame after
   all RAII scopes have ended.
4. Reserve userdata storage and install a GC-capable metatable before transferring
   ownership. Every failure edge has exactly one owner.

A protected trampoline alone does not protect destructors in jumped frames.
No live string/container/lock guard/exception object may be skipped by longjmp.
Audit setup, module/metatable initialization, nested conversion, UInt64, errors,
publication and finalizers, not just dispatch. Sanitizers supplement this proof.
Wrapper-only allocation/cleanup is distinct from dependency-internal OOM behavior;
there is no guarantee that the dependency recovers from its own allocation failure.

## Paging and invalidation

All calls share read/mutation/lifecycle classification. Generation increments
before dispatched mutations/lifecycle calls, including native() and failed/partial
calls; validation-only failures do not increment it. Iterators check before every
yield. They retain bounded previous-page identities/order, reject oversized,
repeated, duplicate and nonadvancing pages as PAGINATION_STALLED, and fetch lazily
without prefetch or an unbounded history set. Functions order by entry address,
symbols by symbol_id, memory blocks by start address/name. Offset advances by
actual returned count; short pages alone do not establish exhaustion.

Other families are pages-only. Signature offsets count candidates before filtering,
so empty output is not exhaustion. Instructions decode from the supplied start
until the first gap, not across all mappings. Native range end zero is an explicit
UINT64_MAX sentinel only for documented operations. Compound limit+offset must
fit INT_MAX; ReadBytes is bounded to signed int4 before allocation/dispatch.

## Integration and persistence

Source builds link `libghidra::local_whole`; SDK consumption recreates WHOLE_ARCHIVE
for the installed local archive, retaining registration objects. All incorporated
archives must be PIC. The selected profile uses shared BFD/sframe/zstd; arbitrary
static BFD archives and HTTP-only SDKs are insufficient. Module Lua symbols resolve
to the selected host; the helper DSO uses installed $ORIGIN layout.

External specs use explicit nonempty ghidra_root and bypass embedded extraction.
Embedded specs use empty root and `$HOME/.ghidracpp/cache/sleigh`; cold extraction
needs a writable cache. External-root success does not establish embedded behavior.
[TESTING](TESTING.md) describes profile/ABI validation.

State reload is best-effort types/symbols into slot 0, not complete restoration.
Byte writes are copy-on-write overlays, discard is not rollback, and destruction
never autosaves. Ignored native protection/deadline fields must not become facade
guarantees. See API for category-specific persistence and effective limits.
