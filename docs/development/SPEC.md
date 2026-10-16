# Binding contract

The native-local Lua/C++ binding wraps libghidra at
`d51ca813ae1b6b59519551a9be8c0b1ad74d862d`. Supported environment: Linux x86-64,
ordinary PUC Lua 5.4 with signed int64 integers and eight-byte double numbers
(qualified host 5.4.6), C++20 and CMake >=3.26. Lua 5.3 and other platforms need
independent qualification. No HTTP, SWIG or upstream Python-binding dependency.

[API](../API.md) owns exact signatures, defaults, surfaces, return envelopes and
limits. [DESIGN](DESIGN.md) owns implementation architecture;
[COVERAGE](COVERAGE.md) owns source accounting and support methodology;
[TESTING](TESTING.md) describes executable validation commands.

## Build and runtime dependencies

Project-owned deliverable tooling and qualification are Lua-based. Native SOURCE
builds use the unchanged pinned `cpp/embed_specs.py`, invoked by
`cpp/cmake/EmbedSpecs.cmake`, with Python >=3.10 and standard-library zlib/XML.
This is SOURCE-only: no Python bindings, project-owned Python tooling/test oracle,
SDK-consumer or installed Lua runtime Python requirement. Do not replace or patch
the upstream generator. Installed operation requires no Python, Java, Ghidra
application or network. Fixture generation may use development Java/Ghidra.

## Ownership and concurrency

Calls are synchronous. Exactly one live binding-owned client per process is
supported across Lua states; `pool_size` is exactly 1. A second owner returns
CLIENT_IN_USE. Engine construction, dispatch and destruction are serialized.
Each Lua state stays confined to its invoking thread. Do not mix independently
managed engines in-process. The module borrows the host VM, never a second VM.

Lowlevel returns detached native envelopes. Session shares the same owner and
unwraps selected reads while retaining the complete third response. False/zero
and empty values are not absence. Optional absence is nil/NOT_FOUND; native
failure has no invented response. `check` checks presence, not outcome success.

Owner close is idempotent and permanently closes all aliases; __close preserves
an active Lua error and __gc destroys the handle once. Program close/shutdown
are logical access closure, not engine unloading or owner release. Reopening
uses the same owner. Neither destruction nor discard promises save or rollback.
Category-specific persistence is documented in API, not inferred from saved=true.

## Value and boundary invariants

Every native uint64 output is exact immutable UInt64, including small values.
No float intermediary is allowed. Signed/narrow integer fields use checked Lua
integers. Dense arrays are 1-based; native offsets and ordinals remain zero-based.
Bytes are length-preserving strings, including NUL. Optional absence preserves
false and zero. Enum output preserves unknown numeric values.

Reject unknown keys, wrong types, sparse arrays, overflow and invalid compound
pagination before dispatch. ReadBytes accepts 0..INT32_MAX before requested-buffer
allocation. Accepted upper bounds are not memory-availability promises or a
requirement to allocate huge buffers. UInt64 parsing does not prove mapping:
unsafe addresses can crash the native process. Use caller-verified mapped inputs.

Native exceptions become structured errors; Lua allocation/runtime errors remain
Lua errors. No C++ RAII storage may be skipped by Lua longjmp. Every validation,
publication/conversion and finalizer path must preserve exactly one owner.
Dependency-internal OOM recovery is not guaranteed; wrapper lifetime, exception
containment and allocation/longjmp safety remain required.

## Iteration and support claims

Only functions, symbols and memory blocks have Session iterators. Validate shared
state/generation before every yield, including buffered records. Dispatched
mutations and lifecycle calls invalidate iterators even on failure/partial effects;
validation-only failures do not. Detached records survive closure. No universal
snapshot or external-mutation detection is promised. Pages-only/filtering and
constant-empty defined-string limits remain explicit in API.

Real supported native Lua execution, ownership/ABI checks and meaningful semantic
assertions establish runtime behavior; mocks, source reachability and nonempty
text alone do not. Preserve incomplete/fallback/error outcomes. Coarse native
capabilities are not an operation support oracle. Attribute inherited limitations
honestly; do not fabricate success or silently expand engine support.

## Licensing

Original wrapper work is [MIT](../../LICENSE), Copyright 2026 Salvador Fandiño.
Third-party terms remain applicable. [NOTICES](../NOTICES.md) retains exact
attribution, source obligations and current pins. This contract grants no new
redistribution permission or combined-license compatibility finding.
