# B documentation — independent design/plan review r1

Reviewer B, fresh independent review, 2026-10-16. Scope: B's analysis,
design and implementation plan for F04–F07/F11–F13. This is a proposal review,
not implementation acceptance or a replay of native qualification.

## Verdicts

- **Analysis: APPROVED.** Findings, alternatives and evidence limitations are
  appropriately bounded and corroborated by actual source inspection.
- **Design: CHANGES_REQUESTED.** The selected compact manual and manifest are
  sound; the document-checker integration contract needs the concrete completion
  in item 1.
- **Plan: CHANGES_REQUESTED.** Resolve item 1 before handoff. This is a small
  existing-test integration correction, not a request for another framework.

## Required change

1. **Specify the manifest handoff and update the existing document-probe caller
   chain explicitly.** B design §7 and plan §5 (lines 179–188) introduce a
   configure-exported list and change `tests/installed_documents.lua` to accept
   it, but neither defines its output filename, checker invocation, nor how the
   shell probe gets that build-owned file. C's design lines 61–74 expressly
   retain `installed-documents.sh MODULE_PREFIX DOCUMENT_PREFIX FRESH_WORK` as
   B's interface; those arguments contain no build/manifest path. The current
   pristine caller is `tests/installed-qualification.sh:43`; its shell-probe
   caller is line 46. `tests/installed-documents.sh:14,22,29` invoke the old Lua
   interface, and lines 15–26 still mutate and restore `docs/M4-FULL.md` and
   `api/coverage.json`, which B deliberately excludes. Leaving that loop intact
   either fails on absent files or restores unlisted historical content into
   the disposable tree, invalidating the new pristine check.

   **Requested revision:** name the configure-exported file and exact source,
   installed and disposable-probe checker commands. Explicitly assign the shell
   mutation-loop update to B. Agree with C how the manifest is passed through
   both callers (an explicit additional argument is sufficient), and update C's
   interface description accordingly through its owner. Keep the LuaRocks
   document root explicit and identify the corresponding rock build's exported
   list. Replace the old probe targets with manifest members and the already
   planned missing-link/fragment/freshness/content/unlisted-file mutations.
   Require pristine checks before and after restoring each mutation, with each
   expected failure diagnosed for the intended defect. Include the actual
   future commands in B's validation section. No duplicate hardcoded shipping
   list, legacy interface adapter or new test-selection system is necessary.

## Substantive assessment and evidence

- **Compact user journey:** four maintained prose pages plus generated fields,
  with only one new source-only development index, is proportionate. Keeping
  familiar paths avoids gratuitous moves and redirect scaffolding. The chosen
  alternative is stronger than repairing individual links while continuing to
  install the dossier: `cmake/Binding.cmake:143–152` really does recursively
  install all docs/api. `tests/installed_documents.lua:11–29` checks a fixed
  subset, while lines 41–89 fossilize historical approval/process language.
  Replacing those assertions with substantive contracts and closure/freshness
  checks addresses the defect rather than maintaining its symptoms.
- **Installation:** the shown preparation options match
  `scripts/prepare-native.lua:7–17`; source/SDK selection and environment names
  match `scripts/luarocks-build.lua:11–35`. `CMakeLists.txt:8–19` separates SDK
  consumption from source Python discovery; `lua-libghidra-scm-1.rockspec:5,15–18`
  is a local make descriptor, not evidence of a downloadable source rock.
  Ordinary absolute work paths, clean destinations, fresh-cwd load checks,
  separately labelled offline preparation and unavailable-route reporting are
  correct. Final ABI options must consume A's accepted selected-host/header
  contract rather than freezing today's ambient header selection.
- **Own-input example:** the new parameterized script, decompile-before-lookup,
  exact address parsing, structured diagnostics, separate incomplete/fallback
  handling and close-scoped return before `os.exit` are appropriate. Existing
  `examples/first_slice.lua:2–18` really requires fixture metadata and opens an
  analyzed project before its semantic assertions. B correctly requires a real
  qualified ELF positive without importing that fixture machinery into the new
  interface. Known dangerous-address probes must remain excluded; Lua cleanup
  does not contain a native crash.
- **API and safety:** `lua/libghidra/init.lua:8–11` currently forwards reopen,
  shutdown and get_revision. A's design retains the first two with explicit
  facade policy; B correctly waits for that disposition instead of deleting or
  promising methods editorially. Complete subsystem signatures, defaults,
  rejected keys, response envelopes, enum fallback and effective bounds are
  required, not merely an operation-name index. B's extraction checklist retains
  owner/process restrictions, aliases/generation, ignored deadlines/read-only
  settings, no autosave/rollback, category-limited persistence, overlays,
  partial outcomes, lazy discovery, loader gaps and unsupported producers.
- **Field generation:** `scripts/inventory_source.lua`'s `M.lua` omits int32
  and defaults named types to “table/enum”; `scripts/render-fields.lua` copies
  that text and links historical grammar. `src/owner.cpp:173` converts
  file_version directly; `src/slice_convert.hpp:38–48` demonstrates explicit
  enum spellings (`param`, `temp`, `const`) and numeric fallback. Classification
  at the generator owner plus an explicit converter-derived mapping is sound;
  mechanically lowercasing C++ names is not. Included nested-model reachability
  must stay separate from native-only schemas and runtime producer evidence.
  `scripts/check-tooling.lua` already checks the historical ledger digest and
  unqualified evidence slots; preserving those bytes and paths is justified.
- **Notices:** the manifest keeps LICENSE, exact upstream notice and locks.
  `LICENSE:23–29` retains the exact upstream revision reference. The GCC 14
  runtime correction matches `native-system.lock.json:60–74` and must remain
  separate from GCC 13 compiler identity. The proposed bundled-zlib extraction
  distinguishes the complete-header hash from the extract hash, preserves
  system notice bytes and blocks an invented placeholder. This is bounded
  notice accounting, not license interpretation, compatibility clearance or
  an expanded upstream/legal investigation.
- **Owner boundary:** manifest-selected documentation alone is subject to F13.
  B explicitly preserves source/tools/tests and development/operator/history
  records, narrowly bounds the optional README creation credit, and checks raw
  bytes without silently redacting mandated notices. That matches the owner
  restriction. Exact installed-set checks, source/install graph checks and byte
  equality complement each other; none substitutes for the others.
- **Dependencies/rollback:** A owns facade/ABI policy; C owns test selection and
  stronger specialist evidence. B should consume C's qualified evidence payload
  without rewriting historical claims as new passes. Rollback is appropriately
  limited to the coordinated doc/generator/manifest/check changes and fresh
  disposable installations, preserving unrelated changes and immutable evidence.
  Item 1 is the remaining concrete coordination gap.

## Optional clarification

- In the own-input instructions, show an address such as `0x401106` explicitly
  when using `nm` output. `nm` displays hexadecimal without `0x`, whereas the
  public helper accepts bare digit strings as decimal. Copying `0000000000401106`
  directly would therefore select a different address. This is a useful local
  clarification, not a request for an address-discovery subsystem or extra
  dangerous-address tests.

## Historical baggage / evolutionary-bias conclusion

The selected design correctly rejects milestone inertia: shipping every old
approval, requiring readers to reconstruct API grammar from successive reports,
and checking process IDs are historical accumulation, not product safeguards.
Preserving immutable evidence in place does not require installing it. Conversely,
the one-owner guard, exact UInt64 boundary, host-VM constraint, loader/crash limits,
ignored-timeout warning, persistence limits and exact notices are retained because
they describe actual behavior and obligations, not because a previous reviewer
requested them. No additional hierarchy, compatibility scaffolding, acceptance
ritual or dependency-repair campaign is warranted.

## Inspection limits

Read project/workspace guidance, SPEC/DESIGN/COVERAGE/PLAN, all requested audit
reports/findings and B's three documents; inspected A/C designs and the actual
build/install inputs, document tests/callers, preparation driver, Lua facade,
native conversion, generator/check tooling, examples, LICENSE and runtime lock.
No build, test execution, install, notice fetch/extraction, commit, push or runtime
control was performed. The existing modified master plan was not edited. Only
this report was authored; qualification results remain attributed evidence.

VERDICT: CHANGES_REQUESTED
