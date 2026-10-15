# M1 native ownership implementation (bounded qualification)

MIT Copyright 2026 Salvador Fandiño. Extends [foundation](M1-BOUNDARY.md);
not a declaration of complete M1 or broad M2 coverage.

## Owning primitive and boundary audit

`src/owner.cpp` supplies one private userdata. Session strongly references that
same userdata; `native()` returns it, not a second engine. The trivial Slot is
initialized null and given its GC metatable before constructing Handle/IClient.
The unique_ptr is transferred only after construction succeeds, with no Lua
allocation between transfer and return. __gc releases and deletes once, nulling
the marker; close/__close release only the native client and increment generation
once. Program close/shutdown dispatches do not release the process slot.

Construction/dispatch/destruction all use the module's process-static mutex and
occupied bit. No lock spans Lua execution. Parsing has only trivial locals and
raw table reads. Borrowed strings stay rooted on the Lua stack even if a
finalizer mutates the input table. Stack capacity is reserved before native RAII;
lookup/closed checks occur after parsing and stack growth. Native requests,
responses and exceptions have no allocating Lua calls in their phase. The
packet remains outside the protected conversion frame. Conversion, field/error
helpers and protected-call setup use only trivial automatic storage. Packet
and native owners are destroyed before lua_error. Native status code/message
strings are preserved in full. Exception fallback uses bounded nonallocating
storage (exception messages may truncate at 2047 bytes), outside catch before
conversion. Binding owner close does not allocate or raise Lua errors.

Generation increments before each dispatched open/close_program/shutdown,
including native failures, never for rejected arguments. No facade cached
program state masks the native view. Minimal implemented dispatch: status,
capabilities, revision, open_program, close_program, shutdown, read_bytes.
ReadBytes validates before the dispatch lock/request/result and SDK invocation;
upper accepted size tests use no loaded program, so native NO_PROGRAM avoids a
multi-gigabyte request. Small real reads use the analyzed-project/ELF route.

## Selected engine globals

Audited pinned local_client.cpp, decompiler_pool.cpp, engine/ghidra_decompiler.cpp,
and selected engine libdecomp.cc, marshal.cc, capability.cc, sleigh_arch.cc.
LocalClient owns a pool; pool_size=1 creates exactly one Decompiler. Embedded
constructor acquires extracted specs and starts the library; external constructor
starts against the supplied root. Destructor resets Impl before shutdown and
embedded release. shutdownDecompilerLibrary is empty in this engine. Attribute
and element ID initialization drain registration lists into persistent maps;
capability initialization drains its registration list. Sleigh spec paths and
language descriptions are process globals. Therefore the binding must serialize
these paths, not rely on LocalClient's per-instance request mutex. Tests repeat
real engine creation/open/destruction and independent-state teardown; they do
not authorize concurrent external users, multiple loaded copies of the module,
or mixed externally owned Decompilers. Those remain unsupported/unqualified.
No libghidra or engine source was modified.

## Tests and residual qualification gates

`ownership_entrypoints.lua` preserves the red reproducer verbatim. Tests run in
shared and static/exported C-built Lua hosts. `ownership.lua` checks real project
open, detached metadata, aliases, native logical closure/reopen, native errors,
process slot reuse, generation, ReadBytes bounds and active-error preservation.
GetRevision is owner-level in selected LOCAL and succeeds without a program;
NO_PROGRAM checks deliberately use ReadBytes instead.

`ownership_host.c` uses two independent Lua states, both teardown orders,
GC-only release and persistent allocation denial through construction, error,
capability/status conversion and successful facade publication. Each failed
script is collected and a new owner is constructed in the same state before
allocator byte balance at state close. `ownership_reentry.lua` exercises
allocation-triggered Lua finalizers releasing/manually finalizing owners and
manual finalization is tested twice. This is useful reentry evidence, **not** a
deterministic proof of every exact predispatch allocation edge.

Remaining M1 qualification work, explicitly not waived by a passing entrypoint
reproducer: deterministic finalizer scheduling at each parsing/conversion edge;
native C++ allocation/exception injection (including partially constructed
upstream engine cleanup); concurrent
multi-thread independent-state engine overlap observation; whole dependency closure/Lua
sanitizer instrumentation. The combined initialization/ownership/conversion
sweep described below closes that specific earlier gap, not these other gates. Current ASan/UBSan instruments wrapper and C hosts,
not the prebuilt native SDK or system Lua. Foundation initialization sweeps are
separate. Full first-slice operations/iterators remain M2. Raw/FileBytes loader
limitations and historic qualification evidence remain unchanged. Installed
SDK load is tested, but release/LuaRocks/distribution gates remain open.

## Combined initialization/publication fault coverage

`tests/ownership_host.c` additionally starts a persistent Lua-allocation denial
sweep before either public module is required. Each fresh state has only standard
libraries, module paths and fixture names configured; the test chunk is compiled
before denial. One chunk requires both modules, publishes a low-level owner,
converts real status/capabilities and a native open error, releases it, then
publishes a Session over the real analyzed-project fixture and converts its
open response and status. The allocator counts actual denials: a reached denial
must return LUA_ERRMEM; an unreached threshold must return success with fewer
allocation calls than its index. Independent states need not have identical
allocation counts (including hash-dependent table/parser behavior). The sweep
visits every index through the baseline plus a bounded 16-point tail and requires
substantial reached-denial coverage and at least one unreached threshold. It is
not proof of all possible allocation traces. After restoring allocations and
full collection, the entire chunk must succeed again in that same state,
including require retry after partial initialization. Lua allocator byte balance
must return to zero at state close.

Reproduce with `cmake --build build --target ownership_host -j4`, then
`ctest --test-dir build -R ownership_states_faults -V`.
The original 371-point success was subsequently found unstable: one independent
state completed in 370 calls, so index 371 denied nothing and correctly returned
success. The repaired oracle distinguishes that case from swallowed OOM rather
than assuming each state's count equals the baseline. Historical verification
failure is retained in the card status; it was a test oracle failure, not evidence
of native corruption. The preloaded sweeps are unchanged. This covers Lua
allocation failure and recovery across the combined chain, not native C++
allocation failures, arbitrary GC scheduling, native heap leak accounting or
full sanitizer qualification.

## Concurrent independent states (bounded real-native coverage)

`ownership_concurrent_states` uses two worker threads, each exclusively owning
its own ordinary C-built Lua state. A C++20 barrier holds each winning owner
until both contested construction attempts finish: exactly one factory must
succeed, and the other must return binding CLIENT_IN_USE. Across 40 rounds,
status/capability dispatch and detached conversion run against rejected factory
loops in the other state. Release alternates explicit close (followed by CLOSED)
and GC-only destruction. Further barrier phases force alternating states to
construct a client and verify rejection in the peer, so scheduler bias cannot
hide cross-state reuse. After both workers close their states, a fresh state must
construct and release another real client. No mock, second concurrent owner,
engine patch or broad adapter is involved.

Run `cmake --build build --target ownership_threads -j4` then
`ctest --test-dir build -R ownership_concurrent_states --repeat until-fail:5 -V`.
The test has a 120-second timeout for deadlock detection; assertions remain on
in release builds. This asserts public slot exclusivity and cross-thread/state
reuse for one loaded module. It is not a TSAN/native-phase overlap observer,
proof across independently loaded module copies, or exhaustive engine-global
race proof; those restrictions and remaining qualification gates are not waived.

## Real logical-close save failure preservation

`tests/ownership_close_failure.lua` opens the analyzed-project fixture through
Session with `state_path=/dev/null/lua-libghidra-state.xml`. On the qualified
Linux profile a child of the non-directory /dev/null cannot be opened, including
as root. This injects a real native file-open failure without mocks, permission
assumptions, or writable temporary state. Pinned `Decompiler::saveState` returns
`Unable to open file for writing: <path>`; `closeProgramLocked(save)` returns
SAVE_FAILED before resetting adapters/loaded state; Shutdown forwards that error.

Static and shared C-built embedded hosts assert the exact native code/message,
backend and operation for facade close_program(save) and native shutdown(save).
Each failure increments shared dispatch generation once, retains program byte
reads through both aliases and keeps the process slot occupied. A subsequent
discard succeeds, exposes native NO_PROGRAM (not CLOSED), retains owner status,
and only binding owner close permits a new client. This covers the real native
save-failure branch, not every possible native exception/outcome or persistence
success. Run `ctest --test-dir build -R ownership_close_failure -V` after building.

## ReadBytes operation-level ordering observer

`read_bytes_dispatch_order` compiles the same owner/boundary sources with two
nonallocating test-only callbacks: after accepted validation (before native
request/lock) and immediately before SDK ReadBytes invocation. Production builds
have neither callbacks nor new exports. The real native client has no program:
0 and INT32_MAX each reach both phases once in order and return native NO_PROGRAM;
INT32_MAX+1 and UINT32_MAX reach neither phase and return binding INVALID_ARGUMENT.
The host replaces ordinary C++ new/new[] to observe request/response allocations
and refuses any allocation over 1 MiB while calling the operation. Observed
largest allocations are 42 bytes for accepted values and zero for rejected ones.
No requested-size buffer or multi-gigabyte read is performed. This is not a
malloc/aligned-allocation observer or full native allocation/exception sweep;
source ordering plus dispatch counts establish oversized requests cannot reach
the SDK's buffer allocation. Existing Lua tests cover facade delegation.

Reproduce: build target `read_order_host`, then run
`ctest --test-dir build -R read_bytes_dispatch_order -V`.

The same host additionally enables persistent ordinary C++ new/new[] denial
only after constructing the real owner and preparing the call. ReadBytes(0,0)
on the unloaded owner must actually hit denial after the SDK-dispatch marker,
return nil plus NATIVE_EXCEPTION/binding/read_bytes with nonempty message,
and then return native NO_PROGRAM on a same-owner retry once allocations resume.
This exercises real std::bad_alloc propagation through SDK/binding lock scopes,
the nonallocating exception fallback and protected conversion, rather than
injecting an exception at an artificial callback. Denial remains enabled through
catch and conversion. It is bounded native-allocation failure/recovery evidence,
not partial-engine-construction cleanup, exhaustive native fault sweeps,
destructor accounting, malloc/aligned faults or full dependency sanitizer proof.
