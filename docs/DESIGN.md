# Design

Proposed implementation of [SPEC.md](SPEC.md); no experiments are claimed passed.
Use a minimal C++20 adapter and small Lua facade. sol2 is provisional, contingent
on M1's C-built Lua longjmp audit; direct Lua C API is the fallback. No SWIG,
HTTP abstraction, Python bridge or record-object hierarchy.

## 1. Layers and ownership

`lua/libghidra/lowlevel.lua` exposes faithful envelopes;
`lua/libghidra/init.lua` supplies Session/open, direct reads, check and iterators.
Both call private `libghidra._native`. `src/client.*` owns a unique IClient,
generation and closed state. `src/convert/` contains explicit field converters;
`src/bindings/` groups operations. No borrowed storage, JSON/protobuf round-trip
or second conversion implementation. Handwritten adapters first; `api/coverage.*`
will track native operation, public mappings, field types, defaults, tier,
limitations and positive/negative evidence.

Userdata contains a live handle until GC. close and __close reset its unique
native owner but do not destroy the enclosing C++ handle; __gc destroys that
handle once, with a construction marker for partial publication. All aliases
share it. __close ignores its error argument and never raises, preserving an
unrelated active error. Explicit close_program is separately fallible.

A process guard rejects a second live client and serializes construction,
dispatch and destruction across Lua states. Do not hold a mutex across a Lua
allocation that can longjmp. Test client B after A closes, reversed state
teardown and repeated construction on different states. Audit selected-engine
initialization/destruction and global registries before any relaxation;
LocalClient's per-instance mutex proves no cross-client safety.

## 2. C-Lua error boundary

A protected trampoline alone does **not** protect destructors in jumped frames.
All frames between an allocating/raising Lua API and its protected boundary
must have only trivial automatic storage. No sol2 temporary, std::string,
container, lock guard, exception object or other live RAII owner may be skipped.

1. An outer native owner holds request/result/error storage. Raw Lua validation
   and marshalling run through protected C API trampolines using trivial locals
   and pointers to that owner. Owners are outside jumped frames, not merely
   in a trampoline's own C++ locals.
2. Native request construction and SDK dispatch use RAII in a phase with no
   allocating/raising Lua calls. Catch exceptions into owned error data;
   leave catch frames before Lua marshalling or raising.
3. Response/error conversion uses protected raw allocating API trampolines.
   After pcall returns, release native owners normally. Propagate a Lua runtime
   error only from an outer trivial frame after all RAII scopes have ended.
   Never call lua_error from a live RAII or catch frame.
4. Userdata publication reserves Lua storage and installs a GC-capable metatable
   before native ownership transfer; every failure edge has exactly one owner.
   Audit module initialization, metatable creation, request validation, nested
   responses, errors, UInt64 construction and finalizers, not just dispatch.

M1 records an all-frame audit and allocator-failure sweeps at each allocation
boundary using ordinary C-built Lua. Prove no leaks, double destruction or skipped
destructors under ASan/UBSan. If sol2 hides unsafe frames, use direct C API there
or throughout; never waive the gate based on pcall. check and iterator raising
live in Lua after native return.
Include protected-call setup/exit and allocation-triggered finalizer reentrancy
in the audit; recheck handle validity/closed state after any Lua-running phase
before native dispatch. Sanitizers supplement, not replace, the all-frame proof.

## 3. Pagination and generation

Apply SPEC compound integer validation to every paged adapter, including
ListInstructions' native limit+offset scan argument. Native paginate also casts
container size to int: qualification must establish supported collection sizes
below INT_MAX; this release does not support larger native collections.
pool_size=1 is mandatory: multi-engine CFG/block aggregation appends by completion
order, so repeated scans can duplicate/omit records across pages; state reload
also targets only slot 0. Per-page sorting cannot solve that problem.

Each iterator has a fixed extraction field, canonical identity and qualification
fixture. Compound keys use exact UInt64 hex and length-delimited text:

| Page family | Identity (native field meaning) |
| --- | --- |
| Functions, leaves | entry_address |
| Decompilations | function_entry_address |
| Instructions, data items | Address |
| Symbols | Address plus name (and namespace if returned) |
| Memory blocks | start_address plus name |
| Types, aliases, unions, enums | path_name (full native type path) |
| Type members | parent_type_path_name plus ordinal |
| Enum members | type_path_name plus ordinal |
| Basic blocks | function_entry, start_address, end_address |
| CFG edges | function_entry, src_block_start, dst_block_start, edge_kind |
| Xrefs | Source, destination and reference kind |
| Comments | Address and comment kind |

Resolve these semantic identities to exact model fields in the manifest before
enabling a family. If identity or stable serial order is insufficient, provide
pages only until qualified. Retain the previous page's ordered identities and
last ordering key, bounded by page size. Reject oversized pages, repeated pages,
duplicate identities within a page and non-advancing/overlapping order as
`PAGINATION_STALLED`; do not silently deduplicate. Verify native order (not
necessarily numeric) and define the comparator per operation in the manifest.
One offending page ends iteration: no unbounded retries/history set. Only for
families whose offsets count returned records, advance by actual count with
checked arithmetic and, without reliable continuation metadata, stop on an empty
page rather than a short page. Record cursor domain and post-pagination filtering
alongside identity/order in the manifest; these are separate qualification checks.
ListFunctionSignatures paginates candidate functions then omits absent signatures:
pages-only, no initial iterator. Empty filtered pages are not exhaustion and
returned count is not candidate progress. A future input-aware traversal requires
a separate design and missing-signature tests within/across pages.
ListDefinedStrings is a constant-empty native compatibility stub; omit its facade
iterator and populated/order gates. No implicit unbounded request in any family.

All calls share native dispatch classification (read/mutation/lifecycle).
Generation invalidation happens before mutating/lifecycle dispatch, including
native() calls; iterators check before buffered yields too. Test low-level
mutation during high-level iteration, close/reopen, failed partial mutations,
identical adjacent pages and serial repeated scans. No global page cache.

## 4. Local integration and persistence

Use public local factory and IClient. SPEC's matrix is normative for surface
behavior. Verify save/reopen separately for types, symbols, comments, signatures,
data, bytes and benchmarks; saved=true never means every category persisted.
DiscardProgram's true flag is a no-op acknowledgment, not rollback. Preserve
native flags. Ignored members cannot imply read-only/deadline guarantees.
Explicit architecture hints match in Lua, native and Python qualification runs.

## 5. Reproducible native build

Use CMake >=3.26 and C++20. Source builds **must** link
`libghidra::local_whole`, not just libghidra_local: registration-only architecture
objects otherwise disappear from archives. Installed packages export
`libghidra::local`; recreate a consumer whole-archive interface wrapper (CMake
LINK_LIBRARY:WHOLE_ARCHIVE) for the local archive and verify registration/link
closure. A release SDK with HTTP-only libraries is insufficient.

Local source configuration unconditionally runs `cmake/EmbedSpecs.cmake` and
`embed_specs.py`, even with Python bindings disabled. Require Python >=3.10
(evaluated union annotations) with importable Python zlib and an early CMake/
LuaRocks version/module check. Record interpreter version in the build lock.
Consuming a prebuilt local SDK need not run this generator. This build dependency
is distinct from Python's qualification-oracle role and the Python-free runtime.

M0 dependency lock records URLs, revisions, archive SHA-256, options and licenses
independently for:

- libghidra `d51ca813ae1b6b59519551a9be8c0b1ad74d862d`;
- Ghidra engine source `2035b8153afaf7ce2edde24a2c80b62bbcf5127f`;
- compiled Sleigh archive: pinned upstream CI uses
  `ghidra_12.1.3_PUBLIC_20260817.zip` from NSA Ghidra release `Ghidra_12.1.3_build`
  (not a verified artifact named `specs12.1.3`). Record its exact URL and SHA-256;
  engine compatibility remains **unqualified** here. Source lacks compiled .sla;
- protobuf exactly v29.3 (checked-in generated code requires 5029003), compatible
  Abseil, httplib v0.16.3, and a tested sol2 release if retained;
- Lua ABI, toolchain and all transitive libraries.

Provide source-directory/FetchContent source overrides for every fetched input
and a clean network-disabled build. Set PIC for every archive used by the module;
upstream Python-build PIC settings are insufficient. Initial Linux profile
explicitly requires BFD with pinned compatible binutils, not ambient optional
detection. Record actual BFD/libiberty/compression-library licenses and source
obligations; require PIC-capable archives or shared libraries, fail configuration
for unqualified system archives. Do not label BFD permissive. No-BFD profiles
are deferred pending separate loader qualification.

Qualify two distinct spec-loading profiles and prove the intended constructor
path was exercised:

- **External specs:** nonempty explicit `ghidra_root`, deterministic external
  specs; test valid, missing and unreadable roots. This constructor bypasses
  embedded extraction and does not require its HOME cache.
- **Embedded specs:** empty `ghidra_root`, compiled-in specs; isolated HOME with
  cold, warm and unwritable `$HOME/.ghidracpp/cache/sleigh`. Cold extraction needs
  a writable cache; record actual warm/unwritable behavior and diagnostics rather
  than inferring it from external-root success.

Both profiles remain qualification gates, including missing-spec diagnostics;
an explicit-root test cannot count as evidence for cache handling.

Compile against the selected Lua ABI without bundling another VM. Test dynamic
Lua hosts and statically embedded hosts exporting Lua symbols; inspect module
dependencies/symbol resolution to prove functions resolve to the host VM.
Test require from a fresh directory after CMake and LuaRocks staged installation.

## 6. Evidence sources

Paths refer to the SPEC pin in
[upstream](https://github.com/0xeb/libghidra/tree/d51ca813ae1b6b59519551a9be8c0b1ad74d862d):

- `cpp/include/libghidra/{api,models,local}.hpp`: public types/default stubs.
- `cpp/src/local_client.cpp`: paginate, ignored options/timeouts, operations,
  no-op discard, save/close and batches.
- `cpp/src/decompiler_pool.cpp`, `cpp/src/local_arch_adapter.cpp`: pool ordering,
  primary state, engine access and persistence.
- `cpp/CMakeLists.txt`, `cpp/bindings/CMakeLists.txt`: whole-archive linkage and
  dependencies; generated protobuf headers record 5029003.
- `LICENSE`: HOS terms, distinct from third-party licenses.

These are source evidence, not executed acceptance. M0/M1 must inspect selected
engine globals and exact archives in addition to this wrapper tree.
