# Bounded example-origin assessment and replacement briefs

Independent EXAMPLE-ORIGIN analyst, 2026-10-16. Working material only: do not
install, render or link this assessment from the final manual.

## Conclusions for the designer

1. The inspected material does **not establish a copied or recognizably adapted
   upstream example**. Similarities in open/decompile/print, error checks and
   contract field names are insufficient evidence. Authorship history remains
   unknown; this is neither a clean-room finding nor an originality certificate.
2. All four `examples/*.lua` files currently ship. Calling three of them regression
   demonstrations does not remove them from the public replacement boundary.
   Select examples by the final manual, installed data and website downloads,
   rather than preserving the old set because qualification once ran it.
3. Prefer newly authored, task-first public examples using the briefs below.
   Retire the fixture-specific regression tour from public delivery; preserve or
   relocate useful internal checks only where they still test a current contract.
   This recommendation is based on usefulness and the explicit authoring goal,
   not a finding that all existing examples were copied.
4. The most concrete public-example risk is unrelated to origin:
   `fixture_manifest.lua` supplies UINT64_MAX as an absent-function probe, and
   `first_slice.lua` dispatches it. Do not reproduce that in new tutorials or
   validations. Exact integer parsing is not native address safety.

## Inspection boundary and reproducibility

Requested product baseline: `4dffcb1`. At inspection the clean worktree HEAD was
`56764e62c1e9e84adf7ec05b5d5bc08d267374a7`; `git diff 4dffcb1 -- README.md
docs/API.md docs/EXAMPLES.md examples tests/fixtures` was empty. Thus the product
examples assessed here match the requested baseline despite later planning commits.
Runtime status is operator-supplied context, not independently rechecked here.

Read project/workspace instructions, SPEC, DESIGN, COVERAGE, PLAN, requirements,
subsystem map, R03, current README/API/EXAMPLES, every `examples/*.lua`, fixture
README and authored C source. Inspected install selection and its qualification
caller. No executable examples, native builds, Python bindings or runtime controls
were run. Proposed outcomes below are future acceptance criteria, not new passes.

Available upstream checkout:
`/home/salva/g/ml/tmp/lua-libghidra-upstream`, clean tracked status, HEAD exactly
`d51ca813ae1b6b59519551a9be8c0b1ad74d862d`, repository `0xeb/libghidra`.
No network fetch or prepared-input reconstruction was needed. Compared selected
complete upstream examples/docs with the Lua files, inventoried C++/Python example
directories, and searched the checkout for distinctive fixture identifiers,
constants and invalidation markers. Search did not find `native_smoke`,
`fixture_renamed`, `authored_value`, `401106`, `18446744073709551615`,
`* 3 + 7` or `ITERATOR_INVALIDATED` in upstream source. This is a bounded textual
check, not a semantic plagiarism detector or a review of every upstream file.
No claim covers unavailable earlier drafts, other upstream revisions or other
repositories. Native source was searchable for adaptation evidence only; no
implementation translation, dependency repair or license applicability research
was performed.

### Pinned comparison sources

All upstream links below name the exact inspected commit, not a moving branch:

- [U1: C++ decompile_function.cpp](https://github.com/0xeb/libghidra/blob/d51ca813ae1b6b59519551a9be8c0b1ad74d862d/cpp/examples/decompile_function.cpp): binary/address/spec-root/architecture CLI, open, decompile, print.
- [U2: Python local_quickstart.py](https://github.com/0xeb/libghidra/blob/d51ca813ae1b6b59519551a9be8c0b1ad74d862d/python/examples/local_quickstart.py): binary/address CLI, format detection, metadata banner and decompilation.
- [U3: C++ decompile_project.cpp](https://github.com/0xeb/libghidra/blob/d51ca813ae1b6b59519551a9be8c0b1ad74d862d/cpp/examples/decompile_project.cpp): project/binary pair, optional named selection, otherwise list and decompile first three.
- [U4: C++ quickstart.cpp](https://github.com/0xeb/libghidra/blob/d51ca813ae1b6b59519551a9be8c0b1ad74d862d/cpp/examples/quickstart.cpp) and [Python quickstart.py](https://github.com/0xeb/libghidra/blob/d51ca813ae1b6b59519551a9be8c0b1ad74d862d/python/examples/quickstart.py): HTTP health/open/first-ten-functions/first-function decompilation.
- [U5: C++ session_lifecycle.cpp](https://github.com/0xeb/libghidra/blob/d51ca813ae1b6b59519551a9be8c0b1ad74d862d/cpp/examples/session_lifecycle.cpp) and [Python session_lifecycle.py](https://github.com/0xeb/libghidra/blob/d51ca813ae1b6b59519551a9be8c0b1ad74d862d/python/examples/session_lifecycle.py): revision/rename/save/discard tours; different local/HTTP behavior and sequencing.
- [U6: C++ README](https://github.com/0xeb/libghidra/blob/d51ca813ae1b6b59519551a9be8c0b1ad74d862d/cpp/README.md), [Python README](https://github.com/0xeb/libghidra/blob/d51ca813ae1b6b59519551a9be8c0b1ad74d862d/python/README.md), and [root README local example](https://github.com/0xeb/libghidra/blob/d51ca813ae1b6b59519551a9be8c0b1ad74d862d/README.md#L365-L384): method snippets, local open/decompile, CLI and live-host quickstarts.
- [U7: Python reference exact-result snippet](https://github.com/0xeb/libghidra/blob/d51ca813ae1b6b59519551a9be8c0b1ad74d862d/python/docs/api_reference.md#L297-L320): inspected selected decompilation snippet, not the entire reference. Checks completed/nonfallback before printing.

## Per-artifact findings

Classification **N/U** below means no distinctive adaptation established in the
inspected comparison, actual composition origin unknown. It does not mean proven
independent authorship. Contract-defined names/defaults are not originality evidence
in either direction.

| Current public artifact | Observed comparison and classification | Redesign disposition |
| --- | --- | --- |
| [decompile.lua](../../examples/decompile.lua), entire script | **N/U.** U1/U2 share binary/address CLI and required open/decompile/print sequence. Lua additionally requires explicit language/compiler, uses exact UInt64 parsing, structured diagnostics, close-scoped execution before exit, and checks completed/fallback/error-message outcomes. No upstream-specific names, address constants, metadata banners or distinctive extra task sequence are reproduced. U7's completed/fallback checks express necessary result semantics. | Author the first-use task from brief A; do not mechanically translate U1/U2 or merely rename this script. Existing behavior is useful contract evidence, not proof of copying. |
| [first_slice.lua](../../examples/first_slice.lua), entire script | **N/U.** Its multi-feature tour overlaps U3/U4/U5 at ordinary API level, but decompile-first fixture arithmetic/ENDBR64 checks, detached envelope identity, shared native alias, close/reopen invalidation and post-scope CLOSED assertions are Lua-binding regression concerns. U3 lists before decompilation; U5 pursues revisions/persistence instead. No distinctive upstream expression identified. | Remove from public example selection; do not preserve a milestone tour as a user journey. Useful regression assertions may remain internal, subject to address-safety review. |
| [core_mutation.lua](../../examples/core_mutation.lua), entire script | **N/U.** Rename overlaps U5, but U5 uses `entry_renamed`/`lifecycle_test_renamed` with revision/save/discard behavior. Lua uses `fixture_renamed`, page size two and a buffered-iterator invalidation assertion through the shared native view. That sequence is not the upstream lifecycle demonstration. | Internal regression, not a required shipped mutation tutorial. Use optional brief C only if a real editing task is needed. |
| [fixture_manifest.lua](../../examples/fixture_manifest.lua), entire module | **N/U.** Checkout-root environment configuration, authored ELF/project paths and fixed fixture addresses are local test inputs. No matching distinctive constants/identifiers found upstream. The language/compiler identifiers are required domain values. | Exclude from public downloads with the fixture tours. Keep test-input configuration internal as needed; do not reuse its UINT64_MAX native lookup. |
| [README](../../README.md) | No fenced executable code or task sequence. Inline require/module names identify actual exports, not an upstream example. Attribution/source-review statement does not establish example copying. | New landing excerpt should derive from the chosen runnable public example, not become an independently drifting second example. |
| [EXAMPLES](../../docs/EXAMPLES.md), shell blocks at lines 36–54, 59–62, 73–84, 97–110, 119–125, 131–142, 146–154 | **N/U.** Wrapper preparation/CMake/LuaRocks commands and host-load checks use wrapper-specific options and installation layout. CMake, shell path checks and require assertions are ordinary idioms. No distinctive upstream task/data sequence found in U6. | Maintain accurate installation recipes; this assessment supplies no reason to replace necessary command syntax. Test exact final recipes separately from Lua examples. |
| EXAMPLES lines 167–171 and 183–193; inline nm/address conversion at 173–179 | **N/U.** Package-prefix block is LuaRocks-specific. Invocation is tied to this wrapper CLI; `0x401106` comes from the documented authored fixture, not inspected upstream. Nevertheless, a copyable fixed address in an own-input tutorial invites inappropriate reuse. | Replace numeric placeholder invocation with a caller-supplied, verified mapped function address; preserve the distinction between virtual address and file offset and prefix nm hex correctly. No fixture-specific address in the public task. |
| [API](../../docs/API.md), all inline construction/signature/value/page/specialist record forms | **N/U; declarative grammar, not a standalone example.** No fenced code blocks. Shared field names, enum names and native defaults are necessary contract facts. Lua argument positions, envelopes, restrictions and native-view distinction differ from upstream C++/Python signatures. | Preserve exact current grammar; do not distort identifiers/defaults to manufacture novelty. Any new executable illustrative snippets must follow the new authoring task briefs. |

The table covers each current Lua file and every EXAMPLES fenced command block,
grouping repeated installation forms. It does not classify all historical working
documents or all internal test programs as public examples. If a final package/site
allowlist promotes another file or snippet into the manual/downloads, assess that
actual addition before shipping it.

## Fixture and shipment boundary

[Fixture provenance](../../tests/fixtures/README.md) documents authored MIT C,
compiler flags/hashes and real Ghidra generation. [authored.c](../../tests/fixtures/authored.c)
defines `native_smoke(x) = x * 3 + 7`, checks input four against nineteen, and
defines `authored_value = 23` with a reader adding five. Those identifiers and
arithmetic were not found in the upstream search. The provenance declaration is
local evidence, not independently reconstructed authorship. There is no need to
create another Ghidra database to satisfy the public example requirement.

The binary and special no-FileBytes project are test inputs. Their arithmetic,
ENDBR64 bytes and addresses can remain private expected-result assertions while
public programs accept any supported caller input meeting documented prerequisites.
The special project route must not become a general project-loading tutorial.
Native regression probes and internal fixtures are outside the requested
user-example replacement scope unless actually published as examples.

[Binding.cmake](../../cmake/Binding.cmake) lines 134–137 and 156–157 install all four
Lua files under `share/libghidra/examples`. [installed-qualification.sh](../../tests/installed-qualification.sh)
lines 83–90 runs the old first-slice/core tours from that installed location.
Changing public selection therefore requires updating the installed-example check,
not retaining obsolete public downloads solely to keep that check unchanged.
[PackageDocuments.cmake](../../cmake/PackageDocuments.cmake) is the separate current
manual inventory; a docs-only allowlist change will not stop example installation.
The pending site must consume the selected new examples, not glob all `.lua`
files or reintroduce old tours as downloads.

## Independently chosen user-task briefs (no implementation)

These are proposed task/data/output decisions made for this redesign. They do not
certify universal novelty. Implement from the actual Lua contract, not from the
upstream files linked above. Two compact public examples are sufficient; C is
optional, not a requirement to expand the manual.

### A — Prepare one function for a human review note

**User goal:** attach the decompilation of one externally identified function to a
review note, clearly separating the result from engine diagnostics.

**Inputs:** supported binary, caller-verified mapped virtual function entry,
explicit language/compiler and optional external specs root. No built-in binary,
address, function name, raw16-bit scenario, implicit first-function selection or
directory scanning. The caller redirects stdout to their review-note file.

**Independent structure:** one function-level report, not a health/API tour.
Normalize the exact address before opening. Emit a compact heading with the
requested address and a result classification, then returned pseudocode as data.
Keep structured call errors and engine error text on stderr. Distinguish absent
record, incomplete/fallback record and completed nonfallback output. Release the
owner before returning process status. Do not infer that any nonempty text is a
successful decompilation; do not add an unsupported timeout guarantee.

**Real Lua acceptance:** invoke the same installed script with fixture paths and
known function addresses supplied by the test harness. Assert exact address text,
complete/nonfallback classification and the fixture's meaningful arithmetic
content, not byte-for-byte decompiler formatting. Invalid argument text must fail
before native access; a missing input path must report an open error. Exercise
available safe non-exact outcomes only with already qualified inputs, never by
inventing an unmapped address. Record any unavailable negative outcome explicitly.
Run external and embedded spec variants using the existing qualified inputs.

### B — Turn a shortlist of reviewed addresses into a name index

**User goal:** annotate a small externally curated shortlist for a notebook or
spreadsheet while keeping addresses exact and output order predictable.

**Inputs/data:** one supported binary and a caller-supplied list of verified mapped
function entries, each with a caller label (illustrative labels: `ingest` and
`reconcile`; not fixture names). Choose a small explicit input cap, e.g. eight,
and document it as a script choice. Reject malformed rows before opening.

**Independent structure:** preserve shortlist order; use canonical hex strings
as duplicate keys; decompile each selected entry before optional function lookup
because discovery is lazy; emit one tabular row per distinct requested entry with
label, exact address, returned name and result classification. Never enumerate
arbitrary addresses or assume an initial function page is exhaustive. Handle
optional NOT_FOUND separately from a native call failure. Quote or escape text
fields according to the chosen output format rather than assuming names are safe
delimiters. One shared owner; no parallel clients or Python detector.

**Real Lua acceptance:** supply two known fixture function entries plus a duplicate
of the first, with independently chosen labels; verify stable order, exact address
deduplication, correct labels and returned native names after successful discovery.
Both known entries must produce real nonfallback decompilation where qualified.
Malformed rows test parser rejection without native probes. This is a shortlist
index, not a claim of complete function discovery or an upstream list-first tour.

### C — Assign a notebook label to one function (optional advanced task)

**User goal:** name one confirmed function for the current analysis session and
verify the visible result before continuing. This is not a regression demonstration
of intentionally stale iteration.

**Inputs/data:** disposable supported input, known mapped function entry, caller's
chosen new label; example task wording may use `reviewed_dispatch` without embedding
that name into fixture expectations. No state file or persistence claim is needed.

**Independent structure:** establish the function by decompilation, retain the
before record, rename through the supported Lua method, inspect acknowledgement
and fresh lookup, then report old/requested/observed names. Complete reads before
editing, and start fresh traversal afterward if needed. Never use discarded=true
as an undo promise or silently save to a sibling file.

**Real Lua acceptance:** verify returned rename flag and actual new lookup name on
the real fixture; verify the retained old record remains detached. Release the
owner. Any later persistence example must have an explicit state path and its own
category-specific save/reopen assertions; do not smuggle that into this task.

## Integration requirements and remaining uncertainty

- Author final scripts first from the selected briefs; derive any tutorial excerpts
  and site downloads from those maintained files. Review all final user-visible
  snippets, not only renamed `.lua` files. Renaming variables/constants alone is
  not a replacement strategy for an actually adapted example.
- Keep executable qualification against the real supported Lua/native package.
  Existing fixture bytes can supply inputs/expectations without appearing in the
  public interface. Do not use Python execution as an oracle or create a new
  heavyweight fixture solely to demonstrate independent authorship.
- Keep required author/origin attribution, exact license texts, dependency pins
  and notices, including the existing [NOTICES](../../docs/NOTICES.md) obligations.
  This report makes no legal determination and authoring new examples does not
  remove dependency obligations.
- Keep this comparison, prior milestone names and provenance narrative out of the
  final manual. Explain present native address, loader, lifecycle and persistence
  limitations directly where they affect the user's task; do not require readers
  to study historical evidence.
- No source/history/runtime deletion is proposed here. Removing an obsolete
  regression demonstration from public packaging is not erasing Git history and
  does not require making an archive part of the manual.

Outstanding evidence is deliberately bounded: no full authorship reconstruction,
no universal similarity search, and no execution of proposed replacements. The
designer can proceed without a new upstream investigation; the implementer must
validate the actual final Lua scripts and package/site selection.
