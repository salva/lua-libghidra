# B/C revised analysis, design and plan — independent review r2

2026-10-16. Fresh independent Astra REVIEWER BC, neither author nor original
reviewer. This reviews the six implementer documents under
`docs/development/plans/package-fixes-2026-10-16/{B-documentation,C-regressions}`.
Approval concerns the proposed specifications, not implementation, qualification,
publication or permission to start work.

## Separate verdicts

| Document | Verdict | Required changes |
| --- | --- | --- |
| B `01-ANALYSIS.md` | APPROVED | None |
| B `02-DESIGN.md` | APPROVED | None |
| B `03-PLAN.md` | APPROVED | None |
| C `01-ANALYSIS.md` | APPROVED | None |
| C `02-DESIGN.md` | APPROVED | None |
| C `03-PLAN.md` | APPROVED | None |

## B r1 correction: closed at specification level

B design §7 and plan §5 now specify a complete interface and C's design/plan
adopt it without an incompatible signature:

```text
BUILD/package-documents.txt
lua5.4 tests/installed_documents.lua source SOURCE_ROOT MANIFEST
lua5.4 tests/installed_documents.lua installed DOCUMENT_ROOT SOURCE_ROOT MANIFEST
bash tests/installed-documents.sh DOCUMENT_ROOT SOURCE_ROOT MANIFEST FRESH_WORK
```

All arguments are explicit absolute paths. The document root is the actual doc
directory, not a module prefix. Configure projects the sole
`LLG_PACKAGE_DOCUMENTS` list into the named build-owned text file; the export is
neither installed nor independently maintained. The driver derives it from the
selected build, requires it, and does not fall back to another build or a legacy
adapter. Reconfiguration after list changes is explicit.

This resolves an actual caller-chain defect, not just inconsistent terminology:
`tests/installed-qualification.sh:43,46` currently supplies the old prefix-based
arguments. `tests/installed-documents.sh:14,22,29` invokes the old Lua interface;
its loop still removes/alters and restores `docs/M4-FULL.md` and
`api/coverage.json`. The revised plans replace every such call and loop under B's
ownership, while C owns driver propagation. Excluded history is not restored
into the new doc set. Checker and callers are to land together.

The revised probe contract is sufficiently concrete:

- Both source and installed pristine checks run in full **and** reduced mode;
  only the mutation driver is full-only.
- The shell requires nonexistent work storage, snapshots installed bytes and
  uses a disposable `FRESH_WORK/documents` copy. It checks pristine before each
  independent mutation, immediately after restoration, and at completion.
- Missing member, stale bytes, bad local destination, bad fragment, forbidden
  content, misplaced/duplicate credit and extra file have named failure
  categories and implicated paths/targets. Manifest membership is asserted for
  ordinary mutation targets; the extra-file case is deliberately outside it.
- Membership/existence precedes graph/content validation, which precedes byte
  freshness. Thus a changed byte cannot falsely satisfy a link/content negative.
  The stale-byte mutation must itself preserve valid graph/content.
- Restoration uses the untouched installed snapshot, including removal of the
  deliberate extra file. Source, real installation and original manifest stay
  unchanged. Malformed/duplicate/escaping manifest probes use disposable copies.

LuaRocks is also explicit rather than assumed equivalent to CMake. B plan §5
pairs `LLG_BUILD_DIR/package-documents.txt` with the actual versioned
`ROCK_PACKAGE_PREFIX/share/doc/lua-libghidra`, confirms that prefix against the
selected build/install, and supplies concrete commands. This matches
`scripts/luarocks-build.lua:13–24`, which installs data under the rock's passed
`PREFIX`, and the rockspec's build/install command arguments. C repeats the same
contract without expanding `tests/package-foundation.sh` into another integration
driver. That script currently invokes neither document checker nor profile/
absence children; there is no omitted caller there.

## B substantive recheck

**Analysis:** the compact current manual, explicit install boundary and retained
source history address the observed recursive install and fixed historical
assertions. `cmake/Binding.cmake:143–152` still installs all docs/api, and
`tests/installed_documents.lua` still requires historical reports, approval IDs
and process phrases. The revised analysis correctly treats these as accumulated
delivery structure rather than product requirements.

**Design:** source mode checks only selected files, while installed mode requires
exact membership and equality with source. Neither permits links into excluded
history merely because that history exists in the checkout. Inline/reference
links, images, fragments and unsupported local HTML syntax are covered; external
URL inventory is not misrepresented as availability verification. The editorial
audience check complements lexical scanning. Full bytes, including comments and
fences, are scanned; only the exact optional single README acknowledgment is
allowed. The restriction stays confined to final documentation, not code/tools/
tests or preserved developer/operator history.

The correction does not weaken notices or field truth. B retains exact notices
and root locks, compiler/runtime separation, independently verified header and
extract hashes for bundled zlib, and incomplete-source-bundle qualifications.
`native-system.lock.json:60–74` corroborates the GCC 14 runtime identities.
The `std::int32_t` omission and ambiguous named-type fallback remain visible in
`scripts/inventory_source.lua`; `scripts/render-fields.lua` currently reproduces
that text and links milestone grammar. Converter-derived enum spelling matters:
`src/slice_convert.hpp:36–48` uses `param`, `temp`, `const` and numeric fallback.
B's generator-owner correction, included-model reachability and native-only
labels avoid inventing Lua conversions or runtime evidence. Historical ledger
hashes and unqualified slots remain protected by the existing tooling contract.

**Plan:** the commands and ownership are executable specifications with honest
unavailable-route reporting. Source/SDK routes preserve the narrow unchanged
upstream generator exception; SDK configuration returns before Python discovery
in `CMakeLists.txt:8–19`. The own-input example checks exact addresses, decompiles
before optional lookup, distinguishes incomplete/fallback output and closes
before process exit. The optional r1 `nm` clarification is incorporated: copy
hexadecimal output with `0x`, not as bare decimal digits. A supplies final ABI/
facade dispositions; no editorial API removal is assumed. No dependency repair
or new release/legal claim is introduced.

## C substantive recheck

**Analysis:** independent inspection confirms ambient selection in
`tests/installed-qualification.sh`, hard-coded build hosts in
`tests/installed-absence.sh:37`, and the cached external tree in
`tests/installed-profiles.sh:10`. The proposed explicit inputs address real
dependencies. Existing CTest registration remains boundary/ownership/native-seeded
coverage, not the full installed suite.

**Design:** full/reduced selection remains truthful after alignment. Full mode
requires its permission/namespace/spec prerequisites and cannot silently reduce
coverage. Reduced mode reports omissions and explicitly disclaims full
qualification. Three-host service coverage, persistence, conditional CFG,
profiles and absence remain accounted for. The opt-in integration target delegates
to the same driver and is neither an ALL target nor a substitute CTest suite.

F09 remains a semantic correction rather than flag-counting. Current
`tests/m4_services.lua:26–52` checks many acknowledgments, retypes int to int and
selects a local by position. `tests/m4_persistence.lua:20–62` does not establish
most pre-save states. The revised design requires identity-keyed immediate
readbacks, genuinely different supported parameter types, detached pre-save
snapshots and fixed expected post-reopen outcomes without reseeding.
`src/core_convert.hpp:79–143` exposes the required alias/member/enum/signature
fields. Acknowledged-only/unobservable writes must be labelled, not called lost
on reload; disappearance of a member does not independently prove comment loss.
True-local versus parameter-kind coverage remains explicit. Implementation-time
observations must become deterministic assertions, never accept-either-result
branches. Unknown wrapper mismatches cannot automatically be blamed upstream.

F10 retains the authored oracle from `tests/project_probe.cpp:19–23`: exactly
`0x401106` and `0x40113c`, excluding caller `0x40111f`, within
`0x401106..0x40113f`. Ordered count, limit-one offsets 0/1/2, singleton ranges and
the shortened range exercise separate forwarding/conversion errors; the existing
adapter passes all four range/page arguments at `src/owner.cpp:566`. Raw ELF
NOT_SUPPORTED remains distinct. Expectations are not sampled from the API under
test and no unsupported leaf sentinel or iterator is invented.

**Plan:** bounded sensitivity checks, parser/preflight validation and one final
full orchestration are proportionate. The alignment does not change F09/F10's
expectations or move B's checker implementation into C. Evidence corrections go
to current authorities through B, leaving old reports historical and source-only
generated slots unqualified. Missing real inputs remain blockers/unverified
routes, not assumed passes. No new fixture or upstream repair is required.

## Historical baggage and review-induced additions

The revision removes the old shipping assertions and mutation targets rather
than layering a second policy over them. A CMake-owned list plus mechanically
exported text is one policy with a simple consumer interface, not two ledgers.
Category-specific mutation failures are warranted because freshness alone would
mask graph/content defects; snapshot restoration prevents the old history-copy
behavior from returning. These review-induced additions close concrete gaps.

The larger documentation tree suggested in the original audit is not mandatory:
four maintained prose pages, generated fields and one source-only development
index suffice. Retaining evidence at existing paths avoids archive moves,
redirects and digest churn. Historical test/approval prose is removed from the
shipping contract while behavioral limits, notice bytes and source qualifications
remain. D's consumption of B's maintained sources/manifest does not justify
another manual or shipping list. No further review machinery, generic Markdown
framework, exhaustive mutation campaign or compatibility scaffolding is needed.

Required changes: **none**. Optional changes: **none requested**; the prior
address-format clarification is already incorporated.

## Inspection limits and overall conclusion

Read workspace/project AGENTS, SPEC/DESIGN/COVERAGE/PLAN, all six revised B/C
documents and all audit/review/companion files requested for this round. Inspected
actual CMake and rock installation, checker/probe/caller scripts, profile/absence
and package smoke drivers, M4 tests, native leaf probe, field tooling and relevant
converters/notices/locks. This is bounded static review, not fresh upstream
qualification or a full D website audit. No builds, tests, installs, fixture
mutations, commits, pushes or runtime controls were performed. Existing unrelated
master/handoff work was left untouched; only this report was written.

The B r1 interface objection is resolved and C's earlier semantic design remains
sound. All six documents are approved for the later authorized implementation
handoff, with no unresolved required correction established by this review.

VERDICT: APPROVED
