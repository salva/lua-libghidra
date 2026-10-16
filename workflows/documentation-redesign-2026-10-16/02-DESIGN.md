# Documentation redesign — selected implementation design

Baseline `4dffcb1`; planning only. This document defines the target organization
and integration contract. Do not implement, build native/site artifacts, Run,
commit, publish, deploy or notify a planner during this authoring task. A fresh
independent design review precedes sequenced plan drafting and later adoption.

## 1. Design objective and nonnegotiable boundaries

Make installation, learning, lookup and contribution distinct reader journeys,
using the existing Markdown, Lua field generator, CMake document export and
planned Pandoc/Lua renderer. No framework migration or second manual is needed.

Final documentation contains no development history, approval narratives,
milestone accounting or example-origin commentary unless genuinely needed to
explain current behavior. Preserve current safety/limitations and required
license/source attribution. No Saivage references in final docs/site except an
optional concise creation acknowledgment. Working plans, critiques, execution
reports and operator instructions stay outside `docs/` and artifacts. This does
not ban identifiers in code/tools/tests or authorize deleting Git/runtime history.
Independently authored Lua examples replace copied/recognizably adapted upstream
examples, without cosmetic translation or clean-room claims. No historical
retention dossier is required for a reader or as an acceptance gate.

The detailed [analysis](01-ANALYSIS.md) compares focused repair with this selected
one-level-up organization. [Requirements](00-REQUIREMENTS.md#L10) are normative.

## 2. Target tree and audience

```text
README.md                         product landing and reader choices
LICENSE                           unchanged exact wrapper license
native-*.lock.json                current pinned inputs/profile/system data
docs/
  INSTALL.md                      supported environment and four install routes
  TUTORIAL.md                     first successful own-input decompilation
  EXAMPLES.md                     task recipes and runnable-example instructions
  API.md                          domain reference, values, errors, limits
  NOTICES.md                      attribution, exact inputs and source obligations
  notices/*.txt                   exact existing third-party notice bytes
  development/
    README.md                     contributor entry and source layout
    SPEC.md                       maintained binding contract/invariants
    DESIGN.md                     current architecture and ownership boundary
    COVERAGE.md                   current operation/support accounting methodology
    TESTING.md                    current build, fixture and validation commands
api/
  FIELDS.md                       generated supported records, index, native appendix
  coverage.json                   sole current native source-fact ledger
  README.md                       ledger generation/maintenance instructions
  history/coverage-m3.json        existing test-consumed historical data, not manual
  runtime-evidence-m3.json         existing historical data, not manual or generator input
examples/
  decompile.lua                   new task-authored own-input CLI
  inspect_function.lua            new task-authored bounded inspection CLI
tests/examples/
  first_slice.lua                 former regression demonstration
  core_mutation.lua               former invalidation regression demonstration
  fixture_manifest.lua            source-only helper for those regressions
workflows/                        working/operator material only
  documentation-redesign-2026-10-16/  this design, reviews and eventual plan
  package-fixes-2026-10-16/        moved existing working plans
  reviews/                       moved existing reviews
  history/                       existing dated reports removed from main docs
  evidence/                      existing nonlegal execution logs removed from docs
```

This tree names maintained responsibilities, not a five-page cap. The two selected
examples address distinct reading tasks, not an API regression tour or example
framework. No new facade methods
or replacement native algorithms are implied.

### Landing and learning

README has a concise scope/profile description and links to Install, Tutorial,
Examples, API, Fields and Notices. It retains visible wrapper/upstream attribution
and points to current locks, without operator-approval wording. The contributor
entry is source-only: use a plain path in the shipped README, as today, rather
than a broken relative link outside the installed allowlist.

INSTALL owns prerequisites, source-versus-qualified-SDK selection, CMake and
LuaRocks routes, actual package-data paths, host ABI selection, shared helper DSO,
input preparation/offline distinctions and spec-cache setup. Clearly state that
commands need a checkout and that no public SDK download is promised. Preserve
the source-build-only Python >=3.10 stdlib zlib/XML requirement from the unchanged
pinned generator; SDK consumption and runtime need no Python bindings/Python,
Java or network. Explain current setup, not the history of exception approval.

TUTORIAL assumes installation completed. It guides selection of a known mapped
virtual function address on a supported binary (including hexadecimal `nm`
output), explicit architecture hints, external/embedded specs, execution,
diagnostics and complete/nonfallback outcome inspection. Put native crash limits
before the first address-taking invocation. Exact UInt64 parsing is not mapping
validation. No guessed/extreme address experiments and no eager-analysis promise.

EXAMPLES is a task catalog and explanation of input/output choices, not another
install guide. Full runnable Lua lives only in `examples/*.lua`. Link to it in
checkout/package Markdown; the site may render escaped file contents and offer
downloads from those same bytes. Avoid a separately maintained full-code copy
in Markdown. Shell invocations can be shown inline. Short API idioms may remain
inline where they explain a contract, but must be independently authored and
reviewed along with the executable examples.

## 3. Reference organization and authority

### API: one reference, navigable by domain

Retain `docs/API.md` as the single hand-maintained signature/default/envelope and
effective-limit authority. Start with linked method index, surface legend and
return/error conventions. Use the following sections, each with method headings
or individually linkable rows via ordinary Markdown headings (no raw HTML anchor
dependency):

1. Construction, session lifecycle, status and capabilities.
2. Exact values, validation, errors and shared pagination grammar.
3. Functions and decompilation, including signatures, parameters and locals.
4. Instructions, comments and defined data.
5. Symbols and cross-references.
6. Memory and byte patches.
7. Types, aliases, enums and members.
8. Performance records.
9. Ownership, iteration/invalidation and category-specific persistence limits.

Do not duplicate shutdown in two operation lists. Mark each method as Session,
lowlevel, or both, with the Session return difference adjacent. Each entry gives
exact arguments/defaults, request keys or shared-page link, result field/envelope,
record links, state requirements, mutation effects and applicable limits.
Index includes `open`, `local_client`, `check`, `u64`, `native`, `close` and the
three actual iterators as well as all implemented native calls. Compare it with
the actual [facade](../../lua/libghidra/init.lua#L8) and native registrations;
do not take historical surface proposals as signatures.

Every model-bearing result must link to its generated schema and nested record.
For example `get_decompilation` links both GetDecompilationResponse and
DecompilationRecord; `get_function` identifies `response['function']` and
FunctionRecord. `get_status` links HealthStatus; `get_capabilities` links Capability
as the array element, not an invented response envelope; `patch_bytes_batch`
links BytePatch as its input item. Scalar results explicitly say scalar.
Required positional arguments stay
required even where native model fields have defaults. The three actual iterator
families are not expanded from source reachability.

Keep the substantive [current limits](../../docs/API.md#L218): one owner/process,
no independent-engine mixing, host ABI, detached records, logical versus owner
closure, NO_STATE_PATH facade guard, no autosave/rollback, per-category persistence,
ignored read_only/project_name/timeouts, ReadBytes and compound bounds, partial
batches, pages-only/filtering behavior, constant-empty defined strings, lazy
discovery, raw/FileBytes limits, unqualified true-local retyping and lack of
dependency OOM recovery guarantee. Put method-specific caveats at the method;
cross-link common explanations rather than copying a second full limitations list.

### FIELDS: supported records first, native-only appendix

Keep `api/coverage.json` → `scripts/render-fields.lua` → `api/FIELDS.md` as the
only pipeline. Extend the existing renderer, not a second generator. Output:

1. Meaning of Lua conversion support versus native producer/runtime qualification.
2. Linked index grouped into supported records/result values, request/options/input
   items, response envelopes, supported enums, and native-only appendix.
3. Supported Lua records/result values first (including nested records), alphabetical
   within that group; request/options/input items and response envelopes next.
4. Supported enums with exact spelling and unknown-response numeric fallback.
5. Native-only schemas/enums last, explicitly without Lua support claims.

Partition the actual ledger exhaustively and without overlap in the existing
renderer, using `lua_scope` from recursive reachability first:

- Every native-only type goes to the appendix regardless of name; every
  native-only enum goes to its enum subsection there.
- For included types, `*Record` plus the explicit exceptions `HealthStatus` and
  `Capability` go to **records/result values**. HealthStatus is the direct status
  result; Capability is an array item, not an envelope.
- Included `*Request` and `*Options`, plus the explicit exception `BytePatch`,
  go to **requests/options/input items**. BytePatch is the `{address,data}` item
  accepted by patch batches, not a response. LocalClientOptions belongs here.
- Included `*Response` goes to **response envelopes**.
- Every included enum goes to **supported enums**. Unknown scope, unassigned
  included type or multiple assignment fails generation rather than dropping it.

The three exceptions are a small presentation map inside `render-fields.lua`,
not another schema source. Assert disjoint output sets whose union equals every
key of `ledger.types` and `ledger.enums`, with each emitted once; verify the
three named exceptions' actual partitions. Preserve unique model-name headings,
their stable slugs and nested links. Retain native-only facts in the appendix,
not another field document. Source reachability alone never proves populated
output, stable iteration, persistence or optional Lua positional arguments.

The API owns method-to-record links; the generated ledger owns native fields and
conversion types. Do not add a second handwritten field table or make the source
ledger's historical proposed call grammar a new API authority. Contributor
instructions document exact regeneration and freshness commands.

### Current contributor knowledge, not work history

`docs/development/SPEC.md` retains maintained invariants, supported platform/scope
and requirement rationale, linking API rather than duplicating signatures.
`DESIGN.md` describes actual direct-C-API phases, shared ownership, conversion,
serialization and bounded iterators. `COVERAGE.md` explains implemented/excluded
operations, source-schema versus real-producer distinctions, known supported
profiles and how coverage is checked, without stage/tier progress reports.
`TESTING.md` owns current source/SDK construction, fixture preparation and the
actual full/reduced installed driver contract. Reduced is not full qualification.
These pages are source-only and never installed or rendered by this site's user
manual. They contain no automation/operator policy or historical archive index.

Current lock data stays at root; generator metadata and tests stay with tooling.
Workflow decisions about review, Run, deployment, model routing or permission
belong in `workflows/`, not contributor guides or machine source-fact ledgers.

## 4. Exact disposition of current material

Apply these source transformations during implementation, not during planning.
Paths in this table are baseline paths; destinations are the target tree above.

| Current source | Disposition |
| --- | --- |
| `README.md` | Rewrite reader navigation and current-state wording; retain substantive attribution and profile. |
| `docs/EXAMPLES.md` | Split installation content into INSTALL, own-input explanation into TUTORIAL; replace EXAMPLES with task catalog. Remove milestone/old-dossier upgrade narrative. |
| `docs/API.md` | Reorganize by domains, add method index and schema links; preserve current grammar and limits. |
| `api/FIELDS.md` | Regenerate supported-first/index/appendix layout from the existing ledger. |
| `docs/NOTICES.md` | Retain legal obligations, identities and source attribution; remove approval/audit-process narrative. Move byte-extraction procedure out of user prose. |
| `docs/evidence/native-notices/*.txt` | Move all fourteen exact existing files to `docs/notices/`; no reflow, normalization or omission. |
| `LICENSE`, three root native locks | Keep exact current assets, no new approval claims or incidental lock updates. |
| `docs/SPEC.md`, `docs/DESIGN.md`, `docs/COVERAGE.md` | Extract/rewrite maintained current content into same basenames under `docs/development/`; remove old main-doc paths, no redirect stubs. Move only still-useful working-policy text to workflows. |
| `docs/development/README.md` | Replace chronological report/index with contributor entry; extract current commands into TESTING and link maintained technical pages. |
| `api/README.md` | Keep current generation/field maintenance instructions; remove chronological migration/approval narrative and report-navigation obligations. |
| `docs/PLAN.md`, `docs/M0-LICENSE.md`, `docs/M0-LICENSE-SOURCES.tsv`, `docs/M1-BOUNDARY.md`, `docs/M1-OWNERSHIP.md`, `docs/M2-SLICE.md`, `docs/M3-CORE.md`, `docs/M4-FULL.md`, `docs/INSTALLED-CORE.md`, `docs/INSTALLED-FULL.md`, `docs/FULL-CROSSWALK.md`, `docs/NATIVE-READINESS.md`, `docs/PACKAGE-FOUNDATION.md`, `docs/PACKAGE-HANDOFF.md` | Remove from main docs; move existing working artifacts to `workflows/history/` under their basenames. Extract only present facts needed by maintained guides; no reader link to these reports. |
| `docs/evidence/*` except `native-notices/` | Move existing execution artifacts to `workflows/evidence/`, preserving contents; no new evidence dossier is requested. |
| `docs/development/plans/package-fixes-2026-10-16/**` | Move to `workflows/package-fixes-2026-10-16/**`; the eventual accepted replacement plan supersedes conflicting B/D content through its owner. |
| `docs/history/reviews/package-audit-2026-10-16/**` | Move to `workflows/reviews/package-audit-2026-10-16/**`. |
| `docs/reviews/**` | Move to `workflows/reviews/baseline/**` to avoid name collisions. |
| `api/coverage.md` | Move chronological research report to `workflows/history/api-coverage.md`; not generation input. |
| `api/history/coverage-m3.json`, `api/runtime-evidence-m3.json` | Keep test-consumed data at existing source-only paths; no manual/site links or regeneration. |
| `examples/first_slice.lua`, `core_mutation.lua`, `fixture_manifest.lua` | Move to `tests/examples/`, update test caller and helper path; remove from install/site. In relocated first_slice, omit the `get_function(u64(fixture.absent_function_address))` nil/NOT_FOUND assertion; remove the helper's `absent_function_address='18446744073709551615'` field. Retain safe checks; no guessed absent-address substitute. |
| `examples/decompile.lua` | Newly task-author its contents using current Lua contract and task spec below, retaining sensible public filename. Review origin assessment without claiming that every existing idiom was copied. |
| Remaining `workflows/**`, `.saivage/**`, `.saivage-work/**`, Git history | Outside the manual. No runtime/history deletion or automatic runtime-reference rewriting. |

Moving existing working material is a bounded location correction, not a new
requirement to reconstruct missing evidence, archive every prior revision or
repair every frozen historical link. Update maintained source consumers and
currently active workflow references. The owning planner must coordinate live
references before execution; do not mutate runtime cards/session history as a
filesystem migration shortcut. Do not leave redirects simply to preserve old
paths. Git supplies historical revisions.

Relevant path consumers include `AGENTS.md` and project skills/current workflow
instructions, `tests/tooling_coverage.lua`, `tests/generator-policy.sh`, fixture
README links, `tests/tooling_fields.lua`, package mutation probes and integration
callers. Update source guidance references using the applicable project guidance
workflow when required; this redesign gives no deployment authority. Remove tests
that demand obsolete approval wording in user contracts only by replacing that
assertion with its current substantive build-dependency obligation.

## 5. Independently authored executable examples

Use independently chosen tasks and control structure derived from Lua's public
contract. Do not translate an upstream sample or preserve its distinctive
sequence/data merely with Lua spelling. The completed bounded assessment found
no distinctive copying or recognizable upstream adaptation; actual origin remains
unknown. This permits proceeding without further research, not a clean-room or
originality claim. Preserve necessary API syntax, outcome checks and ordinary Lua
lifecycle idioms. New authorship serves the selected tasks, not novelty for its
own sake. Keep assessment/provenance commentary out of final documentation.

Select two public scripts. Decompilation produces a function-level review note;
inspection lets a reader correlate that result with exact metadata and bounded
machine-code data. Defer the public rename example: it adds no necessary step to
these reading tasks. In particular, intentional stale-iterator invalidation is an
internal regression concern, not a public naming task. Keep its explanation in
API and its safe existing internal coverage. No new state-file example is needed.

| Script | Task and required behavior |
| --- | --- |
| `decompile.lua` | Given binary, caller-verified mapped function entry, language/compiler hints and optional spec root, emit exact requested address, result classification and pseudocode suitable for a review note. Put structured diagnostics and engine error text on stderr. Exit success only for completed, nonfallback, no-error-message output. Distinguish nil/error from present incomplete records. Return through a Lua 5.4 close scope before exit. |
| `inspect_function.lua` | Given the same own-input context plus caller-confirmed mapped bounds and explicit small read limits, decompile the known function first, then summarize its available record and bounded byte/instruction view. Expose UInt64 hex values and optional absence; never scan for a mapped address or infer no code from an empty page. Bound each read independently as specified below. |

For inspection, require a byte count (script cap 64), explicit nonzero inclusive
instruction range end and instruction count (script cap 8, offset zero). Both
starts must be the caller-confirmed function/instruction entry. Validate positive
counts and exact checked address arithmetic before native reads. The byte interval
and instruction range must each lie within the caller-confirmed mapped extent;
do not derive instruction bounds from the byte count, omit the range end, use the
zero-end sentinel or decode arbitrary interior addresses. The caller must confirm
complete instruction bytes are mapped, not merely the last instruction's starting
address. These are script input bounds, not a native mapping/crash-safety proof.
Use qualified fixture spans for validation; no exploratory decode-boundary probes.
If an observation is unavailable, report it rather than print a success claim.
Neither example embeds fixture addresses/names or assumes a second function.
Do not add a shared example framework for these small scripts.

Validate all scripts against the real installed supported package from a fresh
working directory with fixture-selected safe inputs. Fixtures supply test data,
not a runtime dependency of the installed scripts. Validate external and embedded
spec invocation for decompilation; reuse unchanged native profile qualification
for unrelated engine behavior. Assert meaningful expected semantics, outcome
status, exit status and closure; successful rendering or `luac` parsing alone is
insufficient. Supplement with existing control-flow cases for fallback,
incomplete, error-message, open failure, invalid arguments and raised Lua errors.
Do not manufacture dangerous addresses to obtain native negative cases or add
dependency-internal OOM tests. For relocated source-only regressions, retain safe
both-surface lifecycle/envelope/invalidation coverage, but explicitly exclude the
existing UINT64_MAX native lookup from this lane: remove the absent-function
assertion and helper field named in the disposition table before running it.
Use existing safe optional-result coverage; do not require another unmapped
address, new native test campaign or engine repair. Git history remains intact.

## 6. Installation and site integration

### One authoritative manifest

Keep `cmake/PackageDocuments.cmake` as the sole package-manual inventory. Replace
old entries with README, INSTALL, TUTORIAL, EXAMPLES, API, NOTICES, FIELDS, LICENSE,
three root locks and fourteen `docs/notices/*.txt` entries. Also enumerate the
two public Lua files in that same CMake file as `LLG_PACKAGE_EXAMPLES`; export
their newline list alongside the document export. This is an asset class within
one manifest authority, not another hand-maintained shipping inventory.

Install documents under `share/doc/lua-libghidra` preserving source-relative
layout. Install public scripts once under `share/libghidra/examples`. For linked
offline manual code, also copy their exact bytes at
`share/doc/lua-libghidra/examples/*.lua`, selected from that same example list;
this is a generated delivery copy, not a second source. The combined document
export includes those manual example paths for graph and byte-equality checks.
Source mode resolves them to the actual root `examples/` files. Check the runnable
copies for equality too. Do not install fixture tests or contributor/workflow docs.

Source checking validates only manifest-selected inputs and their link graph;
contributor/workflow files elsewhere in the checkout remain allowed. Exact
membership and nonregular-file rejection apply to the staged documentation
subtree and site output, not the whole source tree or installed prefix.

Both CMake and LuaRocks consume this installation via the existing driver; honor
each producing build's manifest and actual versioned LuaRocks package prefix.
Update the installed example group to run the new public scripts from package
data with safe test arguments. Run only the corrected safe relocated regressions
from the source test tree against installed modules; the unchanged first-slice
UINT64_MAX lookup is not a required or permitted step of this example lane.
Keep the established source/installed checker CLI contract and explicit full/
reduced selection. No inferred sibling manifest or ambient skip switch.

### Website is the same manual

Finish the existing pending website work using Pandoc/GFM and bounded Lua filters.
The site exports the manifest with CMake script mode, without configuring or
building native code. Render every selected Markdown document: README to
`index.html`, others to their source-relative `.html` paths. Copy exact license,
locks, notices and public Lua assets. The route map classifies every exported
entry once and rejects unknown classes/collisions; it does not freeze a five-page
count or maintain an independent content list. No contributor/workflow pages.

The pending owner remains `card-h-d`. Its existing source plan is
`docs/development/plans/package-fixes-2026-10-16/D-website/03-PLAN.md`, moving to
`workflows/package-fixes-2026-10-16/D-website/03-PLAN.md`. This design supersedes
that plan's fixed-five-page route list and standalone extra-example inventory.
Use the interfaces below directly; no reconciliation of old review rounds or
second website project is required:

- `site/export-documents.cmake` includes `cmake/PackageDocuments.cmake` in script
  mode and exports its combined `package-documents.txt` and example list into an
  explicitly selected fresh work directory. No top-level project configuration.
- `scripts/build-site.lua` stages/renders the exported sources into a fresh
  explicit output directory. `site/content.lua` owns navigation and route rules
  derived from those exports, not a second page/example inventory.
- Before rendering, run `lua5.4 scripts/render-fields.lua --check`, then
  `lua5.4 tests/installed_documents.lua source SOURCE_ROOT MANIFEST`, with absolute
  paths and MANIFEST from this site's own script-mode export.
- Retain package checks as
  `lua5.4 tests/installed_documents.lua installed DOCUMENT_ROOT SOURCE_ROOT MANIFEST`
  and `bash tests/installed-documents.sh DOCUMENT_ROOT SOURCE_ROOT MANIFEST FRESH_WORK`.
  These remain package-check interfaces, not HTML-check aliases.
- `site/links.lua` is the Pandoc Lua presentation filter;
  `site/template.html` and `site/style.css` own layout only.
  `scripts/check-site.lua` verifies the actual output map, local graph/fragments,
  content policy, source freshness and exact passthrough/download bytes.
  Focused cases belong in `tests/site_contract.lua`; no second doc-policy engine.
- `site/toolchain.lock.json` records an actual selected Pandoc version/platform,
  release URL, SHA256 and license. Verify archive hash/executable version;
  tool preparation is explicit and separate from offline build/check. Lua 5.4
  and CMake script-mode prerequisites are recorded in source-only `site/README.md`.
  A matching local converter is allowed; no floating latest or native lock edits.

Keep reports/tool sources outside the site output. Permit only derived HTML,
manifest-selected passthrough/download files, local CSS and `.nojekyll`. Reject
symlinks, escaping paths, collisions and output overlapping source inputs.
Produce deterministic output without timestamps/machine paths; a second fresh
render must agree. Check/publish workflows use these same build/check entrypoints;
publication stays manual and separately authorized, never implied by a local pass.

Navigation is Home, Install, Tutorial, Examples, API, Fields, Notices. Generate
page contents from actual headings; keep domain/method and record anchors valid
in source Markdown and rendered HTML. Resolve relative links in source space,
then transform through the output map; validate actual rendered fragments.
Share the current Markdown helper's heading-ID strategy with the Pandoc filter:
lowercase heading text, remove backticks/punctuation as the helper specifies,
hyphenate whitespace, and suffix duplicate IDs with `-1`, `-2`, etc. Extend/export
that implementation from [the existing helper](../../scripts/package-documents.lua#L105)
rather than independently approximating it in the site. The filter sets those
IDs explicitly; model-name headings retain their existing unique slugs. Unsupported
link/anchor markup fails clearly, rather than escaping graph validation.
Use page-relative links/assets under `/lua-libghidra`, and validate both project
subpath hosting and local preview. No hardcoded domain-root asset paths.

Use one accessible responsive template, local CSS/system fonts, keyboard focus/skip
link, scrollable wide tables/code, no remote assets/analytics/JavaScript, fresh
output staging and explicit output allowlist. Site building has no engine or
example-execution prerequisite once source checks pass; runtime example checks
are a separate validation lane. Tested example bytes are rendered/downloaded,
not translated into a second illustrative script.

Use the same document-policy helper where appropriate for source/HTML content
rules; HTML verification additionally checks decoded text/attributes/comments
and actual href/src targets. Preserve exact raw legal/download bytes. An exact
license conflict must be reported, never scrubbed to satisfy a word scanner.
Optional acknowledgment is one literal landing-page credit only, not an excuse
for workflow leakage. No framework switch, redirect scaffolding or second site.
Publication remains separately authorized; local site implementation is not
permission to push, enable Pages or deploy.

## 7. Verification contract

Required checks are proportional to the changed surfaces. Reuse unchanged native
evidence; run affected documentation/tooling, examples and package routes. Do not
rerun all native acceptance merely because pages moved. If an existing required
integration job is selected, complete its declared scope and report full/reduced
honestly; do not weaken it to fit this documentation task.

| Requirement | Positive check | Negative/sensitivity case |
| --- | --- | --- |
| Reader path | From README reach install, tutorial and method → record → caveat without reports | No tutorial dependency on fixture manifest or working-doc link |
| Exact current API | Every actual public method indexed with surface/return shape; record-bearing returns linked | Reject missing method/schema target and unsupported iterator claim |
| Generated fields | Regeneration and `--check`; disjoint partitions cover every included/excluded type and enum exactly once; HealthStatus/Capability are result values, BytePatch an input item | Stale output, missing/duplicate model, wrong exception partition, misplaced excluded schema or broken nested link fail |
| Contributor separation | Current commands/pointers work; no dated status or automation instructions in maintained docs | Working report copied into docs or artifacts fails content/location review |
| Content preservation | Review all current limits and legal obligations against baseline | Removing address-crash warning, ignored timeout caveat or persistence limits is detected |
| Package closure | Source graph, staged exact membership/regular files, bytes and public-script copies match selected exports | Missing file, stale bytes, unlisted report, broken link/image/reference/fragment and malformed manifest fail |
| Required-policy continuity | Obligations explicitly require new target members | Renaming/removing INSTALL or API cannot disable all required-fact assertions |
| Legal assets | Compare all fourteen moved notices plus LICENSE and locks byte-for-byte | Any accidental reflow, truncation or omitted notice fails |
| Public examples | Real installed runs with safe fixtures and meaningful output checks; no source fixture dependency | Synthetic fallback/incomplete/error exits and close-before-exit checks; bad arguments fail before native work |
| Safe regression relocation | Selected first-slice lane omits the UINT64_MAX lookup and absent_function_address helper; existing safe optional-result checks remain | Do not run the unmodified legacy lookup or replace it with a guessed unmapped address |
| Artifact content | Scan selected source, installed files, rendered/decoded HTML and downloads | Hidden workflow markers, duplicated/mislocated credit and report leakage fail |
| Site graph | Every output selected once, all local links/fragments/assets valid under project base path | Root-path asset, stale page/example, missing anchor and unknown export fail |

Adapt existing checker tests and mutation probes instead of duplicating their
framework. Lexical checks supplement a concise editorial review for history,
approval and example-origin prose; they cannot mechanically establish authorship.
Do not build an NLP policy engine or ban ordinary words such as “source”, “build”
or “license”. Keep all validation reports in working locations outside the manual.

## 8. Integration handoff constraints

The eventual sequenced plan must coordinate through the owning main Planner:
preserve completed A/B/C changes and bounded evidence; replace conflicting old
B content-shape instructions; adapt the existing unfinished `card-h-d` website
scope to this manifest/tree rather than spawning a duplicate website project.
Path-sensitive source checks and active references must move with their content.
The completed origin assessment requires no additional origin investigation and
does not expand native scope or alter the renderer choice. Fresh independent design and plan review are still
pending; no approval or adoption is asserted here. Execution stays stopped until
separately authorized Run.
