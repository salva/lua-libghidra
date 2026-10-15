# Fresh independent review 2 — native C++ / Lua boundary

Reviewed HEAD `7cc4caa97d4fcca3f2f0ffaba9bb6d005e2ffa70` against local upstream
`/home/salva/g/ml/tmp/lua-libghidra-upstream` at
`d51ca813ae1b6b59519551a9be8c0b1ad74d862d`.

Read AGENTS.md, README.md, SPEC, DESIGN, PLAN, COVERAGE and EXAMPLES before
forming this assessment. No previous review reports were read. Scope: native
ownership, Lua longjmp, concurrency, provisional sol2 and ABI integration.

## Findings and evidence

No substantive documentation defect requiring correction was identified in this
dimension. This approves the proposed design and its gates, not an implementation.

- **Ownership:** upstream `cpp/include/libghidra/local.hpp:36–38` returns
  `std::unique_ptr<IClient>`; `cpp/src/local_client.cpp:48–53,1707–1708` owns its
  pool and has a default destructor. DESIGN §1 distinguishes closing that native
  owner from destroying its enclosing handle, shares aliases and requires a
  partial-publication marker. SPEC §4 and EXAMPLES explicitly preserve detached
  records and leave surviving aliases closed. There is no borrowed native-record
  lifetime promise or destructor-save promise.
- **C-built Lua longjmp:** DESIGN §2 correctly rejects pcall alone as a C++
  unwinding solution. It places owning storage outside jumped frames, isolates
  native RAII/exception handling from allocating Lua calls, and delays lua_error
  until RAII and catch scopes have ended. Publication, call setup/exit, error
  conversion and allocation-triggered finalizers are explicitly in the audit.
  The post-Lua-phase validity recheck addresses reentrant close before dispatch.
  M1 requires both an all-frame proof and allocator-failure sweeps; sanitizer
  success is not substituted for that proof.
- **Concurrency:** upstream `cpp/src/local_client.cpp:1718–1730` documents only
  an instance request mutex. `cpp/src/decompiler_pool.hpp:104–110` identifies
  primary access outside the pool availability latch. The stricter SPEC §1 /
  DESIGN §1 process-wide single-client guard and serialization are justified;
  they do not infer engine-global safety from the native instance mutex.
  DESIGN forbids holding that guard across allocating Lua calls and requires
  cross-state teardown and sequential reconstruction tests. Engine-global
  initialization/destruction remains an explicit qualification gate.
- **Pool and native ownership:** `cpp/src/decompiler_pool.cpp:51–65,87–112`
  constructs owned engines, reloads state into slot zero and rebuilds borrowed
  architecture adapters. The documented pool_size=1 restriction and detached
  conversion boundary avoid exposing these internal pointers to Lua. The
  native pool's exception-safe slot release at lines 218–230 is useful source
  evidence, not proof that the Lua adapter is safe.
- **sol2 and ABI:** DESIGN §§2,5 and PLAN M1 make sol2 conditional on the actual
  C-built Lua audit, with direct C API fallback. Lua 5.4/64-bit integer ABI,
  toolchain/dependency identities, host symbol resolution and shared/static
  embedded-host qualification are recorded requirements. Upstream
  `cpp/CMakeLists.txt:387–397` supplies the whole-archive interface and C++20
  requirement; DESIGN distinguishes that source target from installed SDK
  linkage and requires PIC throughout. No alternate Lua VM or prequalified
  arbitrary SDK binary compatibility is promised.

## Fixes and remaining gates

No product-document changes were necessary; only this review report was added.
No binding, build or runtime experiment was performed. M0 dependency/license/
engine readiness and M1 ownership, reentrancy, allocator-failure, actual sol2
selection, sequential engine lifecycle and host-ABI tests remain unpassed.
Those are appropriately blocking future qualification requirements, not missing
evidence being treated as success by this review.

VERDICT: APPROVED
