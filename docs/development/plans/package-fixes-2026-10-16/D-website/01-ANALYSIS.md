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
| Minimal Jekyll, no remote theme, isolated allowlisted staging input | Familiar Pages ecosystem, Markdown/layout support, simple CSS | Ruby/Bundler plus locked gems; Markdown anchor differences and generated link rewriting still need deliberate handling. Default branch-root or docs-root publishing is unsuitable. GitHub's implicit build offers less explicit toolchain control. Viable if maintainers already use Jekyll. |
| Explicit Pandoc conversion with small Lua driver/filter and one local HTML template | One pinned converter, project-owned Lua tooling, explicit input/output map, link/heading transformation in an AST, no theme plugins or frontend runtime | Adds a documentation-only Pandoc executable and bounded transformation/check tooling; heading IDs must be checked against actual emitted HTML. |

Select the second: a single converter, no application framework, no browser JS,
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

This analysis reads the required contracts, audit and B drafts. It does not run
native qualification, check online links, verify Pages state, build a site or
claim publication. The accompanying design and plan define future acceptance.
