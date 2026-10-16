# Fresh independent review: upstream semantics

Reviewed target HEAD `7cc4caa97d4fcca3f2f0ffaba9bb6d005e2ffa70` against local upstream
`d51ca813ae1b6b59519551a9be8c0b1ad74d862d`. Read AGENTS, README, SPEC, DESIGN,
PLAN, COVERAGE and EXAMPLES before assessment; no review-history files read.
Scope: native local semantics, coverage, options, persistence and compatibility.
Source inspection only; no runtime qualification is claimed.

## Required fixes

### U1 — Bound byte reads by the downstream signed length (high)

SPEC:87 accepts a checked uint32 size, and SPEC:112 generally permits the full
range of narrower native integral fields. However,
`cpp/src/local_arch_adapter.cpp:502–515` allocates `length` bytes and passes
`static_cast<int4>(length)` to `loadFill`. Values above INT32_MAX therefore do
not retain their requested positive length at the loader boundary. Checking only
the public uint32 signature does not establish a safe supported request domain.

**Fix now:** restrict `read_bytes` on both surfaces to at most INT32_MAX (or a
smaller explicit binding resource limit), before allocation/dispatch; record this
as a binding restriction motivated by the pinned implementation. Add boundary
rejection to M1/M2 acceptance. This requires a contract correction now, not an
experiment allocating multi-gigabyte buffers later.

### U2 — Document zero-end range sentinel and linear instruction scanning (medium)

SPEC:94–108 describes inclusive ranges without their native zero exception.
`cpp/src/local_arch_adapter.cpp:41–50` normalizes `range_end == 0` to UINT64_MAX;
functions, symbols, instructions, comments and data-item queries use it. Thus
`range_start=0, range_end=0` does not mean only address zero. Moreover,
`:547–577` starts instruction decoding exactly at range_start and stops on the
first undecodable address; it does not enumerate mapped executable regions.
The documented zero start can consequently return an empty instruction page on
a loaded program with instructions elsewhere. The current finite-zero-limit
caveat addresses a different issue.

**Fix now:** state the zero-end sentinel explicitly, including its effect on
zero-address-only queries; document ListInstructions as a contiguous linear
sweep requiring a suitable start, with empty output not proving absence of
instructions elsewhere. Include zero-end and unmapped-start/gap cases in the
qualification plan. Preserve native behavior rather than silently replacing it.

### U3 — Distinguish logical program close from engine unloading (medium)

SPEC:169 calls native CloseProgram(discard) an unload, repeated in EXAMPLES:56.
`cpp/src/local_client.cpp:1670–1689` only resets adapters, marks the program
closed and clears benchmark records. `cpp/src/decompiler_pool.cpp:102–105`
destroys adapters, not the slot-owned Decompiler or its loaded architecture.
The client/engine owner remains alive. The source supports logical closure and
subsequent NO_PROGRAM behavior, not a claim that loaded engine resources are
released by this call.

**Fix now:** describe logical program-context closure/access invalidation;
explicitly distinguish it from binding `close()` releasing the native owner.
Remove the unqualified unload wording. Preserve the existing no-rollback and
no-autosave caveats.

## Confirmed strengths

- COVERAGE accounts for the LocalClient overrides and excludes inherited
  NOT_SUPPORTED defaults, including DeleteTypeEnum, GetPcode and operands.
- Ignored read_only/project_name/timeouts and mutation fields match local_client.cpp;
  coarse capabilities and the constant-empty defined-string operation are qualified.
- Candidate pagination before signature filtering is accurately documented.
- Persistence caveats match save/loadState: slot-zero best-effort reload, selective
  types/symbols restoration, no-op discard, and empty-state-path close/save distinction.
- Python auto-detection is correctly treated as a separate facade behavior;
  no HTTP, SWIG or executed compatibility result is implied.

VERDICT: CHANGES_REQUESTED

## Re-review — 6b9dc5e

Re-reviewed `6b9dc5e23b3120cf190065c895d36fc263320b38`, examining all product-document
changes since the reviewed baseline for upstream-semantic regressions. Rechecked
the pinned local source; this remains documentation/source review, not runtime
qualification. The original findings and verdict above are preserved as history.

- **U1 resolved:** SPEC now restricts both ReadBytes surfaces to 0..INT32_MAX
  before dispatch/requested-buffer allocation. DESIGN, COVERAGE and PLAN record
  the downstream restriction and boundary checks without requiring enormous
  successful reads. This matches `local_arch_adapter.cpp:502–515`.
- **U2 resolved:** SPEC documents zero-end normalization, positive-start/zero-end
  behavior and the inability to express a zero-only upper bound. Linear decoding
  and first-gap termination are explicit; the example supplies a known code
  start. DESIGN/COVERAGE/PLAN carry the corresponding semantics and checks.
  This matches `local_arch_adapter.cpp:41–50,547–577`.
- **U3 resolved:** SPEC and EXAMPLES now distinguish logical program closure from
  native-owner release. Shared-view NO_PROGRAM behavior, retained engines,
  owner-level status, reopen and historical metadata are consistent with
  `local_client.cpp:57–89,93–156,199–214,1657–1689` and
  `decompiler_pool.cpp:67–84,102–112`. The process-slot and generation rules are
  appropriately binding policy, not assertions of upstream behavior.

No new upstream-semantic regression found in the changed specification, design,
coverage, plan or examples. All three requested document corrections are present
now; their implementation tests remain future qualification gates, not deferred
documentation fixes.

VERDICT: APPROVED
