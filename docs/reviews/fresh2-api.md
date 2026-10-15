# Fresh independent review: Lua API correctness and ergonomics

Reviewed HEAD `7cc4caa97d4fcca3f2f0ffaba9bb6d005e2ffa70` against upstream
`d51ca813ae1b6b59519551a9be8c0b1ad74d862d` (checkout verified). Read AGENTS,
README, SPEC, DESIGN, PLAN, COVERAGE and EXAMPLES before assessing; no review
history consulted. Scope: local-only Lua API, numeric/error boundaries,
pagination and lifecycle. No implementation or runtime qualification claimed.

## Required documentation fixes

### API-1 — Bound ReadBytes by its actual signed downstream length

**Evidence:** SPEC:87 promises a checked uint32 size for `read_bytes`, which
admits values through 4,294,967,295. Upstream
`cpp/src/local_client.cpp:1165–1174` forwards that uint32 to
`cpp/src/local_arch_adapter.cpp:502–514`, which first resizes a vector to that
length and then passes `static_cast<int4>(length)` to `loader->loadFill`.
Values above signed 32-bit maximum cannot retain their positive length at this
boundary. Checking only the public uint32 type does not protect the actual call.

**Required fix:** Specify an initial binding restriction of
`0 <= size <= INT32_MAX` on both surfaces, rejecting larger values before native
dispatch/allocation with a structured binding argument error. Record the public
uint32 type and narrower downstream restriction separately in the manifest.
Add boundary qualification for rejection at INT32_MAX+1 and UINT32_MAX without
allocating their requested buffers; acceptance at the upper type boundary need
not require a multi-gigabyte successful read. This is a necessary boundary
restriction, not a preference for an arbitrary memory quota.

### API-2 — Document the zero range-end sentinel

**Evidence:** SPEC:94–108 describes native inclusive ranges and SPEC:105 requires
preserving zero, but never states that an explicitly supplied zero upper bound
is special. Upstream `cpp/src/local_arch_adapter.cpp:41–49` normalizes
`range_end == 0` to UINT64_MAX; `listFunctions` uses it at :192 and
`listInstructions` at :551. Thus `{range_start=0, range_end=0}` requests all
function addresses, not the inclusive singleton range at address zero. A
positive start with end zero likewise does not represent an empty reversed range.

**Required fix:** State this native sentinel explicitly for the first-slice page
calls on both surfaces, including that these native range requests cannot express
an upper bound of literal address zero. Preserve the sentinel rather than silently
changing low-level behavior. Record per-operation applicability in the manifest
and test explicit zero separately from omitted/default and ordinary inclusive
bounds. The ordinary inclusive-bound statement alone is materially incomplete.

## Sound contracts and intentionally pending work

- Exact UInt64 outputs, integer-only numeric inputs, checked named arithmetic,
  Lua equality/table-key caveats and zero-based record ordinals are coherent.
- `check` tests presence, preserves the third response and does not mistake false
  outcome flags or incomplete decompilation for transport failures. The proposed
  first-slice example follows its tuple and to-be-closed-variable conventions.
- Shared ownership, alias closure, non-saving finalization, process-wide client
  restriction and pre-dispatch iterator invalidation are explicit. Longjmp and
  reentrancy safety are correctly pending M1 evidence, not claimed results.
- Compound page arithmetic, returned-count advancement, signature candidate
  pagination and defined-string stub limitations are substantively addressed.
  Exact family comparators, manifests and positive runtime cases are deliberate
  pre-shipment gates; their current absence is not a documentation defect.
- No API redesign, additional facade methods, instruction iterator, or SWIG/HTTP
  expansion is requested. Preferences are not blockers.

VERDICT: CHANGES_REQUESTED
