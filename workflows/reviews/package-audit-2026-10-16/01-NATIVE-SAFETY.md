# Native boundary and lifetime audit

Baseline: `4903eb7441242a742ffa97d502eb6fc7735c2355`. Independent fresh source
review, 2026-10-16. Audit only; no implementation changes or test/build runs.

## Result

**No substantive actionable wrapper-safety defect established in this dimension.**
This is a bounded static-review conclusion, not a new runtime qualification or
an assertion of absolute safety. There are no severity-ranked findings, reproduced
defects, or proposed repair campaign in this report.

Read the project instructions, SPEC, DESIGN, COVERAGE, PLAN and this audit's index
and subsystem map. Inspected all production `src/*` files, guard linkage and the
boundary/ownership/reentrancy test implementations. The available upstream source
checkout reports the required `d51ca813ae1b6b59519551a9be8c0b1ad74d862d` revision;
its model definitions were used to check native storage assumptions.

## Boundary reasoning checked against Lua

Checked actual PUC Lua 5.4.6 implementation of
[`lapi.c`](https://github.com/lua/lua/blob/v5.4.6/lapi.c) and
[`lauxlib.c`](https://github.com/lua/lua/blob/v5.4.6/lauxlib.c), including
`lua_pushcclosure`, `lua_pcallk`, `lua_tolstring`, `lua_newuserdatauv`,
`auxgetstr`, `luaL_testudata` and `luaL_setmetatable`. The current lua.org 5.4
source was consulted too; it reports 5.4.9 and was not mistaken for the qualified
5.4.6 runtime.

* **Longjmp/exception frames:** [src/owner.cpp#L499](../../../../src/owner.cpp#L499)
  reserves stack before creating the Packet. Request/SDK RAII and mutex scopes
  finish before protected conversion at
  [src/owner.cpp#L622](../../../../src/owner.cpp#L622); the final `lua_error` is
  outside Packet lifetime. Conversion helpers take references/pointers and have
  trivial automatic storage, including nested arrays and optionals
  ([src/slice_convert.hpp#L50](../../../../src/slice_convert.hpp#L50)).
  Zero-upvalue C-function pushes and lightuserdata pushes used in pcall setup
  do not allocate in this Lua implementation. Protection covers call entry as
  well as the conversion body. No skipped owning destructor was identified.
* **Native exceptions:** native request copies, owner allocation, lock acquisition
  and SDK dispatch occur inside catches. Exception text is copied into fixed
  Packet storage before leaving the catch
  ([src/owner.cpp#L109](../../../../src/owner.cpp#L109)); Lua publication occurs
  afterwards. The Packet's default construction outside the try is not itself
  evidence of a defect: inspected response models default to empty standard
  containers/strings, disengaged optionals and scalar values. No allocating
  default member initializer was identified that would establish an escaping
  exception at that edge in the supported configuration.
* **Factory publication and finalization:**
  [src/owner.cpp#L324](../../../../src/owner.cpp#L324) allocates a null Slot and
  installs its GC metatable before native ownership transfer. Transfer happens
  under the process lock, followed by no allocating Lua API on success.
  [src/owner.cpp#L121](../../../../src/owner.cpp#L121) separates resetting the
  client from deleting the Handle; GC nulls the Slot after deletion. Repeated
  manual finalization therefore does not repeat deletion. `__close` shares the
  release path without constructing an error that could replace a scope error.
* **Reentrancy and borrowed roots:** string fields deliberately stay on the Lua
  stack ([src/owner.cpp#L301](../../../../src/owner.cpp#L301)); direct string
  arguments remain rooted as arguments. Benchmark strings are likewise retained
  ([src/owner.cpp#L462](../../../../src/owner.cpp#L462)). Strict string checks
  prevent `lua_tolstring` numeric coercion and its additional GC edge.
  Owner validity is rechecked after parsing/stack growth. No native Handle
  pointer is needed during result publication: Packet owns detached results, so
  a finalizer may close or manually destroy the source owner then.
* **Batch special case:** [src/owner.cpp#L348](../../../../src/owner.cpp#L348)
  parses under a separate protected call with the vector owned outside that
  call. Each byte string stays rooted through its native copy; allocation
  exceptions are caught before returning to Lua. The receiver is rechecked
  again after that Lua-running phase
  ([src/owner.cpp#L508](../../../../src/owner.cpp#L508)). The extra recheck is
  justified, rather than redundant historical defensive code.
* **Process/thread lifetime:** construction, SDK calls and reset all acquire the
  same shared guard; no ordinary Lua-running API is inside the critical sections.
  The guard is a real DT_NEEDED shared library with SONAME 1
  ([cmake/Binding.cmake#L25](../../../../cmake/Binding.cmake#L25)), rather than a
  per-module local static. This addresses separately loaded ordinary RTLD_LOCAL
  module copies. Handle access outside the mutex relies on the specified Lua-VM
  thread confinement; separate independent VMs do not share those userdata.

## What the tests actually establish by construction

These are inspected assertions and mechanisms, **not fresh pass claims**:

| Area | Relevant evidence and boundary |
| --- | --- |
| Wrapper allocation/exception handling | [tests/read_order_host.cpp#L94](../../../../tests/read_order_host.cpp#L94) refuses actual wrapper Handle/option allocations, counts native blocks and verifies reuse. [Line 360](../../../../tests/read_order_host.cpp#L360) targets request copies. These are deliberately not exhaustive dependency OOM sweeps. |
| Lua longjmp cleanup | [tests/boundary_host.cpp#L402](../../../../tests/boundary_host.cpp#L402) checks actual allocator denial, owner counters and same-VM retry, including synthetic nested records. [tests/ownership_host.c#L68](../../../../tests/ownership_host.c#L68) starts denial before require and retries initialization. |
| Finalizer reentrancy | [tests/reentry_host.cpp#L54](../../../../tests/reentry_host.cpp#L54) forces the pre-recheck edge; [line 122](../../../../tests/reentry_host.cpp#L122) observes allocation-driven finalizers during loaded detached conversion. These are stronger than merely collecting between method calls. |
| Manual finalization | [tests/ownership_host.c#L107](../../../../tests/ownership_host.c#L107) explicitly calls GC twice. [tests/ownership_reentry.lua#L5](../../../../tests/ownership_reentry.lua#L5) includes manual GC from a pending finalizer, but does not pinpoint its phase as tightly as the C++ reentry host. |
| Independent states and serialization | [tests/ownership_threads.cpp#L28](../../../../tests/ownership_threads.cpp#L28) races construction across independent VMs. [tests/native_phases.cpp#L77](../../../../tests/native_phases.cpp#L77) races release against construction and checks balanced/nonoverlapping phases. [tests/guard_contention.cpp#L37](../../../../tests/guard_contention.cpp#L37) checks the same shared mutex. |
| Loaded copies | [tests/ownership_loaded_copy.lua#L4](../../../../tests/ownership_loaded_copy.lua#L4) loads two distinct module files and checks exclusion/reuse in both orders. It does not exercise separate linker namespaces or arbitrary mixed-version support libraries. |

The retained ownership split, prepublication GC setup, borrowed-string roots,
post-Lua receiver rechecks and shared guard each address a concrete reachable
lifetime boundary. Their retention is justified by current code paths, not prior
approval. Conversely, this review supplies no basis for adding more engine OOM
gates, replacing the adapter architecture, or broadening native concurrency.

## Limitations and dimension conclusion

No runtime probe, shared suite, sanitizer, build, container command or dependency
modification was performed by this reviewer. Coordinator results must supply any
fresh execution evidence. This review does not qualify hostile debug-registry or
userdata forgery, concurrent access to one Lua VM, independently managed Ghidra
engines, arbitrary host unload behavior or separate `dlmopen` namespaces. None was
promoted into a speculative wrapper defect. Full API semantics and distribution
policy belong to the other audit dimensions.

Documented dependency-internal OOM/engine limits remain upstream classifications;
they neither establish wrapper correctness nor justify an upstream repair campaign.
Confidence is **moderate-to-high in the inspected boundary mechanisms**, bounded
by static analysis and the stated operating assumptions. **Dimension conclusion:
no new actionable native ownership, longjmp, GC/reentrancy or process-guard defect
established at this baseline; fresh runtime safety acceptance is not implied.**
