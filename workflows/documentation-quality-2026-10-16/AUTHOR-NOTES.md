# Author revision after R1

Reader rewrite, not acceptance; independent re-review remains required.

## Changed pages and closure

- **R1:** README, INSTALL, API and narrowly SPEC/COVERAGE now distinguish UNIX/Linux
  portability ambition, current Linux/Lua 5.4 ABI constraints, tested host and input architecture.
- **R2–R3:** TUTORIAL now authors/compiles a C program, verifies ELF FUNC/symbol,
  executable LOAD mapping and disassembly, selects matching language/compiler IDs,
  runs a complete inline Lua program and interprets reconstructed output.
- **R4:** EXAMPLES demonstrates rename → inspect → explicit save → logical close
  with required policy → same-owner reopen → inspect, with category-specific limits.
- **R5–R6:** EXAMPLES/API add bounded byte/instruction inspection, two-phase
  traversal/editing, record/page/lowlevel comparisons, UInt64 usage and error recovery.
- **R7:** API explains local IDs versus ordinals, signature/type spellings,
  name/path selectors and enumeration IDs, substring queries, xref function-range
  semantics and caller-supplied benchmark storage. Inline signature and struct tasks.
- **R8–R9:** INSTALL adds preflight/packages, variable carryover, later SDK explanation
  and troubleshooting. README loses generator/legal ledger prominence; NOTICES
  retains pins/attribution/terms with neutral presentation. Exact notice files untouched.

Targeted grounding: pinned `cpp/src/{local_client,local_arch_adapter}.cpp`,
`cpp/src/engine/ghidra_decompiler.cpp`, matching `x86.ldefs`, Lua facade/iterator,
ABI/build files and existing persistence/type service tests. No generated FIELDS edits.

## Validation

Temporary extraction/evidence: `/home/salva/g/ml/tmp/documentation-quality-author-r1`.
Real native runs used the existing installed package under container
`/work/lua-libghidra/.saivage/work/cards/card-h-f-a/editorial-correction/cmake-sdk`;
no deployment/lifecycle operations or native rebuilds.

- Compiled exact tutorial C with `gcc -O0 -fno-pie -no-pie`. `readelf -hW/-sW/-lW`
  and `objdump -d --disassemble=lesson_adjust` confirmed x86-64 little-endian EXEC,
  FUNC entry `0x401106`, size 25, executable file-backed segment
  `0x401000..0x401148`; first instruction four-byte ENDBR64. All dispatch followed
  verification and ran in separate Lua processes.
- Exact extracted tutorial: completed=true, fallback=false, no engine error;
  reconstructed `return param_1 * 3 + 7;`. Inspection returned `f3 0f 1e fa`,
  length 4 and ENDBR64. Iterator/two-phase edit ran. Save/reopen printed
  `edited=lesson_saved`, `reopened=lesson_saved`. Initial omitted close policy was
  caught in execution and corrected before final successful run.
- Extracted signature/struct examples ran: parameter ordinal 0/name input/type int;
  struct member value/int at offset 0, size 4. Record/page/envelope and UInt64
  snippets ran. Both existing public CLI scripts returned complete for this C input.
- Existing `tests/m3_persistence.lua` passed, including overlay nonpersistence,
  discard no-op and destructor no-save; native rename overlap warnings were emitted.
- `lua5.4 scripts/render-fields.lua --check`, `lua5.4 tests/tooling_fields.lua`,
  `bash tests/generator-policy.sh`, `git diff --check`: passed.
- Source document check used actual configured build export
  `.saivage/work/cards/card-h-c-c/routes/sdk-check-build/package-documents.txt`:
  27 members, graph/content passed. Staged installed-byte/membership check passed;
  this is document staging, not a new package installation qualification.
- `tests/package_documents.lua` and `tests/installed-documents.sh`: passed,
  including new negative probes below. Logs in temporary evidence directory.
- Full `lua5.4 scripts/check-tooling.lua "$PINNED_SOURCE" "$FRESH_WORK"` rerun
  passed all native Lua inventory suites, both fresh CLI modes, JSON consumers,
  source mutation/producer checks and package-document checks. Complete output is
  `source-tooling.log`; the first foreground attempt timed out at 120 seconds
  after lookup checks. Final staged-document byte/membership check also passed
  against committed `67b5509`.

## Bounded policy relocation

`scripts/package-documents.lua` no longer forces source-generator details into
README; those remain required in INSTALL/NOTICES. Beginner crash/single-owner/
synchronous facts stay required in TUTORIAL. FileBytes, true-local retyping and
no-autosave facts are required in API instead of the beginner closing list.
`tests/installed-documents.sh` adds six removal probes covering generator facts,
beginner crash/owner safety and the three relocated advanced limits. All reject
as missing-policy before byte-freshness checks. Existing install, license, site
graph, membership and safety checks remain active.

Whole-site regeneration/check is left to the coordinator with the pinned Pandoc.
No portability implementation or additional runtime platform claims. REVIEW-r1.md
is unmodified and left for the coordinator's separate review-record commit.
