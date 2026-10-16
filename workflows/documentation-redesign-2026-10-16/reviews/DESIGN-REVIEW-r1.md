# Independent design review — round 1

## Verdicts

- **Analysis: CHANGES_REQUESTED.** The current-state investigation and focused-versus-structural comparison are substantially sound. Integrate the completed example assessment and reassess the selected example scope rather than describing that assessment as still underway.
- **Design: CHANGES_REQUESTED.** The reader journeys, authority separation and reuse of the existing manifest/renderer are credible. Three bounded corrections are required before this becomes an implementation-plan foundation.

This is an independent review, not authorship, implementation approval or runtime acceptance.

## Evidence and limits

Read the supplied workspace/project instructions and repository AGENTS; SPEC, DESIGN, COVERAGE and PLAN; all eleven requested redesign documents; current README, API, EXAMPLES, NOTICES, contributor index and api README. Inspected the generated FIELDS layout and relevant schema facts, complete field renderer, coverage type names, facade implementation, package manifest/checker, CMake install selection, installed qualification driver, fixture examples, field checks and synthetic decompilation control-flow checks. Read the pending D website design to assess compatibility with its actual planned interfaces.

The tracked worktree was clean when inspected. This review uses current product files and the supplied baseline relationship; it does not independently reconstruct all changes since `4dffcb1`. No native execution, builds, tests, runtime operations or independent upstream-origin investigation were performed. The assessment's bounded unknown-origin conclusion is evidence supplied by the separate analyst, not an originality certification by this reviewer. Exact notice preservation is reviewed as a design obligation, not newly verified legal clearance or a byte-comparison pass.

## Required changes

### R1 — Complete the generated-schema partition with actual non-suffix models

**Where:** `02-DESIGN.md`, lines 155–169 and verification row “Generated fields”.

The rule groups included `*Record` types first, then classifies the remainder as options/requests/responses and fails on anything unassigned. The actual included ledger contains **HealthStatus, Capability and BytePatch**, none of which fits that suffix-based scheme. HealthStatus is the status result; Capability is an element of the capabilities array; BytePatch is a patch input item. Calling all three envelopes would also misdescribe the public shapes. The current renderer emits every type without this classification problem.

**Required correction:** Specify their placement and an exhaustive, non-overlapping rule that accommodates actual value/item models as well as `*Record` models. A small explicit exception map in the existing renderer is sufficient; do not invent a second schema authority or generator. Retain stable model-name headings and API links to these models, including array element links for capabilities. Specify a check that all current included and excluded types/enums are emitted exactly once and these three receive the intended partition. Reachability remains conversion/source scope, not populated-producer qualification.

### R2 — Make the public example selection genuinely task-first and proportionate

**Where:** `02-DESIGN.md`, target tree, lines 237–268 and manifest selection; `01-ANALYSIS.md`, example assessment and alternatives discussion.

The design makes three scripts mandatory and makes deliberate stale-iterator invalidation part of the public rename script. This preserves the distinctive *local regression-tour* shape of `core_mutation.lua` after correctly deciding that the old regression tour should move out of public delivery. It duplicates behavior explicitly retained in internal regression coverage. It also contradicts the separate assessment's useful distinction: optional brief C is a user naming task, **not** an intentionally stale-iteration demonstration. No distinctive upstream copying was established; uncertainty is not a justification for manufacturing extra examples or acceptance machinery.

**Required correction:** Choose the smallest justified public set and state the user need for each selected task. A second inspection example can be justified independently; the analyst's shortlist proposal is not mandatory. Either defer the rename example or make it a straightforward edit-and-observe task without requiring an intentionally invalid iterator or unnecessary state-file context. Keep invalidation explanation in API and its existing internal checks. Reconcile tree, manifest and validation obligations with that choice. Update the analysis to incorporate the completed assessment's actual finding and explicitly identify this inherited regression structure as evolutionary bias in the latest design, not just in the old documentation. Preserve correct API names, required outcome checks and ordinary Lua lifecycle idioms without trying to make them look novel.

### R3 — Resolve the unsafe absent-address probe before mandating relocated regression execution

**Where:** `02-DESIGN.md`, disposition row for fixture examples, lines 258–268 and 290–294; `01-ANALYSIS.md`, fixture example discussion.

The assessment correctly identifies an actual native dispatch: `first_slice.lua` calls `get_function(u64(fixture.absent_function_address))`, and the fixture helper supplies `18446744073709551615`. The design says to preserve regression intent “without extending unsafe-address experiments”, but also requires running the relocated regressions explicitly against installed modules. Moving the unchanged file preserves this exact probe inside the new mandatory validation path. Merely prohibiting *new* extreme addresses does not resolve the conflict.

**Required correction:** Explicitly exclude that extreme-address dispatch from the redesigned example-validation requirement. State how useful relocation coverage is retained without making this lookup a new acceptance obligation: for example, omit the unsafe assertion from the relocated demonstration and rely on existing safe optional-result coverage, or leave that legacy case outside the selected example lane with its limitation recorded in working material. Do not require finding another guessed unmapped native address or opening a native repair/test-expansion campaign. Name the affected assertion/helper field so an implementer need not infer the decision from an earlier review. This does not authorize deleting immutable history or changing the binding contract.

## Optional improvements

1. **State the source-versus-built boundary in one explicit sentence.** Source mode checks only manifest-selected inputs and their graph; it must allow contributor/workflow files elsewhere in the checkout. Exact membership/nonregular-file rejection applies to the staged document subtree and site output, not the whole source tree or whole installed prefix. The existing checker already embodies this distinction; preserve it when adding example exports.

2. **Make the pending-site handoff more self-contained.** The new design correctly keeps D pending and selects the same Pandoc/Lua direction, but “retain the pending site's proportionate provisions” leaves some retained details discoverable only in the soon-to-move D design. In the replacement plan, enumerate the small retained site inputs/interfaces and exact relocated owner path, and explicitly supersede the old fixed-five-page route table and standalone extra-example inventory. Carry over the existing shared heading-ID strategy and source-check CLI rather than asking an implementer to reconcile prior review rounds. This is consolidation, not a request for another website specification or broader workflow scaffolding.

3. **Avoid accidental oversized instruction reads in the inspection task.** If that example is selected, define its instruction range/count independently from the explicit byte-read count and honor the caller-confirmed mapped extent for both. A small requested byte count alone does not bound a separate instruction-page call. This can be settled directly in the implementation brief without a new safety framework.

## What is sound and should be retained

- The structural alternative is justified by distinct installation, learning and lookup needs; it does not require a framework migration or per-method page explosion.
- API remains the signature/default/envelope authority. Domain organization, per-method surface distinctions, actual three-iterator limits and method-to-generated-model anchors are more useful than the current common/specialist split.
- Contributor SPEC/DESIGN remain maintained technical contracts, while chronology and automation policy move to workflows. The disposition table names concrete destinations, preserves machine historical data and Git/runtime records, and avoids redirects or installed navigation to reports.
- The single CMake inventory, example asset class and exact-byte delivery copies can support checkout, installed manual and website without a second source of example code. The existing checker CLI and full/reduced distinction are preserved.
- The design correctly calls out the old three-path policy-check bypass, exact notices/locks, present ownership/address/UInt64/deadline/persistence limits and the distinction between source support and native producer behavior.
- Same-source Pandoc rendering remains unfinished work under the existing D owner. The redesign does not treat D as completed, authorize deployment, or reopen unrelated native qualification.

The required corrections are bounded design edits. They do not call for new origin research, historical evidence dossiers, legal clearance gates, replacement native algorithms or a new validation framework. Corrected documents should stand on their own; this review need not become an implementer's required reading path.

VERDICT: CHANGES_REQUESTED
