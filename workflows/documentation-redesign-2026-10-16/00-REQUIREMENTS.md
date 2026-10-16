# Documentation redesign — operator requirements

This is a working brief, not package documentation. The operator authorized a new
Astra-authored design, independent Astra review, an updated or replacement plan,
and then a request to the main planner to use it. Do not implement the redesign
during planning. Keep runtime execution stopped until separately authorized Run;
the latest explicit Stop remains effective. No push or publication is authorized.

## Outcomes and conditions

1. A new user can choose an installation route, load the module, decompile their
   own supported input and interpret outcomes without understanding development
   stages or automation. Experienced users can find exact method signatures,
   result types, defaults and limitations efficiently.
2. Clearly distinguish maintained user documentation, maintained contributor
   guidance and automation working documents. Saivage plans, designs, critiques,
   execution reports and operator instructions must be outside the main
   documentation, installed manual and website. This working directory is not a
   user/contributor guide and must never be shipped/rendered as one.
3. Final package/site documentation contains no Saivage references except an
   optional concise acknowledgment that it was used to create the project. This
   condition does not ban identifiers in production code, tools or tests.
4. No development history, milestones, audit trails, approval narratives or example
   provenance commentary in final docs. Historical context is permitted only when
   genuinely necessary to explain a present Lua-binding behavior, normally an
   inherited base-library limitation; prefer the current actionable explanation.
   Do not create an archive-reading obligation or a historical-document retention
   gate for the redesigned manual. This does not authorize deleting Git/runtime
   history or disregarding licenses/provenance obligations.
5. Replace user-facing example code copied or recognizably adapted from upstream
   libghidra C++ source/docs or Python bindings with independently authored Lua
   examples. Derive examples from user tasks and the actual Lua contract, not
   line-for-line translation, renaming or superficial changes. Standard API calls
   and ordinary Lua idioms alone do not prove copying; do not claim clean-room
   provenance or absolute absence of similarity. Keep any necessary development
   assessment outside package docs; retain legally required attribution/notices.
6. Accurate current contracts and substantive warnings remain discoverable:
   native crash/address limits, UInt64, ownership/host ABI, ignored protections/
   deadlines, partial outcomes and category-specific persistence are not history
   to erase. Preserve exact licenses/notices, source/pin information and honest
   qualifications without turning tutorials into workflow-policy documents.
7. Maintain one authoritative source for each fact. Generated reference content
   stays reproducible; supported Lua records are distinct from excluded/native-only
   schemas. Website and installed docs consume the same maintained sources, not
   separately drifting manuals.
8. Validate navigation, links/fragments/assets and content boundaries in checkout,
   installed package and website. Validate executable examples on the real
   supported package; rendered code blocks or successful generation alone are
   insufficient. Distinguish unavailable checks from passing ones.
9. Prefer a proportionate design: no unnecessary framework switch, duplicated
   generators, redirect scaffolding, elaborate page hierarchy or new acceptance
   bureaucracy. Compare a focused correction with a coherent structural alternative.

These are constraints, not a prescribed document tree. The designer chooses the
organization and generator/renderer integration within them.

## Stable-point facts

At inspection: clean tracked worktree, HEAD `4dffcb1`; dedicated runtime stopped,
idle, zero active actors. A/C corrections and B documentation/integration work are
done in the existing hierarchy; `card-h-d` website work is unfinished and stopped.
No generated website/tooling is present in tracked source yet. The replacement
plan must coordinate unfinished website work, not assume it shipped or silently
reopen completed native batches. Final independent plan approval is required
before notifying the main planner to adopt it.
