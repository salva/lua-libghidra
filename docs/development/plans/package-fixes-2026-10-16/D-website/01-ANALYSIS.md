# Static project website — analysis

Planning baseline: production `4903eb7`, 2026-10-16, with subsequent audit and
design records. Scope: owner feature F14 and website application of F13. This
contract proposes work; it authorizes no implementation, commit, push, settings
change or publication. Paths are repository-relative.

## User outcomes

A visitor should identify the native-local Lua binding, its supported profile and
qualified status, install it, decompile a known function in their own supported
binary, and find every public call and applicable warning without reading project
history. Advanced readers need both Lua surfaces, exact values and errors, linked
native fields, lifecycle/persistence limits, and complete license/notice access.
The site must remain usable on narrow screens, with a keyboard and without JavaScript.

The repository is `https://github.com/salva/lua-libghidra`. The intended project
site is `https://salva.github.io/lua-libghidra/`: origin
`https://salva.github.io`, base path `/lua-libghidra`. Pages enabled state, source
mode, environment protections and existing deployment are **unverified**. No
GitHub interaction is needed to complete this plan. The URL is a target, not a
claim of current availability. Publication requires later explicit authority.

## Current facts and dependency

README currently leads into qualification, specifications and operator material.
The audit identifies missing installation/own-input continuity and mixed current
and historical contracts. Merely publishing the docs directory would expose that
problem and deploy audit/planning material. A repository-wide static build with
an exclusion list is not an adequate content boundary.

Batch B owns the primary content solution: README, `docs/EXAMPLES.md` as compact
guide, `docs/API.md`, `docs/NOTICES.md`, generated `api/FIELDS.md`, root license,
three native locks and explicitly listed exact notices. Its planned
`cmake/PackageDocuments.cmake` defines `LLG_PACKAGE_DOCUMENTS`. It also owns the
new `examples/decompile.lua`, field generation fixes and document-content checks.
These are proposed interfaces, not files asserted to exist at baseline. B's
independent review may refine them. D must reconcile against accepted B before
integration; it must not freeze an obsolete B draft or duplicate its work.

## Alternatives

| Approach | Benefits | Costs and suitability |
| --- | --- | --- |
| Minimal Jekyll built explicitly in Actions, no remote theme, isolated allowlisted staging input | Familiar Pages ecosystem, Markdown/layout support, simple CSS; explicit build gives toolchain and artifact control independently of GitHub's implicit hosted builder | Pin Ruby/Jekyll and commit Gemfile.lock with transitive gems; configure the chosen Markdown backend, stage layout/front matter without editing B's pages, and map routes/links/heading IDs. Fully viable with the same manifest and publication controls; neither implicit hosted building nor the full github-pages gem bundle is required. |
| LDoc annotated API plus topics/examples | Lua-oriented module/function navigation, C/C++ comments or standalone .luadoc inputs, parameters and alternative returns, integrated prose/examples and custom templates | Explicit annotations can document dispatch-generated methods without rewriting code. However, adopting annotations as another maintained API authority alongside B would duplicate contract ownership; replacing B's authority or generating annotations from it is additional scope needing a concrete benefit. |
| LDoc as presentation for the existing five Markdown topics and example | Reuses B's prose and FIELDS unchanged as authorities; no API annotation migration or second API generator is intrinsically required | Pin LDoc and a table-capable Markdown backend/dependencies; adapt topic routes, heading IDs, reference processing, code-language treatment and layout. Retain explicit staging and copied notices/downloads. Its module-oriented advantages are less useful for five existing prose/reference pages. |
| Explicit Pandoc conversion with small Lua driver/filter and one local HTML template | One pinned converter, project-owned Lua tooling, explicit input/output map, link/heading transformation in an AST, no theme plugins or frontend runtime | Adds a documentation-only Pandoc executable and bounded transformation/check tooling; heading IDs must be checked against actual emitted HTML. |

### LDoc capabilities and adaptation boundary

The official [LDoc manual](https://lunarmodules.github.io/ldoc/manual/manual.md.html),
read 2026-10-16, documents “Extension modules written in C”, “Which files are
processed?”, “Markdown Support”, “Readme files”, “Examples” and “See References”.
It explicitly supports C/C++ comments with `@module`, `@function`, parameters and
returns, standalone `.luadoc`, Markdown topics, examples and custom templates.
These are capability facts, not a tested/pinned LDoc integration in this checkout.

Here `src/owner.cpp:636` registers operation names as closures over one dispatcher;
`lua/libghidra/lowlevel.lua:7` reexports helpers/factory and `init.lua:8–10,32–36,
69–87` constructs methods in loops. That limits automatic signature inference,
not documentation feasibility: explicit comments or standalone annotations can
express names, policy, tuple variants and errors without restructuring code.
B must remain sole owner of those facts. This site task neither introduces a
parallel annotation contract nor transfers B's API authority into annotations.
`scripts/render-fields.lua:5–26` consumes B-owned `api/coverage.json` to produce
native model tables. Neither LDoc mode replaces that generator, its included/
excluded-schema distinctions or its source-only evidence meaning. A schema-to-
LDoc adapter is possible but has no required benefit for this scope.

For topics-only use, the manual documents bundled markdown.lua, lua-discount,
lunamark and commonmark backends; specifically it identifies lua-discount's
PHP-Extra tables. Do not assume bundled Markdown or plain CommonMark accepts all
current pipe tables, escaped cells and fenced blocks. A chosen LDoc release and
backend would need exact pins and representative compatibility checks. Its
documented fallback to another available processor must be prevented/detected
so output does not depend on ambient packages. Lock LDoc, the selected backend
and actual transitive Lua/native dependencies from that release's package
metadata; a discount choice includes its C-library/binding provisioning. No exact
dependency closure or working backend version has been qualified here.

LDoc topics normally live under a topics directory; documented section references
use underscore-style normalization, unlike GitHub-style fragments. Its default
backtick references can turn code identifiers into links, including external Lua
manual links. A topics renderer would disable that behavior explicitly, preserve
ordinary Markdown links, map source-relative destinations and emitted anchors,
and check reference/image links and duplicate headings in actual HTML. The manual
also describes Lua-oriented code prettification (including non-C fence language
treatment); shell recipes must remain literal shell text, not accidental Lua
references. Template/staging adaptations can handle these concerns without
changing the maintained manual. Exact allowlisting, raw notice/example copying,
project-base paths and output checking are necessary with every alternative.

### Selected renderer

Select **Pandoc/Lua** for the actual five-page manual: a single converter with
GFM tables/fences and a documented AST transformation interface directly fits
the needed presentation work. LDoc topics-only is credible, not duplicate API
generation, but requires backend/reference/topic adaptation without using its
principal annotated-module strengths here. Explicit locked Jekyll is likewise
credible; Ruby/gem provisioning and staging/front-matter/link handling do not
offer a needed advantage for this small existing manual. This is a bounded
maintenance judgment, not a benchmark or assertion that either alternative
cannot work. The renderer choice is resolved for this plan; no prototype,
framework migration or further comparison campaign is required. Exact Pandoc
version qualification remains a future implementation check, not an open choice
among frameworks. If it cannot meet the contract with bounded transformations,
report the specific blocker for a revised decision rather than silently switching.

Use no application framework, no browser JS,
no search service, no theme package, no second native API parser. CMake only
exports B's manifest in script mode; native configure/build requirements do not
change. A hand-built Markdown parser is not a smaller reliable alternative given
tables, links, code and the complete field reference.

## Historical baggage and non-goals

Retain source history and notice facts, not old incident dossiers in the site.
Milestone delivery order must not become navigation or imply current package
variants. Do not carry approval conversations, operator work paths or process
identifiers into rendered prose, comments, metadata or downloads. The optional
single exact creation credit is the sole F13 exception. Exact licenses must not
be redacted to pass scanning; any actual conflict requires explicit resolution.

No published old route is established here, so do not invent a redirect system,
version selector or compatibility pages. Keep existing maintained source paths
and stable section IDs; generated HTML is disposable presentation, not a second
manual. Website success establishes documentation delivery, not new runtime
qualification, release approval, legal clearance or corresponding-source delivery.

## Evidence limits

This analysis reads the required contracts, audit, B drafts, relevant export/
renderer source and the official LDoc manual. It does not run
native qualification, check online links, verify Pages state, build a site or
claim publication. The accompanying design and plan define future acceptance.
