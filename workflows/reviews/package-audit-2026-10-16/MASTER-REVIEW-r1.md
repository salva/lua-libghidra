# Master implementation contract — independent review r1

2026-10-16. Fresh independent Astra MASTER REVIEWER; not a component author or
previous reviewer. Reviewed checkout HEAD
`3ce2be4712ff5dab312bc4e79a6281eebae314f6`; initial worktree was clean.
Production baseline named by the plans is `4903eb7`.

## Verdicts and required changes

| Document | Verdict | Required changes |
| --- | --- | --- |
| `docs/development/plans/package-fixes-2026-10-16/99-MASTER-PLAN.md` | APPROVED | None |
| `docs/development/plans/package-fixes-2026-10-16/98-SAIVAGE-HANDOFF.md` | APPROVED | None |

No unresolved blocking cross-contract contradiction or missing planning gate was
established. This is approval of the implementation specification, not a claim
that its prospective checks have passed. Component approvals were read as review
history and independently checked against the contracts and selected source.

## Whole-plan findings

### 1. Coverage, scope and sequencing are complete

Master §2 accounts for F01–F14 individually, including importance,
transversality, selected correction, rejected alternative and batch. A owns
F01–F03; B owns F04–F07/F11–F13; C owns F08–F10; D owns F14 and its F13 application.
Neither the operator's documentation condition nor website feature is disguised
as a newly reproduced native defect.

The six-batch sequence is executable: A fixes policy/build selection; C establishes
focused state/oracle and selection work; B fixes generated facts/notices, then
authors the manual; B/C jointly land the document integration; D consumes the
accepted content. Master §3 explicitly limits batch 2 acceptance and stages the
new document callers until batch 5. The missing-manifest negative preflight case
does not require pretending the future positive interface already exists.
F08 cannot close before the integrated full/reduced runs.

Shared edits have exclusive ownership and order, especially Binding.cmake A → C
→ B, C-owned orchestration, B-owned checker/probes/manual, and D → B → D helper
compatibility. This avoids both unavailable-signature commits and concurrent
manual/test rewrites. A's standalone ABI/configure tests remain mandatory siblings
of C integration; no nonexistent mismatch-host flag is assumed.

### 2. A's facade and host boundaries remain intact

Actual `lua/libghidra/init.lua:8–24,99–114` corroborates the reopen forwarding
and shutdown/save-policy gaps. A's shared six-key raw validator rejects ignored
keys by presence, including false/empty values, without duplicating native value
parsing. Factory publication/failure cleanup stays distinct from existing-owner
reopen. Invalid-key versus CLOSED precedence is specified rather than flattened.

`src/owner.cpp:140–143,168–173,387–399` corroborates state-path precedence,
distinct closed/accepted envelopes and raw policy parsing. Logical close does
not become owner release, validation does not become dispatched mutation, and
save acceptance does not become a persistence guarantee. B receives these exact
current-contract corrections rather than removing methods to fit old prose.

`src/boundary.cpp:185–204` currently publishes metatables without the proposed
first-call ABI check. Binding.cmake currently uses ambient headers and an
unkeyed limited profile check; LuaRocks does not yet forward host/header inputs.
The plan correctly treats the probe, selection arguments and regression files
as future work. It specifies actual include-directory discovery, separately
identified embedded system libraries, a pinned ordinary nondefault 5.4.6 host,
and an isolated int64/float32 fixture with concrete provisioning commands.
Both probe and production entry must produce the precise protected numeric
diagnostic before publication and leave the host usable. Missing symbols are
not passes. The amd64/signature caveat prevents a universal custom-ABI claim.

### 3. C supplies meaningful evidence, not acknowledgement counts

The current `tests/installed-qualification.sh:43–73` has ambient selection;
profiles hard-code a spec tree and absence hard-codes embedded build paths.
C's explicit full/reduced arguments, prerequisite failures, unique retained work
and thin opt-in target address those concrete owners. The master does not equate
CTest, reduced selection, full integration or release acceptance.

Inspection of `tests/m4_services.lua` and `m4_persistence.lua` confirms the weak
acknowledgements, int-to-int parameter change and insufficient pre-save states.
The selected immediate identity-keyed readbacks, detached snapshots, different
parameter type and fixed reload expectations remedy that without allowing
either outcome to pass. Unobservable native writes require bounded attribution
and narrower claims; unexplained wrapper mismatches remain failures. True-local
coverage cannot be manufactured from parameter-kind records.

`tests/project_probe.cpp:19–23` supplies the authored two-leaf oracle. C carries
it through Lua with exact order/count, caller exclusion, offsets 0/1/2 and
independent range checks, retaining raw-ELF NOT_SUPPORTED. Disposable sensitivity
mutants exercise actual false-positive risks without production mutation hooks.

### 4. B/C document interfaces agree throughout

The master, assignment and B/C bodies all specify:

```text
BUILD/package-documents.txt
lua5.4 tests/installed_documents.lua source SOURCE_ROOT MANIFEST
lua5.4 tests/installed_documents.lua installed DOCUMENT_ROOT SOURCE_ROOT MANIFEST
bash tests/installed-documents.sh DOCUMENT_ROOT SOURCE_ROOT MANIFEST FRESH_WORK
```

The export is a mechanical projection of the sole CMake list. DOCUMENT_ROOT is
the actual documentation directory; FRESH_WORK must not exist. Source and
installed pristine checks run in both modes; mutation probes are full-only in C.
Each of the four installation routes uses its producing build's export and
actual installed root, including confirmed versioned rock package prefixes.
Inspection of the current rock driver/spec supports that data-prefix distinction.

The current shell probe restores excluded M4/coverage files from source. The
replacement explicitly uses a pristine installed snapshot and manifest-member
targets, removes extra files on restoration, and requires intended diagnostic
categories. Membership/graph/content before freshness prevents stale bytes from
masking the intended negative. B implementation and C callers land together.

F07 is corrected at the generator/current-output owner: the inspected
`inventory_source.lua:65–75` lacks int32 and conflates named types. Historical
ledgers and source fingerprints remain preserved. Included conversion reachability
and actual enum spellings stay distinct from native-only schema. F11 separates
compiler and runtime identities. F12 requires verified whole-header bytes, exact
notice extraction and its own digest, not an invented extract or system-zlib
substitute. Missing source remains a blocker to that result.

The maintained manual and own-input example preserve practical safety/lifecycle,
loader, outcome and persistence limitations. The hexadecimal nm warning and
close-before-exit requirement make the example contract concrete. Historical
reports remain separate evidence, not competing installed authorities.

### 5. D is a bounded presentation and publication contract

Pandoc/Lua is selected after a credible comparison with annotated LDoc,
topics-only LDoc and explicitly locked Jekyll. The proposal does not falsely
require dispatch rewrites for LDoc or treat Jekyll's hosted defaults as mandatory.
No further framework comparison is needed for implementation readiness.

D consumes B's exact manifest via script-mode export and B's source checker,
renders the five maintained pages and derives the complete example from its
single executable source. Website additions are explicit presentation assets,
not another package shipping inventory or API authority. Actual converter/action
pins remain implementation tasks; no unavailable hashes or tested renderer
integration are invented.

Project-path and empty-baseurl checks, actual emitted IDs, source-relative URL
mapping, byte-identical notices/downloads, current-source freshness, exact output
membership, encoded-content negatives, reproducible rebuild and bounded browser
checks cover the relevant delivery risks. Native qualification is not rerun for
website acceptance. Read-only PR CI and separately guarded manual publication
retain action pins, deploy-only privileges, environment and concurrency controls.

### 6. Authority and self-containment are adequate

Master and handoff explicitly acknowledge the subsequent authorization to notify
the main planner and use supported resume once ready, after independent approval
and committed reconciliation. Earlier component draft/no-implementation-now
preambles describe their planning provenance; the assignment supplies the current
readiness/implementation boundary directly. Implementers need the linked component
contracts, not a reconstruction of earlier review conversations.

The assignment's prohibition on submission/runtime changes concerns implementer
actions; it does not revoke the coordinator's expressly authorized planner
notification/resume. Nothing grants push, Pages enablement/settings/publication,
deployment modification or new dependency patches. This reviewer performs none
of those actions.

F13 stays confined to final package/site documentation, with the exact optional
single creation acknowledgment. There is no blanket source/tool/test naming ban,
history deletion, license redaction or silent extension into operational state.

## Historical baggage and proportionality

The plan removes history-dependent shipping assertions rather than layering new
approval ledgers over them. It keeps one manual authority, one generated-field
owner and one shipping list; avoids archive moves, redirects, new fixtures,
platform expansion, upstream repair/OOM campaigns and generic test frameworks.
The two Lua fixtures directly discriminate F03; targeted mutation checks directly
discriminate the audited false positives. These are justified gates, not reasons
to repeat the prior review process during implementation.

**Optional efficiency improvement, not a readiness blocker:** master §9 currently
repeats B's full checker-mutation suite on all four installation routes. Once
unchanged checker code passes those sensitivity cases on one representative
installed snapshot, per-route pristine membership/bytes/graph/content checks
usually suffice to establish the other routes' packaging correctness. The owner
could consolidate those repeated mutations while retaining all four actual
installations and their own manifest/root checks. As written the repetitions are
bounded and cheap relative to native builds, so they do not justify withholding
approval. No additional reruns or review rounds are requested.

## Scope and evidence limits

Read project AGENTS and supplied workspace guidance; SPEC, DESIGN, COVERAGE and
PLAN; all twelve A/B/C/D analysis/design/plan documents; master and handoff; audit
index/map, all actual F01–F14 files, MASTER-AUTHOR-COMPANION and the requested
A/B-C/D r2 reviews. Inspected the actual facade, native entry/policy/conversion
snippets, Binding.cmake, rock driver/spec, package smoke and installed orchestration,
profiles/absence/document mutation scripts, M4 services/persistence, native leaf
probe and field generator/renderer.

This was bounded static review. No builds, tests, installs, fixture provisioning,
upstream fetch/checksum revalidation, website rendering, GitHub inspection,
commits, pushes, planner notification or lifecycle controls were performed.
Only this report was written. Existing historical execution evidence retains its
original scope; missing future environment, backend, ABI, notice and website
results remain execution gates, not assumed successes.

VERDICT: APPROVED
