# Static project website — selected design

Planning only, 2026-10-16; baseline `4903eb7`. Implement after accepted batch B.
No implementation, settings change, push or deployment is authorized by this file.

## Renderer decision

Use **Pandoc with bounded Lua presentation filters**. The analysis compares
annotated LDoc, LDoc topics-only, explicitly locked Jekyll in Actions and Pandoc.
LDoc can document this C/C++ binding using comments or standalone `.luadoc`
without rewriting dispatch loops; it can also render existing topics/examples
without becoming a second API generator. Its topics mode would still require
pinned table-backend/dependency provisioning, suppression of backtick reference
expansion and adaptation of topic routes, section IDs and code prettification.
Locked Jekyll also preserves B's authority and controlled Actions artifacts, but
adds Ruby/gem and staging/front-matter integration. Pandoc's GFM parser and Lua AST
interface are the smallest coherent fit selected for these five maintained pages.
No annotation migration, new schema generator or replacement of B's field tooling
is part of this design. The choice is settled at planning level, conditional only
on the selected pinned release meeting the stated validation contract later; a
failure requires reporting a bounded blocker, not an automatic framework switch.

## 1. Single source and exact layout

B remains owner of maintained content, package selection, generated field schema,
notices and example semantics. D owns presentation, URL conversion, website
toolchain and artifact verification. Future new source files:

```text
site/README.md                  contributor build/preview/publication instructions; never deployed
site/toolchain.lock.json        converter version, platform, release URL, SHA256, license
site/content.lua               explicit page routes, navigation, extra example and asset entries
site/export-documents.cmake     script-mode export of B's LLG_PACKAGE_DOCUMENTS
site/template.html             one accessible HTML layout, no product narrative
site/style.css                 local responsive stylesheet
site/links.lua                 Pandoc Lua filter for links and stable heading IDs
scripts/build-site.lua          stage/render; no native configuration or execution
scripts/check-site.lua          output, graph, freshness and content checks
scripts/preview-site.sh         optional loopback BusyBox HTTP preview wrapper
tests/site_contract.lua         focused checker/transformation mutation cases
.github/workflows/site-check.yml
.github/workflows/site-publish.yml
```

All build products go to a caller-selected disposable directory outside source
inputs; no generated HTML is committed. No recursively copied source directories.
`content.lua` lists five page mappings explicitly:

| Maintained input | Output relative to site root |
| --- | --- |
| `README.md` | `index.html` |
| `docs/EXAMPLES.md` | `docs/EXAMPLES.html` |
| `docs/API.md` | `docs/API.html` |
| `docs/NOTICES.md` | `docs/NOTICES.html` |
| `api/FIELDS.md` | `api/FIELDS.html` |

The exporter includes only B's manifest, writes `package-documents.txt` in its
explicit site-build work directory using B's newline-list format, and does not run
the top-level CMake project. D reads that list rather than maintaining a second
package-document inventory. Every entry must be either one of the five rendered
pages or an explicitly recognized passthrough class: `LICENSE`, the three named
root locks, and the exact notice entries selected by B. New manifest entries
require an explicit D disposition; unknown entries fail. Copy passthrough files
byte-for-byte at their existing relative paths. Do not deploy raw Markdown pages.

Additional website inputs are individually enumerated: `site/style.css` becomes
`assets/style.css`, and B's `examples/decompile.lua` becomes the byte-exact
download `examples/decompile.lua`. Render that complete example as an escaped
code block appended to the guide with a download link; derive it from the same
file, never maintain another script/snippet. B's guide retains the sole narrative
and installed usage instructions. No fixture scripts are implicitly published.
Emit only the five HTML pages, passthrough files, stylesheet, example and empty
`.nojekyll`. Keep source hashes/output-map validation reports outside the artifact.

Reject duplicate/colliding routes, absolute or parent-escaping entries, symlinks,
missing files and paths whose resolved target leaves the checkout. Reject output
inside any source input tree. Build into a fresh staging directory, verify it,
then make that directory the sole artifact input; never upload the checkout.

## 2. Navigation and URLs

Global navigation: About (landing), Install/Quickstart/Examples (guide sections),
API, Native fields and Notices. Generate the in-page table of contents from each
page's actual headings, including all API subsystem sections and model headings.
API must link both surfaces and all supported operations; FIELDS retains clear
included/excluded schema distinctions. D does not infer Lua support from models.

Use one H1, semantic header/nav/main/footer, a visible-on-focus skip link, visible
keyboard focus, sufficient color contrast, meaningful link text, readable line
length and CSS wrapping. Navigation wraps at narrow widths without a scripted
menu; wide tables/code have labeled horizontal-scroll containers, without forcing
the whole viewport sideways. Use system fonts; no remote assets, analytics or JS.

Configure origin `https://salva.github.io` and base path `/lua-libghidra` explicitly.
Canonical URLs include the base path. Internal href/src values are page-relative
and computed from the output map; no domain-root `/docs`, `/api` or `/assets`
links. README-relative and nested-doc-relative links resolve against the **source
file** before being mapped to output. Preserve query/fragment components, encode
paths correctly and validate fragments after rendering. Links to README become
index.html. Notice/lock/download links retain their mapped raw targets.

Use GitHub-style heading IDs consistent with B's maintained Markdown checker,
including duplicate-heading suffixes; implement them once in the shared Lua
document helper where practical. The filter sets IDs explicitly. Explicit source
anchors, reference links, images and fragment-only links must be supported or
fail with a precise unsupported-syntax error, never silently bypass validation.
No rewriting code spans/fences or raw notice bytes. Reject active HTML/script and
unrecognized local URL forms; permit only the documented inert anchor markup.
External https links stay external; inventory them without fetching them in the
required checks. B's optional exact-revision developer-source link may remain a
secondary external link; it must not cause any developer material to be staged.

## 3. Content and freshness gates

Use B's exact source-check interface:
`lua5.4 tests/installed_documents.lua source SOURCE_ROOT MANIFEST`, with absolute
SOURCE_ROOT and the site export's absolute `package-documents.txt` path. B owns
this interface and the shared graph/content helper; source mode checks only
selected files, not absence of other checkout material. Agree script-mode export
compatibility sequentially with B; never guess another build's manifest. B's
`installed DOCUMENT_ROOT SOURCE_ROOT MANIFEST` and shell mutation-probe contracts
remain native-package checks, not an HTML-checker interface. Consume the future
accepted B contract if refined, with explicit reconciliation rather than fallback
to obsolete signatures.

Use B's shared final-doc scanner on selected source bytes and decoded rendered
text, attributes, comments and downloadable bytes. Case-insensitive Saivage,
card/record/work URI and card-marker exclusions apply to the entire artifact,
including template, paths and metadata. Permit only the exact optional sentence
`Saivage was used in creating this project.` once in README's acknowledgment
section and its corresponding single rendered landing-page paragraph. No global
substring/path exemption and no hidden alternate wording. Scan raw HTML too;
entity encoding must not evade the decoded check. Preserve exact license bytes:
an actual conflict blocks acceptance pending resolution, not silent rewriting.

The checker enumerates actual regular files and compares them with the computed
allowlist exactly, hashes copied notices/locks/example/license, and verifies every
rendered source hash against the current checkout. Rebuild to a second fresh
directory and compare outputs to detect stale manual text; avoid current-time or
machine-path metadata. Use the same checkout for fields, prose and code. Require
`lua5.4 scripts/render-fields.lua --check` before rendering; D never regenerates
FIELDS independently or consumes historical ledgers. B remains responsible for
fresh source-ledger generation against the pinned upstream source.

Preserve B's warnings prominently, especially known-address selection/crash
limits, outcome versus presence, one owner/process, ABI, persistence/no rollback,
ignored protections/deadlines, unsupported loaders, schema/support distinctions,
and build-only Python exception. Keep wrapper MIT boundary, upstream author and
nonendorsement, exact upstream license, patch/provenance and substantive third-
party/source obligations. No link to an incident dossier substitutes for a warning.

## 4. Toolchain and workflow boundary

Prerequisites: Lua 5.4, CMake >=3.26 in script mode, and a qualified pinned Pandoc
release supporting GFM input, standalone HTML and Lua filters. Select an actual
release during implementation and commit its exact version, linux-amd64 archive
URL and SHA256 in the website-only lock; do not invent a hash in this plan. Verify
archive hash before extraction, verify executable version, and permit an explicit
matching local executable for offline use. Record system Lua/CMake versions in
validation output. No floating latest download, implicit converter upgrade or
native lock changes. Pandoc's dependencies are contained in the selected release;
there is no gem/npm/theme dependency graph. Preview additionally requires BusyBox
with httpd; it is optional and never a native package prerequisite. Build/check
are offline once tools are installed. Tool download is a separate explicit step.

Plan two workflows. `site-check.yml` runs build/check on pull_request and default-
branch push, read-only `contents: read`, checkout without persisted credentials,
no secrets, no deployment and no pull_request_target. Pin every action to a
reviewed full commit SHA (with release comment); pin runner OS family/version and
use the locked converter. Upload a checked artifact only if desired for review.

`site-publish.yml` is initially manual workflow_dispatch only, restricted by an
explicit default-branch guard; no automatic push deployment. Its build job repeats
the same offline build/check using the selected commit and has contents: read.
Only its deployment job gets pages: write and id-token: write, consumes that run's
checked Pages artifact, and uses the github-pages environment. Pin checkout,
Pages artifact upload and Pages deploy actions by full SHA; configure-pages, if
needed, must not auto-enable Pages. Never deploy artifacts from fork PRs or an
untrusted workflow_run. A shared publication concurrency group serializes runs
with cancel-in-progress false. Display the deployed URL from the deploy step.

Operator must separately authorize pushing the implementation, select GitHub
Actions as Pages source if necessary, review environment branch protections and
authorize the first manual deployment. Implementation/local CI success does not
perform or imply any of these. No custom domain/DNS changes. Do not advertise the
target URL as live in README until actual authorized publication is verified.
