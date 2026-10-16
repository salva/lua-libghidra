# Documentation audit — 2026-10-16

## Scope and verdict

Baseline: `4903eb7441242a742ffa97d502eb6fc7735c2355`. Independent documentation audit only. This report proposes changes; it does not reorganize documents, change product requirements, approve release/publication, or make legal determinations.

**The repository contains substantial, careful contract and limitation documentation, but its primary reading path is a development/qualification dossier rather than a usable package manual.** A new user cannot follow one clear route from installation to decompiling their own binary. Full implementation is documented, but core-first headings, obsolete commands and append-only progress reports obscure the present package. Preserve the evidence; separate its audience from users.

Read: project AGENTS, README, all top-level `docs/*.md`, complete `api/FIELDS.md`, `api/coverage.md`, `api/README.md`, review index, examples and fixture README, LAUNCH/OPERATIONS; inspected CMake documentation inputs and selected Lua/C++ surface/conversion code to check specific documentation claims. Historical individual reviewer reports and raw evidence logs were not substantively re-audited. No build, installation, Lua/native execution, upstream investigation or runtime control was performed. Qualification results below are **claims recorded by the existing reports**, not newly reproduced results.

Priority: **P1** blocks or materially misleads the first-use journey; **P2** impairs reference accuracy, navigation or maintainability. None of the findings requires upstream repair.

## New-user journey

| Step | What the reader currently encounters | Assessment |
| --- | --- | --- |
| Choose platform/package | README gives Linux x86-64 / Lua 5.4 and full adapters, then links qualification, core API, specification, plan and operations. | Useful scope, but no “start here”, installation link or short working example. |
| Install | Commands exist in PACKAGE-FOUNDATION, M1-BOUNDARY and NATIVE-READINESS; SDK/source choices and prepared inputs are dispersed. | A user must reconstruct a development environment and understand card work roots before reaching `require`. |
| Load module | EXAMPLES supplies `LUA_PATH`/`LUA_CPATH`, but assumes `$prefix` and a checkout-backed fixture root. | Useful installed-path detail, disconnected from installation and LuaRocks tree selection. |
| Open own binary | SPEC supplies exact option grammar. Main example requires `fixture_manifest`; executable additionally opens the authored project. | No parameterized binary/address example; no compact explanation of obtaining a known mapped function address and selecting explicit hints. |
| Decompile | Executable decompiles first and checks completed/nonfallback arithmetic; prose looks up a function before decompiling and checks only record presence. | The most prominent copyable example is a poor template for a fresh binary. |
| Handle errors/limits | API and SPEC explain tuples, `check`, ownership and ignored options; detailed crash/producer/persistence observations live in M2–M4 reports. | Technically valuable, but important operational caveats require hopping through milestone narratives. |
| Use advanced operations | Full grammar is in M4-FULL; core grammar is in M3-CORE; first slice is in SPEC; FIELDS is a native schema. | Complete facts exist, but users need historical stage knowledge to find accepted syntax. |

## Prioritized findings

### D01 — P1: no end-to-end installation and first-use entry point

**Evidence:** [README.md#L12-L20](../../../../README.md#L12-L20) has no install/quickstart entry; [PACKAGE-FOUNDATION.md#L7-L32](../../../../docs/PACKAGE-FOUNDATION.md#L7-L32) requires an existing local SDK and `$SAIVAGE_CARD_WORK_ROOT`; [M1-BOUNDARY.md#L6-L24](../../../../docs/M1-BOUNDARY.md#L6-L24) holds the CMake wrapper recipe; [PACKAGE-FOUNDATION.md#L84-L105](../../../../docs/PACKAGE-FOUNDATION.md#L84-L105) holds current input preparation. [INSTALLED-FULL.md#L95-L114](../../../../docs/INSTALLED-FULL.md#L95-L114) is a card artifact/reproduction map, not installation instructions.

**Impact:** someone with a fresh checkout cannot tell which instructions are prerequisites, how to obtain/prepare the pinned inputs, which route avoids the source generator, or how the resulting prefix reaches Lua. Internal work-root variables look like product dependencies.

**Remedy:** publish one installation guide with the supported Ubuntu/Linux/Lua profile, prerequisites, explicit caller-owned absolute build/install directories, pinned-input preparation, source CMake/source LuaRocks routes, and optional already-qualified SDK routes. Define every variable, describe explicit network preparation versus disconnected build, show installation-to-`require` verification and ordinary LuaRocks search-path setup. Link directly from README. Preserve patch/profile provenance, dependency notices and source-build Python requirement without requiring operator-workflow terminology.

**Proportionate alternative:** add a short README route selector and a current command-only section atop PACKAGE-FOUNDATION, with defined local variables and direct links to prerequisites. No new documentation framework is necessary.

**Claim accuracy:** the existing reports describe all four source/SDK × CMake/LuaRocks routes as completed local qualification ([INSTALLED-FULL.md#L29-L55](../../../../docs/INSTALLED-FULL.md#L29-L55)); missing user instructions are not evidence that those routes fail. Packaging correctness belongs to the package reviewer.

### D02 — P1: installed examples are qualification fixtures, and the prose sequence differs materially

**Evidence:** [EXAMPLES.md#L11-L37](../../../../docs/EXAMPLES.md#L11-L37) imports `fixture_manifest`, opens only its binary and immediately asserts function lookup; decompilation occurs later at [L57-L59](../../../../docs/EXAMPLES.md#L57-L59). The document itself explains lazy discovery only at [L104-L122](../../../../docs/EXAMPLES.md#L104-L122). By contrast, [first_slice.lua#L8-L22](../../../../examples/first_slice.lua#L8-L22) opens a project as well as the ELF, decompiles before lookup and asserts fixture-specific arithmetic/bytes. [fixture_manifest.lua#L2-L8](../../../../examples/fixture_manifest.lua#L2-L8) requires checkout paths and fixed addresses. The project fixture uses a special no-FileBytes external-ELF route ([fixture README#L19-L35](../../../../tests/fixtures/README.md#L19-L35)).

**Impact:** the “first example” is not equivalent to the installed executable, and adapting it to a newly opened binary can hit `NOT_FOUND` before any decompilation. Installation alone cannot satisfy the examples. The fixture dependency is disclosed, but late and without a direct fixture-provenance link. Readers can mistake a special project profile for generic Ghidra project support.

**Remedy:** add a small standalone example accepting binary path and known mapped function address, explicit language/compiler hints, and optional external specs. Show `require`, `open`, checked UInt64 conversion, decompilation, handling `nil,error` separately from present `completed=false`, checking `is_fallback`/`error_message`, printing `pseudocode`, and deterministic close. Explain that addresses are native virtual addresses, not assumed file offsets, and that ordinary binary open does not eagerly discover functions. Place the crash/address limitation beside address selection. Keep existing fixture programs as labeled regression demonstrations, with exact prerequisites and their own invocation.

**Proportionate alternative:** make EXAMPLES' leading snippet match the checked executable, put fixture requirements first, and add a short separate own-binary snippet. A user need not build an analyzed project merely to decompile a known binary function.

**Claim accuracy:** no new execution was attempted. The ordering problem follows both the documented lazy-discovery behavior and the differing source sequences. Do not claim a copied snippet was run or that arbitrary binaries/addresses are qualified.

### D03 — P1: historical build recipes remain plausible current instructions, including deleted commands

**Evidence:** [NATIVE-READINESS.md#L19-L36](../../../../docs/NATIVE-READINESS.md#L19-L36) says “Reproduce” and invokes `scripts/prepare-native.py`; its “current result” section also invokes retired Python helpers ([L177-L191](../../../../docs/NATIVE-READINESS.md#L177-L191)). Those three referenced paths (`prepare-native.py`, `check-native-patched.py`, `check-native-profile-inputs.py`) were checked and are absent at the baseline. Current Lua cutover is documented at [PACKAGE-FOUNDATION.md#L294-L309](../../../../docs/PACKAGE-FOUNDATION.md#L294-L309), but that file's earlier migration sections still describe successive incomplete states ([L156-L167](../../../../docs/PACKAGE-FOUNDATION.md#L156-L167), [L270-L292](../../../../docs/PACKAGE-FOUNDATION.md#L270-L292)). The final sentence still mentions discharging an embedding decision request despite the explicit accepted decision at [L78-L82](../../../../docs/PACKAGE-FOUNDATION.md#L78-L82).

**Impact:** a reader following build references can invoke nonexistent files or reopen already-resolved tooling/permission questions. “Current” has multiple historical meanings inside a single document.

**Remedy:** extract maintained build/tooling commands into developer/install guides; label the remaining reports with their evidence revision and “historical, commands may not exist at current HEAD”, plus a current replacement link. Preserve historical commands verbatim in the archive rather than silently rewriting the experimental record.

**Proportionate alternative:** a top-of-file historical banner and direct Lua replacements, with every “current result” heading qualified by revision/date. `api/coverage.md` already has a useful historical banner ([L1](../../../../api/coverage.md#L1)); use that pattern consistently.

**Claim accuracy:** source-build Python is still a real prerequisite; owned Python tooling retirement does not remove the unchanged upstream generator. The issue is obsolete instructions and policy chronology, not a proposal to remove Python from upstream.

### D04 — P2: full implementation, core labels and source-only qualification labels are interleaved

**Evidence:** [README.md#L5-L9](../../../../README.md#L5-L9) says full adapters are implemented; [API.md#L1-L6](../../../../docs/API.md#L1-L6) calls the package a core binding, then adds full methods at [L95-L112](../../../../docs/API.md#L95-L112). [EXAMPLES.md#L1-L7](../../../../docs/EXAMPLES.md#L1-L7) still says “Proposed Lua usage”. SPEC and DESIGN link “current qualification” to core ([SPEC.md#L3-L6](../../../../docs/SPEC.md#L3-L6), [DESIGN.md#L3-L6](../../../../docs/DESIGN.md#L3-L6)). PLAN calls later implementation qualification/tool migration outstanding ([PLAN.md#L191-L197](../../../../docs/PLAN.md#L191-L197)); [INSTALLED-FULL.md#L39-L55](../../../../docs/INSTALLED-FULL.md#L39-L55) records completed tooling and full installed routes. The ledger intentionally retains historical approved/proposed syntax classifications ([api/README.md#L3-L8](../../../../api/README.md#L3-L8)).

**Impact:** users cannot reliably infer whether “full” is available, planned, tested, or separately installable. They must understand the distinction between historical tiers, implemented methods, generated source facts, writer qualification and independent acceptance before making a call.

**Remedy:** one current status/support page: implemented full native-local surface; supported platform/profile; available facade subset; excluded operations; known limitations; separately dated qualification/release status. Rename the public API reference to full/current Lua API, organize by subsystem/surface and link exact signatures directly. Treat “slice/core/full” as historical delivery labels unless they correspond to actual supported package variants. Keep generated source facts unqualified; link them to accepted grammar instead of changing their evidence meaning.

**Proportionate alternative:** correct front matter and navigation, then add a single current operation index pointing to SPEC/M3/M4 anchors. It can precede extraction into subsystem reference pages.

**Claim accuracy:** existing full implementation/qualification claims do **not** establish independent M5 acceptance or publication approval. Those remain explicitly separate in [INSTALLED-FULL.md#L116-L126](../../../../docs/INSTALLED-FULL.md#L116-L126). Conversely, historical pending M0/M3 prose is not evidence that the full code is absent. README's “pending review” description also does not describe the converged historical documentation review ([review index#L3-L12](../../../../docs/reviews/00-INDEX.md#L3-L12)).

### D05 — P2: a few current reference claims contradict the actual surface/type representation

**Evidence A:** [M4-FULL.md#L141-L148](../../../../docs/M4-FULL.md#L141-L148) explicitly says all full specialist calls, including Shutdown, use `native()` and none creates a Session convenience; [FULL-CROSSWALK.md#L84](../../../../docs/FULL-CROSSWALK.md#L84) repeats native-only disposition. Yet [lua/libghidra/init.lua#L8-L11](../../../../lua/libghidra/init.lua#L8-L11) directly exposes Session `shutdown` and `open_program`. [M3-CORE.md#L26-L41](../../../../docs/M3-CORE.md#L26-L41) also omits the already-exposed `get_revision` from its core grammar table; the crosswalk names it but does not supply a precise return shape there.

**Evidence B:** [FIELDS.md#L963-L972](../../../../api/FIELDS.md#L963-L972) describes `RevisionResponse.file_version` as `std::int32_t table/enum; resolve in types/enums`; its actual converter passes that scalar to `field` ([owner.cpp#L173](../../../../src/owner.cpp#L173)), with integer overloads ([boundary.cpp#L99-L102](../../../../src/boundary.cpp#L99-L102)). Enum entries similarly use generic “table/enum” wording ([FIELDS.md#L149-L155](../../../../api/FIELDS.md#L149-L155), [L226-L244](../../../../api/FIELDS.md#L226-L244)) although the public contract uses lowercase strings/unknown numeric values ([SPEC.md#L125-L130](../../../../docs/SPEC.md#L125-L130)).

**Impact:** users can conclude that callable methods are absent or write type checks for nonexistent table/enum values. FIELDS is exhaustive source schema, including unsupported models, not yet an unambiguous Lua reference.

**Remedy:** reconcile intended public surface against the actual exports and record an explicit disposition for existing Session conveniences (including their native save-policy caveats); document `get_revision()` and envelope. Correct representation generation at its source, not just the rendered file; provide explicit enum names/numeric fallback and model anchor links. Distinguish included versus excluded models in navigation.

**Proportionate alternative:** add a precise public-surface exception table and a prominent field-manifest errata note until generated output can be corrected in its owning review. Do not silently remove working methods as an editorial fix.

**Claim accuracy:** this is static source corroboration, not a new runtime test or a conclusion about whether the extra facade methods should be supported. That contract decision belongs to the API owner.

### D06 — P2: practical limitations are preserved, but mixed with incident/review instructions

**Evidence:** [API.md#L72-L79](../../../../docs/API.md#L72-L79) correctly warns about category loss, ignored protection/deadline settings and crash limits, but routes details to milestone reports. [M2-SLICE.md#L64-L100](../../../../docs/M2-SLICE.md#L64-L100) combines the crucial native SIGSEGV, repeated-failure state and default-field limitations with GDB attribution and test-hypothesis history. [M4-FULL.md#L195-L250](../../../../docs/M4-FULL.md#L195-L250) mixes useful persistence/batch behavior with an exploratory overlay attempt. [NOTICES.md#L56-L84](../../../../docs/NOTICES.md#L56-L84) contains practical user/distributor obligations, followed by internal decision IDs and no-push instructions at [L86-L92](../../../../docs/NOTICES.md#L86-L92).

**Impact:** readers must distinguish actionable limits from instructions to a past Executor/Reviewer. Important warnings lose salience through repetition. A short manual must not achieve brevity by deleting the limits.

**Remedy:** maintain a user limitations/troubleshooting page organized by symptom/operation and affected profile. Preserve: unsupported extreme-address safety, raw/FileBytes route limits, one owner per process/no independent-engine mixing, Lua ABI restrictions, cache requirements, ignored timeouts/read-only/metadata, lazy discovery/default fields, pages-only families/candidate offsets, constant-empty strings, nonpersistent overlays/category loss, no rollback/atomicity, and dependency-OOM recovery exclusions. Explain practical consequences, link detailed immutable evidence secondarily. Keep attribution, exact licenses/notices, source links and pre-conveyance obligations in an accessible notices section. Move planning approvals, card-specific imperatives, failed hypotheses and repair chronology to historical/operator documentation.

**Proportionate alternative:** add a consolidated limitations index with concise summaries and exact anchors before splitting reports. Retain NOTICES in the main user navigation; only extract process material, not obligations or qualifications.

**Claim accuracy:** current limitations are supported by the reports' bounded observations; do not generalize fixture results to every input, or relabel unknown failures upstream. This audit neither resolves licensing questions nor proposes additional upstream debugging.

### D07 — P2: installed-document audience is an undifferentiated source dossier

**Evidence:** [cmake/Binding.cmake#L143-L152](../../../../cmake/Binding.cmake#L143-L152) installs the entire `docs` and `api` trees alongside README/locks/license. This includes historical milestone reports, research ledger, all review rounds and raw evidence, while the landing README puts specification/plan/review/operations beside API/examples ([README.md#L12-L20](../../../../README.md#L12-L20)). Historical reports contain card-only URIs ([INSTALLED-FULL.md#L33-L48](../../../../docs/INSTALLED-FULL.md#L33-L48)) and developer recipes pointing outside that document tree.

**Impact:** an installed user is presented with an archival development packet rather than a distinct manual. Generic recursive installation also makes any new `docs/history` report part of the input set. Moving files into `history/` alone would not define the installed audience.

**Remedy:** define user manual/reference/notices as the ordinary installed-document entry point and developer/history material as a separately indexed source/audit collection. Ask the packaging reviewer to implement an explicit content policy and preserve link closure once approved. Keep legal notice texts and locks/provenance needed for practical obligations available even if historical logs are separated.

**Proportionate alternative:** retain the full source handoff collection but add a clear installed index with “Users”, “Developers”, and “Historical evidence” sections. Do not require archival reading to follow a user task.

**Boundary:** only documentation inputs/audience were inspected here. No staging install, package-content correctness or installed-link validation is claimed.

## Navigation/path checks performed

- A read-only check resolved **158 relative inline Markdown links in 51 files**: README, top-level docs, all `docs/reviews/*.md`, `api/*.md`, fixture README and top-level workflow Markdown. No missing filesystem target or mismatched heading slug was reported in that set. Heading matching used a simple GitHub-style slug approximation; this was not rendered-browser validation, a reference-link parser or a guarantee about every anchor syntax.
- API's first-slice, core-grammar and persistence anchors and FIELDS' M3/M4 grammar anchors match the inspected headings. No broken source-checkout anchor finding is invented.
- Separately checked the three obsolete Python command paths identified in D03; all are absent. These are fenced command references, so a Markdown-link checker does not detect them.
- [DESIGN.md#L10-L17](../../../../docs/DESIGN.md#L10-L17) presents `src/client.*`, `src/convert/` and `src/bindings/` as architecture locations. Checked `src/client.cpp`, `src/convert` and `src/bindings`: absent. The actual owner/converter files inspected are `src/owner.cpp`, `src/boundary.*`, `src/core_convert.hpp`, `src/slice_convert.hpp`. Update the maintained implementation map or explicitly label the old map a proposal (P2, developer-facing).
- `work:///`, `record:///` and `[[card:...]]` are workflow references, not ordinary checkout navigation. They were not resolved. External URLs, upstream license links, installed-tree links and artifact availability were not network-validated. No statement of general link validity follows from the limited local check.

## Historical-baggage and evolutionary-bias analysis

The documentation grew by adding a correction beneath an earlier report, not by maintaining a current-state layer. This is visible within M1-OWNERSHIP: a required deeper engine fault campaign and failing lifetime gate ([L436-L485](../../../../docs/M1-OWNERSHIP.md#L436-L485)) precede the explicit operator scope disposition that supersedes that work ([L487-L512](../../../../docs/M1-OWNERSHIP.md#L487-L512)). PACKAGE-FOUNDATION records multiple intermediate migration counts and only at the end establishes the cutover. M3-CORE keeps early unmet gates above later closure evidence. These are valuable historical records, but inappropriate primary operational instructions.

There are three biases to avoid:

1. **Milestone inertia:** treating “core”, “first slice” and “proposed” as current product categories because they were once the organizing structure. Users need supported calls and behavior, not the delivery sequence.
2. **Evidence-preservation conflation:** assuming preserving every failed attempt requires displaying it alongside every present instruction. Archive exact evidence with revision/date and supersession links; extract the durable limitation and contract into maintained docs.
3. **Approval-language accumulation:** repeatedly restating no-push/no-new-patch/review-required instructions in product docs. Those are important operator controls, but they are not how an application developer learns the API. Preserve them in workflows and immutable decisions, while public docs retain accurate release status and substantive obligations.

The opposite bias would be equally harmful: treating careful limitations as obsolete because implementation is complete. Full native coverage does not create a populated union producer, eager analysis, durable state, safe arbitrary addresses, reliable timeouts, full string discovery or distribution clearance. Extract and preserve those distinctions. **Reorganize by audience and authority, not by whether a passage sounds positive or negative.**

## Proposed tree (design only; no moves authorized here)

```text
README.md                         product/supported profile + install/quickstart links
LICENSE                           original wrapper license, unchanged
docs/
  README.md                       audience index + current status pointer
  user/
    INSTALL.md                    pinned source / existing SDK; CMake / LuaRocks
    QUICKSTART.md                  require -> own binary/address -> decompile -> close
    EXAMPLES.md                    task recipes; separate fixture demo prerequisites
    LIMITATIONS.md                 operational limits, symptoms and troubleshooting
    SUPPORT.md                     implemented/excluded scope and qualification status
  reference/
    API.md                        complete current method index, both surfaces
    VALUES-ERRORS.md               UInt64, enums, errors, outcome checks
    LIFECYCLE-PERSISTENCE.md        aliases, state, invalidation, persistence matrix
    FIELDS.md                     generated linked native/model facts, scope marked
  developer/
    SPEC.md                       normative requirements, not release chronology
    DESIGN.md                     current implementation architecture/invariants
    BUILD-TEST.md                 reproduction, hosts, fault/sanitizer boundaries
    COVERAGE.md                    accounting method and evidence authority
    TOOLING.md                     regeneration and immutable evidence rules
    QUALIFICATION.md               current revision/route matrix with archive links
  legal/
    NOTICES.md                    attribution, license/source/accounting obligations
    notices/                      exact retained applicable license texts
  history/
    README.md                     dated/revision-pinned archive; supersession map
    milestones/                   M0–M4, native readiness, foundation/handoff reports
    planning/                     old PLAN and research narrative
    reviews/                      historical original/fresh reviews and this audit
    evidence/                     immutable logs and research/source manifests
api/
  README.md                       machine-ledger provenance/regeneration pointer
  coverage.json                   source-generated accounting (not runtime approval)
  history/coverage-m3.json         immutable retained ledger
  runtime-evidence-m3.json         historical digest/index
examples/                         own-input example + clearly named fixture demos
tests/fixtures/README.md           fixture provenance/regeneration remains with tests
workflows/                        operator authority/deployment/prompts stay separate
native-*.lock.json                 machine-readable pins/accounting stay discoverable
```

This is a concrete target, not a requirement to create every page immediately. A single user guide plus a current API reference can cover the small manual initially. Preserve old incoming URLs with short redirect/pointer documents when moves are later authorized; update references/generators and installed-document policy together. Avoid duplicate normative copies.

## Audience/content disposition by existing major document

| Existing document | Audience / authority | Proposed disposition |
| --- | --- | --- |
| `README.md` | New users; product entry | **Rewrite** around install/quickstart/reference/limitations/notices; keep origin attribution, supported scope, qualified status; one secondary developer/history link. |
| `docs/API.md` | Users; public contract summary | **Rewrite/split** into full current method index and values/errors/lifecycle reference; remove progress chronology, retain behavioral caveats. |
| `docs/EXAMPLES.md` | Users plus qualification authors | **Split** own-input tutorial from fixture regression demonstrations; synchronize runnable code and prose. |
| `api/FIELDS.md` | Advanced users and maintainers; generated source facts | **Keep/rewrite generator presentation** under reference; fix scalar/enum wording, add model links and supported/excluded scope. Do not hand-edit away source provenance. |
| `docs/SPEC.md` | Developers; normative requirements | **Split** durable contract into maintained developer spec/reference; archive planning decisions and acceptance history; retain normative safety limits. |
| `docs/DESIGN.md` | Contributors; architecture/invariants | **Rewrite** implementation map/current choices; preserve boundary, ownership and pagination invariants; move obsolete alternatives/source experiments to history. |
| `docs/COVERAGE.md` | Users need scope; developers need accounting | **Split** current support/exclusions into user SUPPORT; maintain developer coverage methodology; archive staged rollout text. |
| `docs/FULL-CROSSWALK.md` | Advanced users/reviewers; manual evidence index | **Split** method/surface index into API; keep revision-pinned operation/test/evidence mapping in developer qualification; reconcile Shutdown disposition. |
| `docs/INSTALLED-FULL.md` | Maintainers/reviewers; current local qualification | **Split** concise current applicability matrix into developer QUALIFICATION; archive incident/gate-repair/card process details; expose only an accurate status summary to users. |
| `docs/INSTALLED-CORE.md` | Historical qualification | **Archive** with explicit baseline and successor link; extract any unique still-current limitations before archival. |
| `docs/NOTICES.md` | Users/distributors; notices/accounting obligations | **Keep/split** accessible legal/notices page and exact license texts; move operator decision IDs, no-push directives and qualification incident narrative to history/workflows. Do not reduce substantive obligations. |
| `docs/M0-LICENSE.md` + `M0-LICENSE-SOURCES.tsv` | Historical research/decision provenance | **Archive together**, preserving qualifications/quotes/digests; current user obligations link from NOTICES, not a mandatory read through superseded questions. No new legal determination. |
| `docs/M1-BOUNDARY.md` | Contributors/reviewers; boundary audit and early build evidence | **Split/archive** current architecture/testing instructions into DESIGN/BUILD-TEST; preserve revision-scoped audit and historical gates verbatim. |
| `docs/M1-OWNERSHIP.md` | Contributors/reviewers; fault/ownership incident chronology | **Archive**, extracting current guard/loader restrictions and owner invariants into maintained docs; retain superseded OOM investigation as evidence. |
| `docs/M2-SLICE.md` | Historical implementation/qualification | **Split/archive** durable lazy-discovery, diagnostic, extreme-address and producer limits into user/reference docs; retain repair chronology and captures in history. |
| `docs/M3-CORE.md` | Current grammar embedded in historical report | **Split before archiving**: move exact accepted core grammar, iterator and persistence rules to reference; preserve old gates, attempted iterators and correction evidence separately. |
| `docs/M4-FULL.md` | Current full grammar plus evidence | **Split before archiving**: accepted full signatures/fields and practical batch/persistence caveats into reference; full writer evidence remains revision-pinned history/qualification. |
| `docs/NATIVE-READINESS.md` | Historical dependency experiment | **Archive**, with current-build successor link; extract supported profiles/cache/loader limits. Never advertise its retired Python recipe as current. |
| `docs/PACKAGE-FOUNDATION.md` | Mixed installer/developer chronology | **Split** maintained installation/tooling recipes from migration/decision history. Remove dependence on undefined card variables in user instructions. |
| `docs/PACKAGE-HANDOFF.md` | Historical artifact handoff | **Archive** with its existing successor relationship strengthened; preserve useful cache/destination caveats in maintained build docs. |
| `docs/PLAN.md` | Historical planning + milestone acceptance | **Archive/split** old exit matrices and decisions; maintain only genuine future work separately if needed. No user-manual prominence. |
| `docs/reviews/00-INDEX.md` and original/fresh reports | Historical review evidence | **Archive as a group** with exact baseline and scope; keep final dispositions and original wording, not a current API entry point. |
| `docs/evidence/*` | Historical raw evidence; exception: current notice texts | **Archive** logs with provenance; **keep** applicable notice texts readily accessible under legal/notices. Separate obligation content from experiment captures. |
| `api/README.md` | Tooling contributors; ledger authority | **Keep** short provenance/index entry, link developer tooling/current grammar. |
| `api/coverage.md` | Explicit historical research ledger | **Archive** as research, retaining its banner; extract any unique current operation semantics before removing it from user paths. |
| `api/coverage.json` | Maintainers/tools; native source accounting | **Keep** machine artifact and source-only qualification meaning; do not repurpose historical proposal labels as current API authority. |
| `api/history/coverage-m3.json`, `api/runtime-evidence-m3.json` | Immutable historical evidence | **Keep** together with hashes/provenance; no rewriting to manufacture full acceptance. |
| `examples/*.lua` | Currently fixture regression demonstrations | **Keep/relabel** their purpose; add own-input example later, not a fixture masquerading as general quickstart. |
| `tests/fixtures/README.md` | Test maintainers; authored input provenance | **Keep/rewrite stale status only**; link directly from fixture examples and preserve special project-route constraints. |
| `workflows/LAUNCH.md`, `OPERATIONS.md`, prompts | Operators/automation; process authority | **Keep separate** under workflows; extract dated operational incidents to workflow/history if desired, without changing authority or deployment. Not normal user documentation. |
| `AGENTS.md`, root license and locks | Contributors / legal / input provenance | **Keep in place**; do not mix operational instructions into API prose, and keep notices/pins discoverable. |

## Suggested execution order for a later authorized documentation task

1. Repair the user entrance: installation route selector, own-binary quickstart, accurate status terminology and clear fixture prerequisites (D01–D04).
2. Reconcile reference claims and create a complete operation index; correct generated field presentation at its owner (D05). Preserve every documented effective bound and limitation.
3. Extract durable limitations, notices and current developer instructions; then archive chronology with dated provenance and successor links (D03, D06).
4. Implement the approved audience tree and installed-doc selection/index jointly with packaging ownership (D07). Check both source and installed link closure and run the actual own-input example on the supported real profile when implementation is authorized.

Success means a new reader can install and decompile a known function without understanding M0–M5, Saivage cards or prior failed hypotheses, while an auditor can still reach the exact retained evidence and all users can find practical limitations and obligations.
