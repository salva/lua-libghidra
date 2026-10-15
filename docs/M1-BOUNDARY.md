# M1 value/build foundation (not M1 qualification)

Original implementation MIT, Copyright 2026 Salvador Fandiño. Dependencies keep
their notices in `docs/evidence/native-notices`; no publication authorized.

## Build and run

```sh
cmake -S . -B build -G Ninja -DLIBGHIDRA_USE_SDK=ON \
  -DCMAKE_PREFIX_PATH="$PWD/.cache/native-sdk-patched"
cmake --build build -j4
ctest --test-dir build --output-on-failure
cmake --install build --prefix /caller/staging/prefix
```

Default source mode retains the native readiness recipe; select
`-DNATIVE_INPUT_ROOT=.../native-inputs-patched` for the approved profile. Source
mode uses `local_whole`; SDK mode explicitly finds exact Protobuf CONFIG and
wraps installed local in WHOLE_ARCHIVE. Both inherit global PIC. The module has
unresolved host Lua symbols intentionally: do not add liblua to its link line.
Lua source/native install directories are configurable; defaults follow 5.4.
`tests/embedded.c` loads the same module from C-built shared and static/exported
VMs. `m1-vm-symbols.log` records no liblua NEEDED on the module, undefined Lua
API symbols, static host without liblua, shared host with one liblua.

## Reusable primitive contract and all-frame audit

Direct C API, not sol2. `src/boundary.hpp` is the shared interface for subsequent
owner/operation work. `read_u64`, `read_size`, `read_page` are raw validation;
`value`, `field`, `push_u64`, `error` are marshalling. These may allocate/raise;
**never call them with live native RAII in the jumped frame**. They must run in
a protected trivial thunk, borrowing storage owned by the caller of pcall.
`read_page` checks unknown keys including non-string/NUL-suffixed keys without
metamethods; applies the zero-end sentinel before inclusive range comparison;
checks offset <= INT_MAX-limit without overflowing. `read_size` accepts integer
0..INT32_MAX only and does not dispatch or allocate a requested buffer. Private
validator exports exist for tests, not operation adapters or support claims.

`protected_convert` pushes only a zero-upvalue C function and lightuserdata, then
pcall. Reserve stack **before** constructing native owners. Lua 5.4's zero-upvalue
C function/lightuserdata push does not allocate; sufficient stack capacity is a
precondition. The caller destroys owners after pcall returns, then raises from
a trivial frame if needed. `tests/boundary_host.cpp::detached` demonstrates this
protocol. Never put RAII in a thunk, lock across Lua execution, or raise inside a
C++ catch. Future SDK work must catch native exceptions in a no-Lua phase, then
marshal after leaving catch scopes; revalidate owner state after Lua-running
phases because finalizers can reenter.

Current module entry, metatable initialization, helper/error construction,
validation, UInt64 publication and all called helper frames have only pointers,
scalars, trivial Page/U64, char arrays and references. There are no std::string,
container, exception or lock automatic owners on those call chains. Header
converters borrow const references and recurse with trivial index locals.
`U64` is trivial and owns no resource: allocation before metatable attachment is
safe on OOM, needs no GC destructor; immutable public access, protected metatable,
no arithmetic metamethods. Failed initialization can leave a partial registry
metatable; require retry fills every member again, never transfers native owners.
Comparisons raise structured errors only from trivial frames. Named helpers
return nil/error. Equality preserves ordinary Lua unrelated-type dispatch.
The module entry relies on require/caller protection, as normal Lua C modules;
embedding hosts must call require through pcall, not unprotected C API calls.

Owned detached conversion tests cover false, zero, NUL, nested optionals, absent
fields, dense arrays, exact uint64 and signed/narrow fields. Owners are destroyed
before inspecting returned Lua values; results retain no native pointers. The
persistent allocation-failure sweep uses ordinary system C-built Lua and denies
all allocations from each selected point onward (including Lua's retry), checks
normal native owner destruction and allocator byte balance on state close. It
covers initialization, publication, errors, validators and nested output.
ASan/UBSan test covers the original C++ boundary/owner test, not instrumented Lua
or the full native dependency closure. No broad/native adapters shipped.

## Remaining gates

Both public modules currently export only shared u64/check; no local_client/open
claim. Following owner work must add process serialization/slot, shared aliases,
close/__close/__gc, publication marker, cross-state reuse, native exception and
reentrant-finalizer tests, ownership OOM sweeps and full sanitizer qualification.
Repeat all-frame audit for every new path. Full M1, M2 engine reads/examples,
LuaRocks installation, release tooling migration/generator exception approval,
packaging/notices/distribution and all-architecture support remain unqualified.

Fault sweeps also retry the entire initialization/conversion script in the same
state after restoring allocations, demonstrating recovery from partial module
publication, not just successful cleanup at state close. Persistent denial is
stronger than one-shot failure for Lua's retry path but does not replace tests
of arbitrary finalizer reentrancy or native-owner publication in the next slice.

The native observer directly calls `read_size` around Lua allocator counters at
INT32_MAX acceptance and UINT32_MAX rejection. Both make zero Lua allocation
calls; the primitive has no native allocation or SDK reference. Lua regression
also covers 0/INT32_MAX/INT32_MAX+1/UINT32_MAX. Once operations exist, their caller
must demonstrate this same check precedes dispatch/request-buffer allocation;
these foundation tests do not assert an unimplemented read operation is safe.

## Expanded UInt64 comparison/helper regression matrix

`tests/boundary.lua` now checks all pairwise ==, <, <=, > and >= outcomes over
the eight exact decimal boundary values (0, 2^53-1/2^53/2^53+1,
2^63-1/2^63/2^63+1, UINT64_MAX). Both operand orders against wrong-type
boolean/integer/float/string/table/function values must raise structured
INVALID_ARGUMENT/binding errors with the specific __lt or __le operation;
unrelated equality must remain false. Nil ordered operands, immutability's
structured __newindex error and the protected metatable are checked separately.

All five named helpers reject invalid receivers via nil/error (not raise),
including nil; add/sub also reject negative/noninteger/absent deltas. Exact
nonzero carry/borrow across signed max, maximum legal Lua-integer delta,
unsigned upper edge, and checked to_integer above signed max are asserted.
These strengthen the original pcall-only comparison coverage and zero-only
arithmetic success cases. They do not substitute for native ownership fault,
reentry, operation dispatch observer or full sanitizer/build qualification.
The same script runs in standalone Lua and static/shared existing-VM hosts.
