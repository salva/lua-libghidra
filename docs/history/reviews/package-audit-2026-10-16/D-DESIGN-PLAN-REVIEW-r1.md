# D website — independent design/plan review r1

Fresh independent Astra reviewer D, 2026-10-16; distinct from the design author.
Review of the three D-website proposals, not implementation acceptance.

## Separate verdicts

- **Analysis: CHANGES_REQUESTED.** The Jekyll/Pandoc comparison is reasonable,
  but omits the materially relevant LDoc alternative raised by the operator.
- **Design: CHANGES_REQUESTED.** Pandoc remains a defensible provisional choice;
  complete the selection rationale in required change 1 before freezing it.
  No other architectural change is required by this review.
- **Plan: CHANGES_REQUESTED.** Make D1 conditional on that reconciled choice.
  The implementation/validation/publication sequence is otherwise suitable.

## Required change 1 — evaluate LDoc fairly before confirming the renderer

D analysis lines 41–52 compares only minimal Jekyll and Pandoc. The operator's
question about a Lua documentation framework makes omission of LDoc material.
Add a short, source-grounded third alternative and propagate its disposition to
the design and D1. This requires a planning correction, not a prototype, migration,
new generator, or permission to switch frameworks.

The comparison must distinguish these actual options:

1. **LDoc for annotated API documentation.** LDoc supports C/C++ extension doc
   comments with explicit `@module`, `@function`, parameters and returns; C++ is
   not a disqualifier. It also supports standalone `.luadoc` inputs, Markdown
   topics, examples and custom templates. A wholesale code rewrite is not required.
   Here, however, `src/owner.cpp:636` installs names as closures over one dispatch
   function, `lua/libghidra/lowlevel.lua:7` reexports native helpers/factory, and
   `lua/libghidra/init.lua:8–10,32–36,69–87` constructs multiple methods in loops.
   Source parsing alone cannot infer their complete public signatures, policies,
   tuple variants or native field mappings. Explicit documentation annotations
   or generated metadata would be needed. Explain who would own those facts
   without maintaining them again alongside B's API authority.
2. **LDoc as a presentation layer for existing topics/examples.** This is also a
   legitimate incremental possibility, not necessarily a second API generator.
   Assess its Markdown-table backend, topic routes/anchors, backtick reference
   behavior, dependency provisioning and needed link/allowlist adaptations against
   the actual five-page manual. Do not dismiss it by assuming all prose must move
   into annotations. Conversely, do not claim compatibility without checking the
   selected backend/version's behavior.
3. **Jekyll or Pandoc rendering the existing manual.** Both preserve B's authority
   without changing API-generation ownership. Compare bounded adaptation and
   dependencies rather than treating Jekyll's implicit hosted build as its only
   mode: isolated, locked Jekyll built in Actions is a viable native-Pages option.

The existing `scripts/render-fields.lua:5–26` consumes `api/coverage.json` and
emits native model tables. B owns correcting its scalar/enum/model representation
and retaining excluded-schema distinctions. LDoc does not automatically replace
that accounting, and its presence would not establish runtime coverage. Any
future schema-to-LDoc adapter would need a concrete benefit; none is required
for this website. The repository's current approach is Markdown plus custom Lua
inventory/rendering, not an already-adopted LDoc framework.

**Recommended conclusion:** keep Pandoc provisionally for this small existing
manual, with narrowly bounded Lua transformations. LDoc is a credible Lua API
documentation option, but its annotation-driven advantages do not currently
outweigh introducing another metadata contract. Jekyll is credible too, not
mandatory merely because deployment uses Pages. Confirm the choice with the
above comparison; the user's question alone authorizes neither a migration nor
implementation. No new benchmarking campaign or framework evaluation matrix is
needed.

Capability evidence: [LDoc manual](https://lunarmodules.github.io/ldoc/manual/manual.md.html),
especially “Extension modules written in C”, “Markdown Support”, “Readme files”,
and “Which files are processed?”, read during this review. These are capability
facts, not a claim of a tested LDoc integration in this checkout.

## Substantive assessment

- **Small coherent site:** five rendered maintained pages, one local template,
  stylesheet and example download are proportionate. Pandoc earns its dependency
  by handling Markdown tables/code and providing an AST for link transformations;
  a hand-written Markdown renderer would be false economy. The filter is justified
  for source-relative destination mapping and emitted IDs. Do not expand it into
  a second content model or API parser. CMake script-mode export reuses B's list
  without configuring native dependencies; BusyBox is optional preview tooling.
- **User journey:** About → installation → own binary/known function address →
  outcome handling → full reference/fields/notices is clear. Rendering B's actual
  executable provides a readable/downloadable example without a drifting copy.
  B remains responsible for real example execution, explicit hexadecimal address
  selection, native crash caveats, decompile-before-lookup and cleanup semantics.
  D correctly consumes that evidence instead of calling a rendered code block
  native qualification.
- **Navigation/accessibility:** subsystem/model TOCs, both surfaces, direct nested
  URLs, keyboard skip/focus, narrow-screen wrapping, scrollable tables/code and no
  JavaScript form a practical acceptance contract. One H1 must be achieved by
  template/title handling rather than duplicating the source title. The large
  FIELDS page needs the specified model navigation, not a new search service.
- **Artifact boundary:** explicit source/output mappings plus B's exact manifest,
  fail-on-unknown dispositions, byte-exact notices/locks/LICENSE, isolated fresh
  staging and actual output enumeration exclude history/plans/operator material
  by construction. Source-only site instructions and validation reports stay out.
  Do not expand F13 into a ban on repository code, tools or tests. Applying the
  site content gate to the displayed/downloaded user example is appropriate.
- **One authority and provenance:** raw Markdown is not republished as a competing
  manual; HTML is disposable. Fresh field rendering and copied-byte comparisons
  preserve currentness while respecting source-schema versus Lua-support limits.
  Exact notices, author attribution, MIT boundary, native pins/patch provenance,
  incomplete source-delivery qualification and real operational warnings survive.
  Historical review wording is not a public-site acceptance condition.
- **Links:** resolving against original source location before output mapping is
  essential and specified correctly. Base path, canonical URLs, local assets,
  duplicate heading suffixes, explicit anchors, query/fragment preservation and
  percent encoding are covered. Checking actual emitted IDs, not merely predicted
  Markdown slugs, closes the renderer mismatch risk. No external-link reachability
  claim is inferred from offline checks.
- **B dependency:** B r1 requested a concrete manifest/checker caller contract;
  the current B design now names `package-documents.txt` and source/installed/probe
  interfaces. That revision is not independent approval. D appropriately waits
  for accepted B and a sequential helper handoff. Use the accepted manifest and
  shared helper API at integration, not an assumed obsolete probe signature.
  There is no reason to make website-only rendering configure the native build.
- **Workflow security/authority:** read-only PR builds, no persisted checkout
  credentials or `pull_request_target`, reviewed SHA action pins, manual guarded
  default-branch publication, run-local checked artifact, deploy-only Pages/OIDC
  rights and the Pages environment are sound. Explicitly disabling auto-enablement
  and keeping repository settings/push/first publication under separate operator
  authorization prevents local checks from implying publication authority.
- **Executable validation:** future interfaces are clearly labelled as unimplemented.
  Local locked-converter build/check, field freshness, independent second render,
  meaningful negative mutations, exact artifact membership, project-path HTTP
  preview and browser checks are sufficiently concrete for planning. Tools are
  provisioned separately; build/check must perform no network fetch. At execution,
  record how offline operation was established rather than calling a successful
  network-enabled run proof of network isolation. Test root and nested URLs at
  `/lua-libghidra/`; serving only `/` would miss the important deployment case.

## Historical baggage and review-induced complexity

The design correctly avoids publishing the dossier, preserving milestone-based
navigation, inventing redirects for unestablished public routes, or treating
historical source-only evidence as full runtime support. Keeping old evidence in
the repository does not require exposing it in the site. Conversely, real native
crash/loader/ownership/persistence restrictions and license provenance are not
obsolete review baggage and must remain prominent.

This review requests one bounded alternative-treatment correction. It does not
justify additional page hierarchies, themes, API generators, redirect systems,
runtime qualification campaigns or approval machinery. The existing checker
mutation cases defend actual publication boundaries and link correctness; avoid
turning them into a generic HTML/Markdown framework. Reuse B's helper where it
fits and validate the renderer's output where its semantics differ.

## Inspection limits

Read project/workspace AGENTS guidance, README, SPEC/DESIGN/COVERAGE/PLAN, all
requested audit records, B drafts and B r1, and all three D drafts. Inspected the
actual Lua exports, C++ registration/dispatch location and field renderer; read
the upstream LDoc manual. No implementation, build/test execution, GitHub settings
inspection, publication, runtime control, commit or push was performed. Only this
review report was written. All proposed checks remain future acceptance work.

VERDICT: CHANGES_REQUESTED
