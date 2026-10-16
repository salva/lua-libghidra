# Independent test-quality audit

Reviewer: fresh independent Astra session. Baseline: `4903eb7`. Audit only;
2026-10-16. The checked-out HEAD contained later audit documents; the baseline-to-HEAD
diff showed no package/test implementation changes.

## Assessment

The suite contains substantial real-native evidence, particularly for exact values,
ownership, first-slice semantics, iteration invalidation and bounded native failures.
It is not merely a mock suite. Three actionable gaps remain: conditional integration
execution, acknowledgement-only specialist/persistence assertions, and a weak Lua
leaf-function oracle. These are test/evidence defects, not demonstrations that the
corresponding production operations are broken.

Read AGENTS, SPEC, DESIGN, COVERAGE, PLAN and the audit index/subsystem map. Inspected
CMake registration, installed/package drivers, M2/M3/M4 Lua tests, native fixture
probes/seeding, and inventory/crosswalk claims. The coordinator's
[07-BASELINE-VALIDATION.md](07-BASELINE-VALIDATION.md#L3) records **18/18 configured
CTest passes**, not a clean build, installed qualification or complete full-tier run.
I did not rerun those builds or suites.

## Findings

### TQ-01 — Medium: the installed qualification entry point silently omits material cases outside a Saivage card

**Evidence.** [tests/installed-qualification.sh#L44](../../../../tests/installed-qualification.sh#L44)
conditionally runs the installed-document mutation checks; lines 51–56 gate M3/M4
persistence; lines 61–66 gate the only populated conditional-CFG fixture; lines
69–73 gate constructor/cache and runtime-absence checks. All depend on the presence
of `SAIVAGE_CARD_WORK_ROOT`, with no skip summary or explicit reduced-suite mode.
The script prints its owner/Session PASS message at line 48 before these blocks.
[cmake/Binding.cmake#L35](../../../../cmake/Binding.cmake#L35) through line 140 registers
the boundary/ownership and native-seeded core tests, but not the ordinary M2/M3/M4
installed suites. [tests/installed-absence.sh#L37](../../../../tests/installed-absence.sh#L37)
does run the full service and persistence scripts when explicitly invoked, but
does not include `m3_branch.lua`.

**Impact/status.** Static, high confidence: a normal developer can successfully run
CTest and `bash tests/installed-qualification.sh build` without exercising several
important regressions. This does not invalidate historical runs made with the card
environment set, nor does the narrowly worded line-48 message itself claim every
gate passed. The defect is the implicit, invisible difference in test selection.
The omitted conditional CFG case matters because
[tests/m3_iterators.lua#L49](../../../../tests/m3_iterators.lua#L49) explicitly permits
empty CFG edges in its ordinary fixture.

**Focused remedy.** Make the disposable work directory an explicit driver argument
(the card variable can remain a default), and either require it for this qualification
entry point or explicitly report a reduced suite and every omitted group. Retain the
existing scripts and assertions.

**One-level-up alternative / regression.** Add a named integration target that invokes
this same driver with explicit prefix/build/work inputs, separate from fast CTest.
Verify test selection with and without the card environment: the full invocation must
run persistence, conditional CFG and profiles/absence, and missing required inputs
must not silently select a smaller qualification. No new test framework is needed.

### TQ-02 — Medium: several full-tier mutation and loss-on-reload tests lack a positive precondition oracle

**Evidence.** [tests/m4_services.lua#L29](../../../../tests/m4_services.lua#L29) through
line 44 rename/retype/comment/delete members, retarget aliases, and edit enum members
mostly by checking `updated`/`deleted`. The member readback at lines 27–28 precedes
those edits. Parameter/local cases at
[tests/m4_services.lua#L45](../../../../tests/m4_services.lua#L45) check response fields,
but do not verify that the chosen local's new name/type is visible in a subsequent
read. In particular, `set_function_parameter_type(...,'int')` follows an already-int
signature, so that success case does not distinguish a no-op.

[tests/m4_persistence.lua#L20](../../../../tests/m4_persistence.lua#L20) through line 40
accepts mutation acknowledgements before saving; lines 47–62 assert disappearance or
reset after reopen. There is no pre-save readback of most edited categories. A lost
member comment or local rename can therefore satisfy the loss-on-reload assertion
even if it never became observable before save. Bytes are a good counterexample:
lines 39–42 verify the actual overlay, and benchmarks/comments have stronger
independent readbacks in [tests/m4_contract.lua#L45](../../../../tests/m4_contract.lua#L45)
through line 77. The criticism is limited to the weaker specialist cases.

**Impact/status.** Static, high confidence: these cases can miss wrong argument
forwarding, wrong-ordinal selection, no-op edits or missing response conversion
where the native response still reports success. The persistence test establishes
post-reopen absence plus acknowledged writes, not actual before/after loss for every
listed category. [docs/M4-FULL.md#L197](../../../M4-FULL.md#L197) accurately describes
the acknowledgement check, but its subsequent category-loss attribution is stronger
than that test alone establishes. No failing production mutation was observed here.

**Focused remedy.** Before deleting each edited object, read it back through the public
Lua API and assert the changed name/type/value/comment and identity; use a genuinely
different supported parameter type. In persistence tests, assert the targeted state
is observable immediately before save, then compare after reopen. Where upstream
does not expose or honor an edit, record the actual limitation and qualify only the
acknowledgement instead of inventing a state-change guarantee.

**One-level-up alternative / regression.** Organize the existing small specialist
blocks as create → read → edit → read → delete → absent sequences, reusing their
current real fixtures. A deliberately wrong member ordinal or dropped rename must
fail a content assertion before the persistence phase. This is a bounded strengthening
of existing positives, not a request for exhaustive mutation combinations or upstream
repair.

### TQ-03 — Medium: project leaf-function support is only checked for nonempty output through Lua

**Evidence.** [tests/m4_services.lua#L15](../../../../tests/m4_services.lua#L15) asserts
only `leaves and #leaves.functions > 0` for the project, versus `NOT_SUPPORTED` for
raw ELF. The full contract's leaf cases at
[tests/m4_contract.lua#L19](../../../../tests/m4_contract.lua#L19) and line 60 cover
unloaded/closed/invalid requests, not leaf identities or positive page selection.
The independent authored expectation already exists:
[tests/project_probe.cpp#L19](../../../../tests/project_probe.cpp#L19) checks exactly
`0x401106` and `0x40113c` in the selected range, excluding the caller `main`;
[tests/fixtures/README.md#L30](../../../../tests/fixtures/README.md#L30) records it.
That probe calls C++ directly and does not validate the Lua leaf adapter.

**Impact/status.** Static, high confidence: a Lua adapter returning an ordinary function
page, losing one leaf, or ignoring offset/range can retain a passing positive test.
The raw-ELF negative is valuable but cannot establish correct project results. The
fixture/native capability is already established, so no new analyzed project is
needed to close this wrapper-specific regression gap.

**Focused remedy.** Reuse the native probe's exact range and expected two UInt64
addresses in `m4_services.lua`; assert caller exclusion and offset 0/1/2 with limit 1.

**One-level-up alternative / regression.** Keep those three authored addresses in the
existing fixture manifest for shared positive expectations. Require the Lua test to
fail for an ordinary-function page or repeated first leaf. This is a targeted public
adapter oracle, not a Python comparison or broader leaf-analysis campaign.

## Coverage and evidence reconciliation

- **Strong first-slice positives:**
  [tests/m2_slice.lua#L22](../../../../tests/m2_slice.lua#L22) checks real completed,
  nonfallback results; lines 34–64 check ENDBR64, exact bytes, range sentinels, decode
  gaps and authored arithmetic on both surfaces. Lines 66–109 distinguish incomplete
  results, missing optionals, logical closure, retained metadata and stale iterators.
- **Iteration:** [tests/m3_iterators.lua#L22](../../../../tests/m3_iterators.lua#L22)
  compares repeated real scans at several page sizes. Lines 68–152 deliberately use
  synthetic page producers for caps, duplicates, errors, finalizer invalidation and
  integer-bound progress. That is appropriate isolation of the Lua iterator; it is
  not substituted for all native-order evidence. The populated branch test supplies
  the graph-order counterexample rather than silently enabling unsafe iterators.
- **Real setup, not mocked backend:**
  [tests/m3_seeded_host.cpp#L19](../../../../tests/m3_seeded_host.cpp#L19) seeds through
  real IClient methods. [tests/m3_seeded.lua#L35](../../../../tests/m3_seeded.lua#L35)
  explicitly disables seeding on reload, avoiding a false persistence pass. It does
  not establish public Lua writer correctness for the seeded operations.
- **Full negatives/batches:** `m4_contract.lua` checks all listed operation classes
  against unloaded/closed state and validation/generation behavior. Its mixed native
  decompilation batch checks both successful and incomplete records; service tests
  read back overlapping/NUL byte patches. No safe mid-patch native status-error path
  is demanded, and unsupported union/string discovery is not treated as populated
  success.
- **Inventories:** [scripts/check-tooling.lua#L14](../../../../scripts/check-tooling.lua#L14)
  preserves historical evidence provenance and requires generated positive slots to
  remain unqualified. [tests/tooling_coverage.lua#L21](../../../../tests/tooling_coverage.lua#L21)
  rejects missing reviews and fabricated evidence. These are useful source-accounting
  regressions, not execution of 70 public Lua behaviors. Keep that distinction.
- **Manual crosswalk precision:**
  [docs/FULL-CROSSWALK.md#L40](../../../FULL-CROSSWALK.md#L40) cites `m3_core`,
  `m3_persistence`, and `m4_persistence` for GetRevision, but none calls `get_revision`.
  There is other limited revision coverage in the native hosts, so this is not an
  assertion of zero tests. Also line 107 claims ignored enum width/**sign** coverage,
  while `m4_services.lua` tests resulting length, not returned signedness. Correct
  these citations/claims when addressing the specialist assertions; do not interpret
  a crosswalk row or a boolean type check as a semantic runtime oracle.

## Historical baggage / evolutionary bias

The suite evolved from milestone probes into a real integration suite; retaining
native reproducers, rejected assumptions and source-only ledgers is useful evidence,
not itself a defect. There is, however, evolutionary coupling to the card environment
in the main qualification driver, and some early “method returned success” checks
remain after full-tier qualification claims became broader. Fix selection visibility
and strengthen existing public readbacks rather than replacing the suite, generating
another ledger, adding approval gates, or expanding upstream fault qualification.

## Limitations and conclusion

Read-only local verification: `sha256sum -c tests/fixtures/SHA256SUMS` from the repository
root passed all 12 entries, including the real project database. An initial invocation
from the fixture subdirectory failed to resolve the manifest's root-relative paths;
the corrected invocation passed. This establishes retained-byte integrity, not fresh
fixture regeneration or independent execution of Ghidra semantics.

No isolated runtime probe was needed. No shared builds, installed suites, sanitizer
sweeps, upstream OOM tests, fixture/state writes or runtime-control operations were
performed by this reviewer. Historical process-log claims were inspected as documented
evidence, not freshly reproduced. Native safety, API implementation, build/license
correctness and documentation architecture are owned by the other audit dimensions.

**Conclusion:** substantial bounded native coverage exists, and the configured 18/18
result is credible within its stated scope. It does not close the integration-selection
or positive-oracle gaps above. Resolve these three focused test issues before treating
the existing full-tier evidence as a dependable routine regression suite.
