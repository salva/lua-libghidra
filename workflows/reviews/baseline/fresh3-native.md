# Fresh independent native-boundary review

Reviewed project HEAD `31cb7ee846f6cea4b583e1a4f633c4a46b71d6bd` and local upstream
`d51ca813ae1b6b59519551a9be8c0b1ad74d862d`. Read AGENTS, README, SPEC, DESIGN,
PLAN, COVERAGE and EXAMPLES without consulting earlier reviews. Scope: C++/Lua
ownership, lifetime, longjmp, concurrency, ABI and provisional sol2 use.

## Findings

No necessary concrete documentation defects found in this dimension. No fixes
requested.

## Evidence

- **Ownership and closure:** SPEC §§2/4 and DESIGN §1 distinguish shared aliases,
  detached responses, logical program closure and native-owner destruction.
  Upstream `local.hpp:36–38` returns `unique_ptr<IClient>`;
  `local_client.cpp:1670–1689` resets adapters and the loaded flag rather than
  destroying the pool. `decompiler_pool.cpp:102–106` confirms adapter-only reset.
  EXAMPLES exercises alias closure, reopening and retained open metadata.
- **Concurrency and engine lifetime:** SPEC §1 and DESIGN §1 require one live
  client process-wide, serialized construction/dispatch/destruction and sequential
  lifecycle qualification. This matches the risk visible in
  `engine/ghidra_decompiler.cpp:189–212`: constructors start the global library and
  destruction shuts it down. `local_client.cpp:1718–1730` only establishes an
  instance-local request mutex. The documents do not misrepresent that mutex as
  sufficient cross-client protection.
- **C-built Lua / sol2:** DESIGN §2 explicitly forbids skipped RAII in every
  jumped frame, separates native work from protected Lua conversion, releases
  owners before rethrowing Lua errors, covers partial userdata publication and
  finalizer reentrancy, and makes sol2 conditional on the audit. PLAN M1 retains
  allocator-failure and sanitizer gates rather than claiming pcall alone suffices.
- **Boundary and ABI:** SPEC §3 requires exact uint64 conversion and detached
  binary strings. The ReadBytes bound matches
  `local_arch_adapter.cpp:502–511`, where a uint32 length becomes signed int4
  after vector allocation. DESIGN §5 records toolchain/Lua dependencies, requires
  PIC and whole-archive registration, and tests symbol resolution against the
  existing dynamic or statically embedded Lua VM rather than bundling a second VM.
- **Qualification status:** README and PLAN explicitly leave implementation and
  runtime qualification pending. Unexecuted ownership, global-lifecycle and sol2
  experiments are defined gates, not documentation defects or evidence of success.
  Local-only scope and the SWIG prohibition are consistent throughout.

VERDICT: APPROVED
