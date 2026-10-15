# Fresh independent review — native C++ / Lua safety

Reviewed documentation HEAD: `699cc8a1efa534cc15f100a487f7afab50215cb1`.
Verified upstream checkout: `d51ca813ae1b6b59519551a9be8c0b1ad74d862d`.

Read project AGENTS, README, SPEC, DESIGN, PLAN and COVERAGE before forming this
assessment. No prior reviews or review index were read. Scope: native ownership,
Lua longjmp boundaries, lifecycle, concurrency, sol2 suitability and ABI/build
integration. This is document approval, not implementation or runtime approval.

## Findings requiring corrections

None. No blocking or nonblocking documentation defect identified in this scope.
No product-document changes requested.

## Assessment and evidence

- **Longjmp:** DESIGN:34–59 correctly distinguishes a protected call from C++
  destructor safety. Request/result owners live outside jumped frames; native
  dispatch and exception handling are separated from allocating Lua operations;
  error propagation follows RAII cleanup. Publication, module initialization,
  conversions and finalizers are explicitly in the audit scope. This is a viable
  architecture constraint, not a claim that an arbitrary sol2 wrapper is safe.
- **Ownership and closure:** SPEC:27–36,114–121 and DESIGN:19–23 consistently
  require a shared owning handle, detached records, idempotent owner reset and
  exactly-once enclosing-handle destruction. Closing one alias invalidates the
  others; `__close` does not destroy storage still needed by aliases or `__gc`.
  The upstream factory returns `std::unique_ptr<IClient>`
  (`cpp/include/libghidra/local.hpp:36–38`), consistent with the proposed owner.
- **Concurrency and native lifecycle:** SPEC:17–23 and DESIGN:25–30 impose a
  single live client, pool size one and process serialization, without confusing
  these restrictions with proof of engine safety. This caution is justified:
  `cpp/src/engine/ghidra_decompiler.cpp:189–212` calls library initialization in
  each constructor and shutdown in each destructor;
  `cpp/src/decompiler_pool.cpp:51–65` constructs an engine per slot. Native
  per-client locking (`cpp/src/local_client.cpp:57–59`, for example) is not a
  process-global protection mechanism. Sequential reconstruction and independent
  Lua-state teardown are appropriately explicit M1 gates.
- **sol2:** README:16, DESIGN:4–6,55–59 and PLAN:29–38 keep its selection
  provisional. The all-frame audit against C-built Lua is the right acceptance
  criterion; a direct-C-API fallback retains the same safety obligations. Neither
  sol2 availability nor exception translation alone is treated as evidence.
- **ABI and linkage:** SPEC:11–13,71–77,174–175 and DESIGN:117–152 identify the
  baseline integer model, field-level conversion manifest, dependency/toolchain
  lock, PIC, host-VM symbol resolution and standalone/shared/static embedding
  qualification. Upstream `cpp/CMakeLists.txt:323,387–390` confirms the installed
  `local` export versus source-tree whole-archive interface distinction. The
  documents do not promise arbitrary installed C++ SDK binary compatibility.
- **Scope:** Both surfaces use one native dispatch/conversion path. No HTTP,
  SWIG, runtime Python bridge or borrowed record storage is introduced.

## Future gated experiments — not current documentation defects

M0/M1 must still establish engine-global initialization/reinitialization safety,
failure recovery and actual linked dependency compatibility. M1's all-frame
audit must include protected-call setup and exit, allocation-triggered finalizer
reentrancy, exception-to-error conversion and partially published userdata;
sanitizer success alone cannot prove absence of skipped C++ destructors. Actual
implementation must preserve handle validity and recheck closed state before
native dispatch after any Lua-running phase. These are concrete applications
of the documented ownership/error-boundary gates, not claims of observed bugs.

The real C-built Lua allocator-failure sweeps, cross-state lifecycle tests,
host-VM resolution checks and real-engine qualification remain unexecuted in
this review. DESIGN:3 and PLAN:3 accurately state that no milestone has passed;
approval here does not waive any of those experiments or authorize implementation.

VERDICT: APPROVED
