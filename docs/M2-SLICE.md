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
- A diagnostic experiment decompiling UINT64_MAX after normal reads first
  returned an incomplete error-bearing record (`Unable to load 512 bytes at
  r0x000001f0`), then another process attempt **segfaulted**. Origin is unresolved;
  not automatically labelled upstream. The mandatory green regression does not
  claim that input safe. Preserve experiment and captures in card status; bounded
  direct-native attribution/affected-path investigation remains required before
  final M2 qualification. No dependency repair authorized.
- Actual backend fallback, decode-gap beyond unmapped-start, broader adapter
  allocation/reentry/exception-path qualification and independent review remain
  open. M1 unchanged-path evidence is reused, not an M1 recampaign. Lua tooling
  migration, LuaRocks/release/distribution and M3 remain outside this repair batch.
