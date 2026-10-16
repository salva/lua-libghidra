# Package documentation — analysis

Draft awaiting fresh independent review. Baseline: `4903eb7`, 2026-10-16.
This document proposes future work only; it grants no implementation, submission,
publication, deployment or dependency-change authority. Scope: F04–F07 and
F11–F13. All paths are repository-relative unless stated otherwise.

## Goal and boundary

A reader must be able to install the supported native-local Lua binding, load it,
open their own supported binary at a known mapped function address, inspect a
decompilation or error, and close the owner without reading delivery history.
The final package documentation must contain no Saivage references except an
optional, precisely designated creation acknowledgment. This requirement applies
to the explicitly selected package documentation, not production source, tooling,
tests, developer/operator records or retained history. These plans and the audit
are development records even though today's recursive installer includes them.

Keep Linux x86-64/Ubuntu 24.04 and ordinary PUC Lua 5.4 qualification bounded.
Do not imply Lua 5.3 qualification, all-architecture loader support, independent
release acceptance, available public binary downloads or legal clearance. The
upstream remains 0xeb/libghidra at
`d51ca813ae1b6b59519551a9be8c0b1ad74d862d`; no HTTP or SWIG scope is introduced.

## Findings, correction choices and selected direction

| Issue | Observed owner/effect | Focused correction | Proportionate conceptual alternative | Selected direction |
| --- | --- | --- | --- | --- |
| F04 | `cmake/Binding.cmake:143–152` copies all docs/api. The audit found 15 missing local-link occurrences in a retained install. `tests/installed_documents.lua` checks selected freshness, not closure. | Supply omitted targets or replace individual links. | Define a small explicit package-doc manifest; validate its graph and installed bytes. | Manifest and closure: supplying workflow/test trees perpetuates the wrong audience. |
| F05 | `docs/PACKAGE-FOUNDATION.md:12–31` uses undefined `SAIVAGE_CARD_WORK_ROOT`; absent values expand to root-level build/tree directories. | Substitute a defined absolute writable work root. | Make installation one maintained route-oriented recipe, shared across source/SDK and CMake/LuaRocks. | One installation chapter with four bounded routes and ordinary paths. No test-driver redesign here. |
| F06 | README leads to a dossier; `docs/EXAMPLES.md:11–59` imports fixture data and looks up a function before decompilation, unlike `examples/first_slice.lua`. `NATIVE-READINESS.md` invokes absent Python tools; DESIGN names absent `src/client.*`, `src/convert/`, `src/bindings/`. Current grammar resides in M3/M4 reports. | Repair entrances, chronology labels and example ordering. | Maintain a compact task manual and API authority, with a source-only development index over retained records. | Four maintained prose pages plus generated fields, not a large page hierarchy or redirect network. |
| F07 | `scripts/inventory_source.lua:M.lua` lacks `std::int32_t` and conflates named records/enums. `scripts/render-fields.lua` prints that ledger text into `api/FIELDS.md`; `src/owner.cpp` emits `RevisionResponse.file_version` through integer conversion. | Add int32 and enum-specific descriptions at the generator owner. | Resolve native scalar/model/enum categories explicitly, distinguishing actual included adapters from excluded schemas. | Bounded type classification and linked renderer, preserving source-only evidence semantics. No hand-edited generated errata. |
| F11 | `docs/NOTICES.md:33` says GCC 13 runtime; `native-system.lock.json` records GCC 14 runtime packages. | Correct the row. | Separate build-tool identities from shipped/host runtime components. | Exact runtime rows and a separate compiler sentence; no new inventory framework. |
| F12 | Notices combines engine zlib/system zlib, but its system copyright inventory is not the bundled 1.3.1 header notice. | Add a direct pinned header link. | Keep a small exact bundled-notice extract locally with explicit source hash and extraction provenance. | Separate rows and a byte-exact local extract, only after verifying the pinned header. Preserve system notice. |
| F13 | Recursive install includes plans, reviews and card/process references. | Remove offending phrases from selected pages. | Declare the final-doc boundary and enforce content selection, with one exact optional credit. | Manifest/content gate jointly with F04; never scrub retained history or source/tooling/tests. |

### Field tooling facts

`scripts/inventory-api.lua SOURCE FRESH_JSON --coverage` is the current generator;
`scripts/inventory_source.lua` supplies field `lua` descriptions, and
`scripts/render-fields.lua [--check]` reads `api/coverage.json` and writes/checks
`api/FIELDS.md`. `scripts/check-tooling.lua SOURCE FRESH_WORK_DIRECTORY` runs
the native accounting suites, fresh CLI generation and historical digest checks.
There is no `scripts/inventory_render.lua`, `scripts/generate-inventory.lua` or
`tests/tooling_fields.lua` at this baseline. Future focused rendering tests must
be deliberately added rather than described as already present.

The current ledger includes 70 local and 40 excluded operations and all native
models. A source model's existence is not a Lua export or runtime success. Integer
overloads in `src/boundary.cpp`, enum converters and nested-model converters must
corroborate representation claims. Unknown response enum values retain their
numeric native value; do not mechanically lowercase C++ spellings to invent names.

### Provenance facts

The compiler is GCC 13.3.0. Locked `libstdc++6` and `libgcc-s1` are both
`14.2.0-4ubuntu2~24.04.1`, source `gcc-14`; glibc `libc6` is `2.39-0ubuntu8.9`.
These are retained profile identities, not a fresh inventory of the current host.

`docs/M0-LICENSE-SOURCES.tsv` records the engine's complete `zlib.h` as 96885
bytes, SHA256 `5b3dc1c20e9b852ec1ef77f598c89129bae58de98d3773f91a4fc3071dd8cabf`,
at engine revision `2035b8153afaf7ce2edde24a2c80b62bbcf5127f`, path
`Ghidra/Features/Decompiler/src/decompile/zlib/zlib.h`. That digest is for the
header, not a future extracted notice. The audit reported bundled version 1.3.1
and copyright 1995–2024, distinct from the retained system inventory's main
1995–2013 range. Revalidate before creating an extract; no local extract or
complete license/source bundle is claimed to exist yet.

## Historical baggage and review overhead

Successive milestone corrections were appended below earlier “current” claims.
Full/source/SDK status and Python migration therefore require archaeology. The
installed-doc test further fossilizes exact approval IDs, process IDs, counts
and review phrases as mandatory shipped content. Those assertions defend past
review conversations rather than the user's present task. Replace them with
content-boundary, substantive-contract, link and freshness checks; retain the
old evidence in place. Do not turn this cleanup into a generic documentation
framework, an exhaustive Markdown implementation or another upstream campaign.

Preservation does not require moving files. Hash-pinned ledgers, raw logs, TSV
sources and native locks stay byte-for-byte at their current paths. A small
development index can classify records without touching them. Current API facts
should be extracted once into the maintained reference; historical statements
remain evidence, not competing authorities. No redirect scaffolding or wholesale
archive relocation is needed to establish this distinction.

## Dependencies and evidence limits

Group A owns facade reopen/Shutdown policy and Lua ABI contract choices. This
group consumes those final decisions in API/profile text; it must not remove or
promise methods editorially. `get_revision` needs its actual envelope documented.
Group C owns integration selection and specialist/leaf test assertions. This
group owns document checks and recipe/example verification; it uses C's explicit
test-selection contract without duplicating driver changes or expanding claims.

The existing caller chain is part of that boundary: `tests/installed-qualification.sh`
calls the pristine Lua checker and `tests/installed-documents.sh`, which calls
the checker before, during and after mutations. The shell currently mutates
`docs/M4-FULL.md` and `api/coverage.json`; neither belongs to the selected final
docs. B must replace that loop and supply one explicit build-manifest contract
through every call. C owns propagation in the qualification driver, not another
shipping list. The configure export is a mechanical projection of the one CMake
manifest, not a second policy file. No legacy signature adapter is needed.

The separate website work consumes these maintained documents and the same
explicit manifest as a stable source handoff. It does not require a second manual
or source-layout changes in this work. Site design remains with its own author.

This analysis inspected source/document owners and the supplied audit. It did
not build, execute recipes, fetch license material, replay qualification or
inspect live runtime state. Audit observations remain attributed observations;
future checks and acceptance appear in `03-PLAN.md`.
