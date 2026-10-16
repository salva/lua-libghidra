# M2 slice implementation evidence (pending independent review)

Original wrapper code MIT, Copyright 2026 Salvador Fandiño. Native dependency
pin/profile/attribution remain in native lockfiles and notices. No distribution
permission or upstream repair is implied.

Implemented function lookup/pages, instruction lookup/pages and decompilation
through the existing single owner dispatch, mutex, native exception containment
and protected detached-conversion primitive. Session unwraps optional records,
keeps third-result envelopes and preserves incomplete records. Function iteration
is lazy, checks shared generation before every yield, uses actual returned-count
offsets and rejects non-advancing address order and oversized pages. Upstream
ArchAdapter symbol-map address order and post-collection paginate define this
iterator's cursor domain; serial real fixture scans are compared to a full page.

The exact source field ledger remains `api/coverage.json` (native field types,
request defaults and ignored timeout). New converters preserve every field of
FunctionRecord, InstructionRecord, DecompilationRecord, DecompileLocalRecord and
DecompileTokenRecord. Addresses/sizes are UInt64, narrow counts/lengths/ordinals
are integers, known enums lowercase and unknown enums numeric. No field is
renamed or one-based except collection array positions. Optional absence omits
the key. Decompilation timeout is lowlevel-only and ignored by the native pin;
Session rejects any options key. Pages reuse M1 range/pagination validation,
including zero-end normalization before reversed-range validation.

## Safety and evidence

`src/slice_convert.hpp` contains borrowed-reference/scalar-only conversion frames
beneath the existing Packet pcall. Dispatch parsing adds only trivial Page and
integer locals; Packet owns responses outside the jumped frames, locks/catches
end before marshalling and Slot is revalidated after Lua-running parsing. No new
ownership transfer or Lua calls in native/locked frames. Boundary host now sweeps
new nested converters under persistent Lua refusal with same-VM retry, detached
false/zero/NUL, ordinal, uint64 max, fallback/diagnostic and unknown-enum checks.
This synthetic fallback is fidelity evidence, not a real backend fallback claim.

Commands: `cmake --build build -j4`, `ctest --test-dir build --output-on-failure`,
`bash tests/installed-qualification.sh`, `bash tests/wrapper-sanitize.sh`, and
`lua5.4 tests/m2_surface_reproducer.lua build/installed-qualification "$PWD"`.
Original surface reproducer is preserved unchanged from the accepted red node.
Both-surface real regression tests ELF/project completed nonfallback arithmetic,
known bytes/ENDBR64, pages/iteration, range sentinel/default/inclusive variants,
unmapped start, oversized reads, optional absence, native close/NO_PROGRAM,
owner status/slot retention, same-owner reopen/stale iterators and detached open
metadata. Installed example observes actual false has_entry_point and zero entry.
No Python/Java/network runtime or binding oracle is used.

## Findings and remaining gates (not acceptance waivers)

- Initial test incorrectly assumed eager ELF function discovery. Native
  GetFunction queries current symbols; ListFunctions enumerates them. Real
  initial ELF results are absent/empty, and explicit GetDecompilation materializes
  functions. Tests now assert this before warmup, then qualify real positives.
  No wrapper workaround or hidden second open was added.
- Extreme-address decompilation was initially unknown-origin; the direct native
  comparison below now attributes the reproduced crash to the upstream engine
  in the exercised profile/order. Original failures remain retained, not passed.
- Real incomplete diagnostics and decode-gap evidence now exist below. Local
  fallback=true is not produced by the pin. Successful nested-result natural
  reentry and independent review remain open; no full M2 acceptance is claimed.

## Remaining-gap qualification batch

### Direct native attribution (no dependency patch)

`tests/m2_native_diagnostics.cpp` is an isolated installed-SDK consumer, not a
passing-suite test. It repeats warmup, two read/page/decompile sequences and
GetFunction(UINT64_MAX), then GetDecompilation(UINT64_MAX,30000), on the authored
ELF with explicit x86:LE:64:default/gcc, embedded specs, pool_size=1 and the locked
patched SDK. Build via tests/installed-sdk. It **exits 139** without Lua or wrapper
code. A bounded GDB run locates SIGSEGV in `ghidra::FlowInfo::connectBasic`, via
`generateBlocks`, `Funcdata::followFlow`, native `decompile_perform`,
`ArchAdapter::decompileWithLocals`, `LocalClient::GetDecompilation`.
This establishes an upstream engine failure for this operation/profile/order;
it does not establish all inputs/orderings, nor a fix. The original Lua failure
and the zero-before-maximum incomplete-result capture are retained in card
status. No native engine repair, new dependency patch or signal interception is
attempted. Public extreme addresses still pass exact UInt64 validation: invalid
code addresses are not promised safe by this engine. A native SIGSEGV cannot be
converted by a C++ exception boundary. Normal supported-address wrapper tests
continue. No invented empty/success result or unsupported rejection is added.

### Real errors and decode gap

Installed both-surface ELF/project regression now asserts present incomplete
records for finite unmapped addresses 0x500000/0x600000: completed=false,
is_fallback=false, nonempty diagnostic and exact address; Session retains exact
third envelope. Distinct addresses avoid another observed native state effect:
repeating an unsuccessful decompile at the same address can return completed=true
on the next call (partial native function remains). Initial test expected both
calls to fail and failed; no wrapper cache or result normalization was added.

Native GetDecompilation at this pin constructs a default DecompilationRecord on
failure and assigns only address/completed/error; success assigns address,
pseudocode, locals and completed. Thus **real fallback=true is not produced by
this local implementation**, and function_name/prototype/tokens remain default.
The real error=false/nonfallback diagnostic is exercised; synthetic fallback=true
conversion remains required fidelity evidence, not real fallback availability.
This source limitation reconciles the original real-fallback expectation without
pretending a synthetic fixture is native success or expanding adapters.

Instruction gap evidence uses authored unaligned bytes at 0x40112b: two-byte
instruction followed by undecodable constructor at 0x40112d. ListInstructions
returns exactly one despite limit=8; known code at 0x401131 remains independently
readable. Tests also retain unmapped zero-start and known aligned ENDBR64 cases.
A failed hypothesis that the end of ELF .fini implied a gap was rejected: native
loader supplies zero padding and decoding continued with ADD. No replacement
scanner is introduced.

### New adapter wrapper boundary qualification

New requests use only checked address/Page/timeout scalars, so have **no new
allocating request copies**; existing OpenProgram request-copy sweep is retained.
`read_order_host` now runs all five adapters against a normally warmed real ELF,
sweeps persistent Lua allocation refusal during request/result publication, then
retries on the same owner. Actual refusal points are 8/12/5/12/11 respectively.
At a test-only no-Lua dispatch edge, bad_alloc, std::runtime_error and unknown
exceptions are injected for each adapter; structured NATIVE_EXCEPTION/binding
and normal restored retries are checked. No dependency-internal allocation sweep
is performed. Packet ownership and catch/lock destruction precede Lua conversion
on these paths as before. The observer is compile-guarded and absent in production.

`reentry_host` now exercises all five adapters at pre-dispatch real finalizer
close/reconstruct and requires CLOSED. It also observes naturally allocation-
triggered finalizers during each unloaded native error's conversion, requiring
NO_PROGRAM to remain detached after the source owner closes/reconstructs.
Successful nested conversion refusal is real-backend coverage; synthetic nested
fixture covers values not emitted by this local producer. Successful-result
allocation-triggered reentry for the new nested adapter results is still a
qualification gap; existing status/capabilities reentry alone does not fill it.

An initial sanitizer run found a **test allocator mismatch**, not ignored as an
upstream OOM: dependency MapState uses nothrow new, intercepted by ASan, while this
host replaced ordinary delete with header-based freeing. Added matching nothrow
new/delete overloads using the host's same header allocator. Preserve the failed
capture in card status; ordinary green runs alone did not expose it.
