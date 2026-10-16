# Documentation redesign — current-state analysis

Baseline: `4dffcb1`. This is an implementation-facing working document, not a
manual page. Scope is documentation organization, example authorship and their
artifact integration. Execution remains stopped. This document authorizes no
implementation, native build, Run, publication or deployment.

## 1. Outcome and binding constraints

A reader should install the supported package, decompile a known function in
their own supported binary, interpret the outcome, and find exact method and
record contracts without reading project history. Contributors need maintained
architecture and validation instructions, not automation transcripts. The
[operator requirements](00-REQUIREMENTS.md#L10) govern the redesign:

- No development history, approval narratives or example-origin commentary in
  final documentation. Retain historical context only when genuinely necessary
  to explain present binding behavior, normally an inherited dependency limit.
- Independently author task-first Lua examples instead of copied or recognizably
  adapted upstream C++/documentation/Python examples. Renaming or translating is
  insufficient. Do not claim clean-room provenance.
- Working plans, reviews, execution reports and operator instructions belong
  outside main documentation and outside installed/site artifacts. Final docs
  contain no Saivage references except an optional creation acknowledgment. This
  restriction is not a prohibition on identifiers in implementation/tools/tests.
- Preserve exact license texts, substantive attribution/source obligations,
  current safety restrictions and honest supported-profile limits. Keep one
  authority per fact and one field-generation pipeline.
- Do not turn historical retention into a new acceptance gate, delete Git/runtime
  history, reopen accepted native milestones, or create a second manual/site.

The [subsystem map](00-SUBSYSTEM-MAP.md#L5) and issues
[R01](R01-reading-path-and-reference.md#L1),
[R02](R02-authority-and-working-documents.md#L1),
[R03](R03-independent-examples.md#L1),
[R04](R04-artifact-and-stage-integration.md#L1) identify the cross-cutting scope.
The selected organization is specified in [02-DESIGN](02-DESIGN.md).

## 2. What actually exists

### Reader path

[README](../../README.md#L9) sends installation and first-use readers to one
[231-line guide](../../docs/EXAMPLES.md#L1). Its first 158 lines cover four build
routes; own-input decompilation starts at
[line 159](../../docs/EXAMPLES.md#L159). These commands contain valuable practical
details: no advertised public SDK, real LuaRocks package-data location, matching
host headers, prepared inputs and disconnected-build semantics. They need a
dedicated installation home, not removal or cosmetic shortening.

[API](../../docs/API.md#L89) divides common calls from specialist calls. This
matches implementation tiers more than reader tasks: type reads and type edits
are separated, and many results are field names rather than links to records.
The 286-line reference is not so large that a page per method or an API framework
is justified. Domain sections, a method index and direct record links solve the
lookup problem with less navigation overhead.

[FIELDS](../../api/FIELDS.md#L11) begins with unsupported bookmark/breakpoint
responses. The [renderer](../../scripts/render-fields.lua#L28) sorts all models
together, then all enums; it generates neither a table of contents nor a
supported-first partition. Correct nested links already exist. The
[field tests](../../tests/tooling_fields.lua#L6) protect real distinctions:
UInt64 versus int32, optional/nested records, enum spellings and numeric fallback,
and reachable token schemas without a populated native producer. Reachability
must not be promoted into a new runtime-support claim.

### Current technical behavior versus old aspirations

The actual [Session implementation](../../lua/libghidra/init.lua#L14) has the
six-key guarded reopen and shared save policy for close/shutdown. Its
[iterator families](../../lua/libghidra/init.lua#L76) are only functions, symbols
and memory blocks. Older broad planning lists are not an instruction to add
iterators or adapters. Current [API limits](../../docs/API.md#L218) distinguish
program close from owner release, partial outcomes, category-specific reload,
lazy discovery, raw/FileBytes limitations and process-crashing addresses.

Those are present product facts. In contrast, original
[SPEC acceptance prose](../../docs/SPEC.md#L236),
[PLAN milestones](../../docs/PLAN.md#L1) and chronological
[coverage notes](../../docs/COVERAGE.md#L103) mix requirements, development policy
and dated evidence. Rewrite the maintained technical contract from current
implementation; do not present old target inventories as current acceptance.
The [direct C API architecture](../../docs/DESIGN.md#L9) remains useful. Its
ownership/longjmp invariants are contributor material; execution ordering,
operator decisions and review histories are working material.

### Contributor index is stale as well as mixed

The [developer index](../../docs/development/README.md#L13) combines historical
retention directions, commit-by-commit corrections, SDK construction and future
integration promises. Its
[pending-manifest description](../../docs/development/README.md#L79) is contradicted
by the actual [installed driver](../../tests/installed-qualification.sh#L91),
which invokes source and installed document checks and full-mode mutation probes.
This is concrete evidence that history-oriented wording decays; it is not evidence
that the existing checks should be reimplemented. Source contributor instructions
must describe the present commands and prerequisites, without inventing an
end-to-end pass from reading their implementation.

### Artifact boundary already has useful machinery

[PackageDocuments.cmake](../../cmake/PackageDocuments.cmake#L2) is an explicit
selection/export. [Binding installation](../../cmake/Binding.cmake#L146) consumes
it. The [LuaRocks driver](../../scripts/luarocks-build.lua#L14) delegates installation
to CMake, so there is no reason to introduce a second rock document list.

The [shared checker](../../scripts/package-documents.lua#L184) verifies membership,
regular installed files, relative link/fragment closure, forbidden artifact
content and byte equality. Existing
[mutation probes](../../tests/installed-documents.sh#L26) are useful adversarial
checks, not a reason to preserve old paths. A specific migration hazard is the
[three-old-path guard](../../scripts/package-documents.lua#L217): changing a page
name can disable substantive-policy assertions silently. Replace that guard with
required target members and explicit obligations; do not count a passing bypass
as validation. Lexical checks alone cannot recognize historical narrative or
independent authorship; those also need bounded human review.

The [old website design](../../docs/development/plans/package-fixes-2026-10-16/D-website/02-DESIGN.md#L6)
selects Pandoc/GFM plus Lua filters, consumes the package export and avoids native
configuration. These are sensible choices. Its five-page map and single example
assumptions are old content-shape accidents, not architectural constraints.
At this stable point no tracked website implementation exists; unfinished
`card-h-d` remains stopped. Completed A/B/C work is not reopened by this redesign.

### Examples are not one homogeneous class

| Current file | Actual role and disposition pressure |
| --- | --- |
| [decompile.lua](../../examples/decompile.lua#L9) | Own-input CLI, explicit UInt64/open/error/outcome handling, close scope before exit. Preserve these semantics in a newly task-authored example; origin verdict is not inferred from ordinary API calls. |
| [first_slice.lua](../../examples/first_slice.lua#L2) | Authored-fixture assertion sequence exercising metadata, bytes, pages, aliases and closure. This is a regression driver, not a beginner tutorial. |
| [core_mutation.lua](../../examples/core_mutation.lua#L2) | Regression for rename and buffered iterator invalidation; prints a milestone-labelled PASS. It belongs in tests, not installed examples. |
| [fixture_manifest.lua](../../examples/fixture_manifest.lua#L2) | Source-tree test input paths, special project and `absent_function_address='18446744073709551615'`. The first-slice script actually dispatches that UINT64_MAX lookup; relocation must remove it from the selected validation lane, not merely prohibit new probes. |

[Installed qualification](../../tests/installed-qualification.sh#L83) currently
runs the two fixture demonstrations from the installed example directory. Moving
them requires updating that caller while preserving safe regression coverage.
Remove the native `get_function(u64(fixture.absent_function_address))` assertion
and its helper field from the relocated demonstration; rely on existing safe
optional-result coverage rather than finding a guessed replacement address.
Do not run the unchanged unsafe lookup as a redesigned acceptance obligation.
[decompile_example.lua](../../tests/decompile_example.lua#L2) tests control flow
with synthetic outcomes; its explicit disclaimer is correct. It does not prove
real native decompilation.

The completed [bounded assessment](03-EXAMPLE-ASSESSMENT.md#L6) establishes no
distinctive copying or recognizable upstream adaptation in the inspected material.
Actual composition origin remains unknown; this is not an originality certificate
or clean-room finding. No more origin research is needed to proceed. Independently
author the selected public tasks for their user value, preserving correct API
names, outcome checks and ordinary Lua lifecycle idioms without cosmetic novelty.
The assessment stays in working material, never a provenance chapter in the manual.

The redesign itself must resist evolutionary bias: making intentional stale
iterator invalidation part of a new public rename example would inherit the
local `core_mutation.lua` regression-tour structure, even without upstream copying.
Select only two public tasks: decompilation for a review note, and bounded
inspection of a known function's metadata/bytes/instructions. The latter serves
readers correlating pseudocode with a caller-confirmed mapped machine-code region.
Defer a public rename task; invalidation stays in API and existing internal checks.
No state-file context, third example or extra acceptance machinery is justified
by uncertainty about origin. Independently bound inspection byte reads and
instruction ranges/counts; a byte-read limit does not bound instruction decoding.

### Licenses are not optional historical baggage

[NOTICES](../../docs/NOTICES.md#L20) identifies the linked closure and legal texts;
its [conveyance section](../../docs/NOTICES.md#L74) includes substantive HOS,
GPL/LGPL and source-delivery obligations. Preserve those obligations and exact
notice bytes. The [bundled-zlib extraction audit](../../docs/NOTICES.md#L55) is
not a reader journey: keep the exact text and pinned source attribution in the
manual, move extraction offsets/comparison procedure to working evidence if
still useful. The three root locks remain authoritative current data, not an
approval narrative. Required origin attribution must not be removed under the
ban on example-origin commentary.

## 3. Alternatives and decision

| Criterion | Focused repair | Proportionate one-level-up organization |
| --- | --- | --- |
| Reader path | Retain EXAMPLES as install/tutorial; add headings and links | Dedicated INSTALL, TUTORIAL and task EXAMPLES, linked from landing |
| Lookup | Add domains/index to current API and FIELDS | Same small reference improvement; no page-per-method hierarchy |
| Audience separation | Remove working docs, sanitize existing developer index | Current contributor subtree with contract, architecture, coverage and testing; working docs elsewhere |
| Examples | Replace inline/current scripts in existing guide | Task scripts become canonical runnable sources; fixture demonstrations move to tests |
| Cost | Fewer page moves, but continued mixed guide and unclear contributor homes | Bounded source/path/checker changes, clear enduring ownership |
| Evolutionary bias | Preserves accidental five-page shape | Preserves working machinery, discards obsolete stage-driven shape |

Select the second alternative. The meaningful extra cost is a few focused pages
and updated path consumers, not a new documentation platform. It directly solves
the installation/tutorial collision and contributor/history confusion. Keep one
API document and one generated field document, with supported records first and
a native-only appendix. Do not add redirects, compatibility shims, a second
inventory generator, a documentation database, mandatory evidence archive or
new release-approval workflow.

## 4. Demonstrable acceptance and exclusions

Acceptance means the new reader can follow installation → own-input tutorial →
domain method → record → relevant limit without entering a working report.
Installed docs and site contain the same maintained narrative and exact legal
assets. Contributor instructions describe executable current tooling, not pending
work already implemented. Native examples execute against the real supported
package; synthetic outcome tests remain supplemental.

Negative cases include: excluded schema presented as Lua support; missing method
record link; stale generated fields; false success on fallback/incomplete output;
unsafe guessed-address advice; install/site leakage of a working report; broken
fragment; omitted or changed exact notice; selected-page rename bypassing required
content checks; a rendered/downloaded script differing from the tested file.

Native API changes, new engine support, broad upstream debugging, dependency OOM
sweeps, huge allocation probes and requalification of unchanged accepted native
milestones are outside scope. Report unavailable checks honestly. The sequenced
plan and owning-planner adoption follow independent design review; they are not
claimed complete by these two documents.
