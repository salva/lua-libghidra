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

## Deterministic finalization at the owner recheck edge

`ownership_deterministic_recheck` builds the real owner sources and SDK with a
test-only Lua-running callback after dispatch stack reservation and immediately
before slot lookup. It forces actual Lua GC exactly there, once per armed call.
An unreachable finalizable table closes the dispatch receiver, constructs and
closes a replacement client, and increments a hit counter. Both ReadBytes and
OpenProgram (with rooted parsed strings) must return CLOSED/binding with correct
operation instead of dispatching into the closed/replaced owner. Hit/edge counts
and subsequent fresh construction are asserted. The finalizer wraps its native
close/replacement sequence in pcall and publishes both success/error and a
completion counter set only after replacement close. Outside GC, the test
requires success, nil error and exactly one completion; Lua's suppressed
finalizer errors cannot masquerade as replacement success. The one-shot arm is cleared
before GC to permit finalizer reentrancy; CTest has a 30s deadlock timeout.

This pins a genuine Lua finalizer to the last pre-recheck edge and exercises
release/reconstruction with no native lock held. The callback is absent in
production. It is **not** allocator-driven GC scheduling inside parsing or
stack growth, nor conversion-edge finalization or native cleanup accounting.
Those independent exact-edge qualification requirements remain open. Reproduce
with target `reentry_host` and CTest regex `ownership_deterministic_recheck`.

### Allocating native success-response fault sweep

The same host sweeps persistent ordinary C++ new/new[] denial over the real
GetCapabilities path, not just the unloaded-program error. Each reached
allocation threshold must return NATIVE_EXCEPTION/binding/get_capabilities;
unreached thresholds must return a nonempty capability table. Every iteration
restores allocation and retries the full operation on the same owner. The sweep
stops at the first measured success tail (with a 256-point ceiling that must
reach success); no assumption equates another state's baseline with a failure.
On the current SDK it reaches 15 failures then the success tail. This exercises
unwinding of partially populated vector/string response storage, lock recovery,
and protected conversion after native failure. The host's ordinary C++ allocation
operators now maintain aligned size headers and outstanding block/byte totals
across all observation windows. After each failed or successful response is
converted/destroyed, and again after its restored-allocation retry, both totals
must equal their pre-call baselines. This attributes zero retained ordinary C++
allocation delta to each tested call (including partial-response failures),
without requiring global engine caches to vanish. Counts include executable
ordinary new/new[] only; they do not measure Lua/malloc/aligned allocation,
prove semantic destructor execution, cover partial engine construction, or
constitute exhaustive whole-engine fault qualification.

### Lua conversion OOM with attributable native response balance

The host additionally uses a byte-counting realloc-based Lua allocator. After
native allocation faults are restored, it sweeps persistent Lua allocation
denial during GetCapabilities, requiring LUA_ERRMEM for actual denials and a
nonempty response for the measured success tail. Ordinary C++ outstanding
block/byte counts must return to pre-call baseline after every conversion error
and every same-owner retry. Current SDK/Lua reaches 26 denied points then success.
Lua bytes must be zero at lua_close. Automatic GC is stopped during this sweep
to avoid unrelated finalization changing native baselines; this is deliberately
not finalizer scheduling. This connects protected conversion/rethrow to actual
native response cleanup under C-built Lua longjmp, not just successful native
exception handling. It remains bounded response-storage evidence, not semantic
destructor counting, all-frame proof, partial-engine cleanup or full native heap
instrumentation. Reproduce through the existing read_bytes_dispatch_order test.

### Independently loaded module copies: failing process-wide guard regression

`ownership_loaded_copy` loads the production module and a byte-identical copy
at a distinct inode using package.loadlib. With an owner from A still live, B
must return CLIENT_IN_USE/binding; after A closes, B must construct and work.
The fixture includes reversed order and explicitly cleans up both owners before
asserting exclusion, so a teardown crash cannot replace the primary failure.
CMake creates the test copy after linking lua_ghidra; no engine or Lua mock is
used. Build lua_ghidra, then run `ctest --test-dir build -R
'^ownership_loaded_copy$' --output-on-failure`.

At the current implementation this test FAILS: the second loaded copy admits a
second owner. A repeat confirms it, with identical SHA256 but distinct inodes.
owner.cpp's anonymous-namespace engine mutex and occupied flag are per-DSO, not
process-wide. Prior single-module independent-state exclusion remains valid in
its bounded scope; it does not establish the specified loaded-copy guard or
native serialization across copies. This is an exposed product defect, not an
expected-failure test or full M1 acceptance. Reverse-order/reuse assertions are
present but not reached after the first exclusion failure. Repair belongs at the
shared guard/serialization owning primitive, not loader-name special cases.

Repair of the preceding failure moves BOTH the engine mutex and occupied flag
into `libllg_process_guard.so.1`, a required shared support library, rather than
relying on ELF weak/global interposition or module-path detection. Every binding
copy has a DT_NEEDED dependency on that SONAME. Construction, native dispatch and
release use the same support object; no Lua-running scope acquires its mutex.
The dependency remains loaded while a dependent module/host remains loaded.
Installations must ship the support DSO alongside `_native.so`; installed module
RUNPATH is `$ORIGIN`. Static embedding of owner.cpp must also link this shared
support library, never compile process_guard.cpp separately into each consumer.
This is Linux's ordinary loader namespace contract, not dlmopen-isolated
namespaces or independently managed engines. Mixing incompatible guard ABI major
versions in one process is unsupported. Native engine closure itself is unchanged.

The unchanged loaded-copy regression now passes in both orders, including reuse
after release. Focused loaded-copy/concurrent-state/response-fault/reentry tests
passed three repetitions each, and all 15 registered tests passed. This repairs
the demonstrated cross-copy slot defect and unifies the serialization primitive;
it does not substitute for native phase-overlap instrumentation, every-frame
longjmp audit, allocator-driven finalizer scheduling or full M1 qualification.
Historical failing commands above remain intentional provenance, not expected
failures or assertions removed from the test.

### Combined native exception and Lua error-conversion allocation denial

The response fault host now runs the Lua allocation sweep in two modes. The
existing successful native response mode remains; the new mode persistently
refuses ordinary C++ allocation from the first attempt AND sweeps persistent Lua
growth refusal during the same GetCapabilities call. Every iteration requires
an actual native refusal. Reached Lua refusal requires LUA_ERRMEM; the measured
no-Lua-refusal tail instead requires NATIVE_EXCEPTION/binding/get_capabilities.
Both modes require ordinary C++ block/byte balance and a complete restored-fault
same-owner retry after every iteration. Current runs reach six denied Lua points
in the native-exception mode (26 in successful native-response mode).

This covers native catch/fallback followed by failing protected error conversion,
with error rethrow only after Packet destruction. It does not manufacture a throw
in a callback. Automatic GC is stopped, so no finalizer scheduling is claimed.
It is not partial-engine construction cleanup, semantic destructor counting,
all-frame/sanitizer qualification, or exhaustive native allocation traces.
Reproduce with target read_order_host and CTest read_bytes_dispatch_order.

### Bounded native factory allocation-failure recovery

Before creating the persistent response-test owner, read_order_host persistently
refuses ordinary C++ new/new[] at thresholds 1 through 16 during local_client.
Each threshold must actually refuse allocation and return structured
NATIVE_EXCEPTION/local_client; after restoring allocation, a fresh real native
owner must construct, report status and close, followed by collection. This
covers wrapper Handle and native factory/partial-construction failures without
holding a prior owner, rather than only response faults on an initialized client.
The real SDK factory uses make_unique<LocalClient>, whose constructor initializes
a DecompilerPool. No synthetic throw or dependency edit is used.

This is deliberately the first sixteen observed thresholds, not a sweep to
successful construction or an exact allocation-site map. Recovery proves the
process slot is not retained and subsequent native initialization works; it does
not prove zero retained engine registry/cache allocations or semantic destructor
counts. Allocation traces vary after native caches initialize. Full partial-engine
cleanup/accounting and deeper factory fault coverage remain open requirements.

### Installed module in shared/static existing VMs

`tests/installed_owner.lua` restricts package.path/cpath to an explicit installed
prefix (no source/build/ambient fallback). It loads lowlevel/facade/native,
checks exact UINT64_MAX decimal conversion, and repeats real owner
status/capabilities, competing-owner rejection, native NO_PROGRAM, idempotent
close/CLOSED and fresh-owner reuse eight times. Run from repository root:

```sh
cmake --build build -j4
prefix="$SAIVAGE_CARD_WORK_ROOT/installed-owner-qualification"
cmake --install build --prefix "$prefix"
build/boundary_static_host tests/installed_owner.lua "$prefix" "$PWD"
build/boundary_shared_host tests/installed_owner.lua "$prefix" "$PWD"
```

The final argument supplies only the authored project/ELF fixture root, not a
module search path. Both ordinary C-built hosts use their already-created Lua
state. In addition to eight unloaded-owner rounds, three analyzed Session rounds
compare facade detached byte strings/envelopes against the native alias, discard
and reopen through opposite views, check shared generation and Session visibility,
and collect the Session while retaining a usable native alias. The ELF/project
are existing authored fixtures; runtime does not invoke Java or Python.
Three runs per host passed (six total), each including all three Session rounds.
Installed module readelf previously showed guard SONAME dependency, `$ORIGIN`
RUNPATH and no liblua dependency; binary inputs were unchanged for this extension.
This adds integrated installed analyzed-Session lifecycle coverage beyond loading
the facade only; it does not qualify all build modes/source rebuilds, full
installed closure or sanitizer/frame safety.

### Direct factory Lua allocation denial and GC-only release

`read_bytes_dispatch_order` also sweeps persistent Lua growth refusal during
protected direct `local_client()` calls, up to the first measured no-refusal
success tail (ceiling 512). Every actual refusal must produce LUA_ERRMEM; the
success tail must return an owner. All returned owners are dropped without
explicit close and collected; after every fault/tail a fresh owner must construct
and explicitly close. The Lua allocator must still balance to zero at state
close. Three repetitions reached two refusal thresholds each then a success tail.
This separately tests direct factory setup/publication recovery, rather than
inferring it from a combined require/Session script. It does not identify exact
allocation instructions or guarantee a refusal occurs after native publication;
that success branch has no allocating Lua API after transfer. GC-only success
release is directly exercised. Native constructor heap/destructor attribution,
allocator-driven finalizer reentrancy and error-conversion factory faults remain
separate requirements. Run `cmake --build build --target read_order_host -j4`
and `ctest --test-dir build -R '^read_bytes_dispatch_order$' --repeat until-fail:3 -V`.

### Native factory exception plus Lua error-conversion OOM

The direct factory host also persistently refuses ordinary C++ allocation from
its first attempted allocation while sweeping Lua growth refusal through the
first successful structured-error tail. Lua-only setup denials are checked as
LUA_ERRMEM but excluded from the dual-fault count; at least two iterations must
actually observe BOTH native and Lua refusal. The no-Lua-refusal tail must report
NATIVE_EXCEPTION/local_client/binding with actual native refusal. After each
iteration both allocators are restored, GC runs, and fresh real construction and
close must succeed. Three focused repetitions each reached ten dual-fault points.
This tests protected conversion/rethrow on a failed factory (separate from the
GetCapabilities dual fault). First native allocation refusal does not demonstrate
deep engine initialization, semantic destructor counting or heap balance; those
remain open. Reproduce via the read_bytes_dispatch_order focused command above.

### Shared native guard contention

`ownership_guard_contention` links the same versioned process-guard DSO as the
production module. A worker-confined C-built Lua state loads that module, then
barriers let the host hold the shared engine mutex before releasing a factory,
status or close operation. Completion must remain pending for 50ms while held,
then finish within 10 seconds after unlock; worker cleanup must leave occupancy
false. Five focused repetitions passed (0.83s). Reproduce with
`cmake --build build -j4 && ctest --test-dir build -R '^ownership_guard_contention$' --repeat until-fail:5 -V`.

This adds empirical contention evidence for construction, dispatch and explicit
native destruction through the shared support primitive without modifying product
or SDK code. It is bounded: a worker could be descheduled during the observation
window, and no SDK phase entry/exit counters are present. It therefore does not
replace native phase-overlap/destruction-vs-construction instrumentation or prove
all lock coverage or absence of locks across arbitrary Lua callbacks.

### Attributed native lifecycle phases (not a timing oracle)

`ownership_native_phases` compiles the real boundary/owner with a test-only
`LLG_NATIVE_PHASE_OBSERVER`. Nonallocating noexcept entry/exit callbacks bracket
CreateLocalClient through publication, native dispatch and client.reset through
slot release, INSIDE the shared lock. An atomic active counter asserts no overlap;
thread-local phase identity and per-kind counts assert matched exits. The scoped
observer destructor runs during native exception unwinding too, before the lock
is released; there are no Lua calls in these scopes. Production builds expand
the markers to no-ops and export no observer or scope symbols.

Two independent ordinary C-built Lua states race factories and native calls,
alternate explicit and GC-only release, reverse ownership, and race retained
owner destruction against the other state's fresh factory retry. The retry loop
accepts only CLIENT_IN_USE until a real owner succeeds. No barrier separates
reset from competing factory calls. Three focused repetitions each observed
121 constructions, 880 dispatches, 121 resets and 120 destroy-to-construct
transitions, balanced with zero overlap; the broader 17-test suite passed too.
Reproduce with `cmake --build build -j4 && ctest --test-dir build -R '^ownership_native_phases$' --repeat until-fail:3 -V`.

This is attributable binding-level native critical-phase evidence, replacing
reliance on worker pending time for those exercised paths. It is NOT internal
engine subobject destructor accounting, exhaustive factory exception injection,
all-operation lock proof or universal scheduler/loader qualification. It uses
instrumented real owner code linked to the unchanged SDK in an existing Lua VM;
production DSO loading remains covered separately by contention/copy tests.

### Deeper native factory fault sweep — failing lifetime gate

The read-order host now sweeps persistent ordinary C++ refusal beyond sixteen
thresholds through a measured success tail (ceiling 4096). After EACH attempted
factory, all Lua results are removed and full collection runs, then ordinary
new/new[] live blocks/bytes must equal that attempt's baseline. Actual refusal
must return NATIVE_EXCEPTION/local_client; restored fresh construction/status/
close is required. Successful retries can retain upstream process state, so their
post-retry balance is not asserted against the preceding baseline; each next
fault uses its own baseline. Such retained state is not declared benign or waived.

This coverage currently FAILS reproducibly: threshold 602 actually refuses one
allocation and leaves one extra 91-byte ordinary C++ block after result removal
and collection (23957 -> 23958 blocks; 5372078 -> 5372169 bytes). Three final
executions reproduce the same delta. Earlier threshold-one failure after the
successful recovery was an overbroad baseline oracle and is recorded separately;
the threshold-602 failure occurs BEFORE recovery. No production/SDK repair was
made here. Determine allocation identity/stack and ownership at the repair route
before calling this an engine leak rather than retained process state. This is
not semantic destructor accounting or an exhaustive sweep: the first failing
gate stops before measured success tail. Reproduce with
`cmake --build build --target read_order_host -j4 && ctest --test-dir build -R '^read_bytes_dispatch_order$' -V`.

#### Repair investigation: threshold 602 is reachable upstream global state

GDB on the task-owned host attributes the last successful 91-byte allocation to
`ghidra::FileManage::addDir2Path`, via `SleighArchitecture::scanForSleighDirectories`,
`startDecompilerLibrary`, `Decompiler`, `DecompilerPool`, `CreateLocalClient` and
the real Lua owner factory. The subsequent refused allocation requests 181 bytes
in the SAME addDir2Path frame. Pinned engine source first pushes the path string
into pathlist, then appends the separator. The latter allocation throws after the
vector already owns the original string. `SleighArchitecture::specpaths` is a
process-global FileManage and shutdown does not clear it.

At the abort GDB inspected that global's last std::string: length/capacity 90,
its data still points at the 91-byte allocation (the test allocator header
contains 0x5b). Its text is the embedded-cache 6502 languages directory, without
the final slash. This is reachable partially modified upstream global state,
not demonstrated lost ownership in the wrapper or a skipped Handle destructor.
It also explains why merely warming one construction cannot make all later
factory baselines stationary: every scan appends paths to the same global.

The failing balance assertion remains intact. This attribution does NOT waive
the required fault/lifetime gate or authorize an engine patch. Next repair must
separate attributable process-global state from per-attempt owned storage using
real pinned types/symbols (not a guessed-layout production shim), and check path
validity/recovery; alternatively an engine-owner-approved transaction/cleanup
change would need its existing authority and locked patch process. No upstream
source or installed SDK was changed during this investigation. A debugger exit
0 after SIGABRT is diagnostic success only, not test success.

### Operator scope disposition (a0289f5)

The explicit operator decision now limits allocation-failure acceptance to wrapper
ownership/cleanup, Lua longjmp/publication/conversion and boundary exception
handling. The historical threshold-602 upstream global specpaths mutation remains
an observed upstream issue, **not repaired**, and is ignored as a qualification
blocker. No upstream OOM recovery guarantee is made. The earlier demand to finish
an exhaustive native factory/internal destructor sweep is superseded.

The mandatory read-order test no longer sweeps SDK/internal allocations. It
refuses the first wrapper Handle allocation (before CreateLocalClient), checks
structured exception conversion and block/byte balance, retains combined wrapper
Handle+Lua-error conversion refusal, Lua factory publication faults, ReadBytes
ordering/bounds and real successful GetCapabilities response conversion under
Lua OOM with native response storage balance. Normal native factory, lifecycle
and concurrency tests remain required. The historical upstream reproducer remains
reproducible from d6d61e2/6239b3a and its recorded logs; it is not a mandatory green
release test. No known wrapper failure is excluded by this disposition.

An uncommitted test-only specpaths move/reset experiment was stopped and removed
on delivery of the decision. It reached 685 native faults plus success tail only
WITH test reset, recording 84 attempts with 1707 blocks/367395 reachable bytes
removed by test cleanup. Its green results were not production rollback evidence.
A raw mode still reproduced threshold 602. Neither result repairs upstream state;
no additional global accounting/investigation is required or continued. Source,
SDK and approved engine patch remain unchanged.

### Wrapper option/request copy fault batch

`read_order_host` now roots non-SSO strings for all three factory string options
and refuses each of those wrapper copies and the subsequent Handle allocation
(four known ordinary C++ sites only). For EACH site it also sweeps Lua refusal
through protected error conversion, counting only actual combined refusals;
setup-only Lua refusal is not counted. Every returned structured tail checks
NATIVE_EXCEPTION/local_client/binding. All popped/collected outcomes restore the
per-attempt ordinary C++ block/byte baseline; restored ordinary factory/close
checks show no stranded process slot. Observed: 40 actual dual refusal points.

All six OpenProgram request string copies are likewise individually refused
before engine dispatch. Each returns NATIVE_EXCEPTION/open_program/binding,
restores ordinary block/byte balance and leaves the same owner able to call
get_revision. This does not assert revision value or generation stability, nor
successful opening of the deliberately synthetic paths. It does not sweep into
upstream allocations or attempt to validate upstream OOM recovery. Inputs are
rooted before refusal, while fault-result conversion uses the real ordinary
C-built Lua runtime. This batch closes the previously untested nonempty option/
request-copy branches, not the exhaustive Lua-frame/reentrancy/sanitizer gates.

Reproduce: `cmake --build build -j4 && ctest --test-dir build -R '^read_bytes_dispatch_order$' --repeat until-fail:3 -V && ctest --test-dir build --output-on-failure`.

### Allocation-driven finalization during real result/generation conversion

The reentry host now also uses Lua's ordinary incremental collector, not an
explicit collect/step call, to finalize an unreachable table while the real
get_status/get_revision/get_capabilities/_generation operation is executing.
The call is rooted before collector restart; debt is varied with unreachable
tables while stopped. No allocator callback reenters Lua. A test C finalizer
marker records execution phase; the existing pre-recheck observer ONLY marks
phase in this mode (no collection). For dispatch cases the required finalizer
phase is AFTER that observer; _generation has no dispatch observer and requires
inside-call phase. Therefore setup/cleanup collection cannot satisfy the test.

Finalizer closes the actual owner and constructs/closes a real replacement.
External assertions require exactly one hit, successful inner pcall and one
completed replacement close. Natural-finalization assertions run before any
explicit cleanup collection. All four paths must actually observe finalization;
not merely fail to crash. Calls must return LUA_OK; the host does not yet assert
every detached response field in this fixture (other functional fixtures do).
Existing deterministic pre-recheck close/reconstruct/CLOSED checks remain.

This provides genuine allocation-driven reentrancy evidence for result conversion
and generation userdata allocation with no native lock across Lua. It does NOT
close all parsing/stack-growth/factory publication edges or attribute the exact
allocation instruction within conversion. Those remain explicit coverage gaps;
this is not exhaustive per-edge scheduling proof. Whole ordinary and wrapper
ASan/UBSan suites pass with these additional cases.

### Reentrant detached-state and factory prepublication assertions

Natural-conversion cases now keep the returned detached result rooted and check
nil error, status true/local/service string, revision modification zero,
capability id/status strings, or generation snapshot zero as appropriate. After
the finalizer's close/replacement completes, original receiver must return CLOSED,
its generation must be one, and a fresh owner must be constructible/closable.
The detached value stays rooted through further collection. Thus LUA_OK alone is
no longer the conversion-state oracle (not all response fields are asserted).

A related natural-GC factory case now queues a finalizer that constructs/closes
a competing real client before outer factory publication. Empty options are
rooted, GC restarted only at call entry. Required in-call finalizer marker plus
exactly-one hit/inner-pcall/completion confirms real scheduling. Outer published
owner must then be usable, exclude another factory with CLIENT_IN_USE, close
twice, collect and permit fresh reuse. No collector step/collect inside call.
Current source's only GC-checking allocation on this empty-options successful
factory path is null Slot userdata creation before native ownership; publication
itself has no allocating Lua API. This is source-supported prepublication
attribution, not an exact allocation-PC trace or an injected postpublication edge.

Parsing/stack-growth-specific scheduling remains a residual coverage question;
these tests do not manufacture product allocations to claim those edges exercised.
Both complete ordinary and sanitizer suites were rerun on this fixture.
