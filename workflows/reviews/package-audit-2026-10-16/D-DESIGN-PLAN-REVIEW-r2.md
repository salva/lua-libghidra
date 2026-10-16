# D website — independent design/plan review r2

Fresh independent Astra reviewer D, 2026-10-16. Second and final budgeted
planning review; reviewer, not author. This approves a proposal, not an implemented
site, tested renderer integration, native qualification or publication.

## Separate verdicts

- **Analysis: APPROVED.** The revised alternatives section closes r1's required
  fair LDoc comparison with source-grounded capabilities and explicit evidence
  limits. The choice is proportionate to the existing manual.
- **Design: APPROVED.** Pandoc/Lua is a defensible selected presentation layer.
  B retains content/schema/manifest authority; the artifact, URL, accessibility
  and workflow boundaries remain intact.
- **Plan: APPROVED.** D1 now consistently follows the resolved renderer decision,
  with actual release qualification deferred to authorized implementation and
  explicit blocker reporting rather than an automatic framework switch. B
  integration, local acceptance and publication remain distinct stages.

**Required changes: none.** No unresolved planning finding remains from r1.
Future qualification and B integration gates below are not claimed completed.

## R1 correction and framework conclusion

The revised analysis lines 41–108 fairly distinguishes four approaches rather
than treating LDoc as requiring a rewrite:

1. **Annotated LDoc is technically applicable.** The official LDoc manual,
   independently read for this review, explicitly documents C/C++ comments,
   named functions/parameters/returns, standalone `.luadoc`, alternative return
   groups, topics, examples and custom templates. Inspection confirms the actual
   constraint: `src/owner.cpp:636` registers closures over a shared dispatcher;
   `lua/libghidra/lowlevel.lua:7` reexports helpers/factory; and
   `lua/libghidra/init.lua:8–10,32–36,69–87` constructs methods in loops. These
   limit automatic inference, not explicit documentation feasibility. Keeping
   annotations alongside B's API would require another maintained representation;
   moving authority or generating annotations would be additional scope. The
   proposal does not incorrectly assert that duplication is intrinsic to LDoc.
2. **Topics-only LDoc is a credible incremental alternative.** The manual
   confirms selectable Markdown processors, bundled fallback, lua-discount's
   PHP-Extra tables, topics routes, underscore-style section references, default
   backtick reference expansion, and Lua-oriented fenced-code prettification.
   Analysis lines 71–92 correctly require backend/version compatibility checks,
   deterministic dependency provisioning, reference suppression and route/anchor
   adaptation. It does not claim the present five pages already render correctly
   under an untested backend. Raw downloads and manifest enforcement would still
   need explicit staging with any renderer.
3. **Explicit locked Jekyll in Actions is genuinely viable.** The comparison
   allows local layouts, isolated inputs, a selected Markdown backend and locked
   gems; it does not confuse GitHub's implicit builder or the full github-pages
   gem bundle with mandatory Jekyll architecture. Ruby/gem and front-matter/link
   integration are reasonable costs to weigh, not reasons it cannot work.
4. **Retain selected Pandoc/Lua.** GFM conversion and Lua AST transformations fit
   five existing Markdown pages without adopting annotation metadata or another
   schema generator. This is a bounded maintenance judgment, not a measured
   performance claim or demonstrated integration. Exact release/archive/hash,
   local compatibility, emitted IDs and offline operation remain implementation
   checks. The user's framework question authorizes neither implementation nor
   a switch; no further framework campaign is needed to accept this plan.

Capability source: [official LDoc manual](https://lunarmodules.github.io/ldoc/manual/manual.md.html),
especially “Which files are processed?”, “Extension modules written in C”,
“Markdown Support”, “See References”, “Examples”, “Readme files” and “Tag
Modifiers”, read 2026-10-16. These are documented capabilities, not a pinned
LDoc/backend integration test.

`scripts/render-fields.lua:5–26` really consumes `api/coverage.json` and emits
model tables; its introduction distinguishes source facts from runtime acceptance
and call grammar. B owns its representation corrections and included/excluded
schema semantics. Neither LDoc nor Pandoc automatically supplies those facts.
The revised design preserves that separation without an unnecessary adapter.

## Preserved acceptance boundaries

- **Single source and manifest:** D design lines 49–78 consume B's
  `LLG_PACKAGE_DOCUMENTS`, explicitly render five pages, copy exact recognized
  notice/license/lock entries, fail unknown dispositions, and enumerate the
  finished artifact. The example and stylesheet are explicit website extras.
  B's current design lines 22–65 and 262–277 agree on the newline manifest and
  absolute `source SOURCE_ROOT MANIFEST` interface. Script-mode export/shared
  helper compatibility is a sequential integration requirement, not an assumed
  existing API. D neither substitutes a second shipping list nor configures the
  native build.
- **No historical baggage:** history stays in source, outside the artifact.
  Milestones do not become user navigation; no unestablished legacy routes,
  redirect machinery or version hierarchy is invented. The exact optional
  creation credit is narrowly located and counted; decoded HTML, attributes,
  comments, paths and downloads remain checked. Exact notice bytes are preserved,
  with a real conflict reported rather than redacted. Operational warnings,
  attribution and source-delivery qualifications remain substantive user facts.
- **Links and assets:** source-relative resolution precedes output mapping;
  README maps to index, project base `/lua-libghidra` is explicit, and actual
  emitted IDs/fragments, duplicate headings, encoded paths, raw downloads and
  assets are checked. Unsupported syntax fails visibly. Parent-root local preview
  and direct nested-page checks exercise the intended project deployment path.
- **Accessible, small presentation:** semantic landmarks, one H1, skip/focus
  controls, generated TOCs, narrow layout, scrollable tables/code, zoom and
  contrast observations form a useful acceptance contract. No JS, remote assets,
  search service, theme framework or extra native/API generator is introduced.
  The converter is documentation-only; BusyBox preview is optional.
- **Meaningful validation:** current sources, copied bytes, actual artifact
  membership, field freshness, a second fresh render and targeted negative
  mutations address real failure modes. Browser checks are not overstated as a
  full accessibility audit. External links are inventoried, not asserted reachable.
  Keep the checker bounded to these contracts rather than growing a generic
  Markdown/HTML framework; the current proposal does not require that expansion.
- **Secure publication separation:** read-only PR checks, no persisted checkout
  credentials/secrets or pull_request_target, pinned actions, default-branch-only
  manual publication, same-run checked artifact, deploy-only Pages/OIDC rights,
  environment and serialized publication are appropriate. Settings, push and
  first deployment require separate operator authority; configure-pages must not
  auto-enable Pages. Local build success does not imply a live site.

## Inspection limits

Read repository AGENTS and supplied workspace guidance, SPEC/DESIGN/COVERAGE/PLAN,
all three D proposals, F13, F14, r1, subsystem map and current B design. Inspected
the actual native registration, Lua facade/exports and field renderer; independently
read the upstream LDoc manual. No implementation, build/test execution, runtime
operation, commit, push, GitHub settings/control action or author-document edit
was performed. Only this review report was written.

VERDICT: APPROVED
