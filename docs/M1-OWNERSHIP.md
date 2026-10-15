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
upstream engine cleanup); logical-close native failure injection; concurrent
multi-thread independent-state stress; fault sweeps of module initialization
combined with ownership in a single script; whole dependency closure/Lua
sanitizer instrumentation. Current ASan/UBSan instruments wrapper and C hosts,
not the prebuilt native SDK or system Lua. Foundation initialization sweeps are
separate. Full first-slice operations/iterators remain M2. Raw/FileBytes loader
limitations and historic qualification evidence remain unchanged. Installed
SDK load is tested, but release/LuaRocks/distribution gates remain open.
