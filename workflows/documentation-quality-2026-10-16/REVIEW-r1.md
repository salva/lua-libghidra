# Independent documentation review — round 1

Baseline: `ea19718`. Review only; no production changes or runtime validation.

## Overall finding

The manual is substantially better as a contract reference than as a guide to using a library. It supplies two command-line invocations, then asks readers to assemble their own Lua program from a long reference. Critical decisions—selecting processor conventions and mapped addresses, interpreting Lua return values, and saving/reopening useful edits—remain assumed knowledge. More approachable wording alone will not close this gap.

Keep the existing pages and method/field links. The needed work is a small set of explanatory walkthroughs and local reference introductions, not another documentation architecture. Preserve the precise incomplete/fallback, address safety, ownership and persistence limits already present.

## Ranked required revisions

### R1 — High: distinguish product ambition, current implementation constraints and tested configuration

**Locations:** README “Requirements”; INSTALL “Supported environment and route selection”; TUTORIAL introduction and “Run the task”; API introduction; corresponding scope sentences in development/SPEC and COVERAGE.

**Reader problem:** “The supported environment is Ubuntu 24.04…” presents the tested machine as the product's intended audience. Conversely, “Lua 5.3 … have not been validated” sounds like the current build might accept 5.3. These are different problems: broad portability is the owner's direction, but today's Lua ABI/build restrictions are real. INSTALL's “You need GCC 13.3.0” also turns evidence about one compiler into an unexplained exact-version requirement.

**Fix:** explain these three layers explicitly, briefly in README and concretely in INSTALL. Suggested starting wording:

> The project aims to support most UNIX/Linux systems at least as broadly as libghidra, and modern Lua versions. Current build tooling targets Linux and requires ordinary PUC Lua 5.4 with 64-bit signed integers and double-precision numbers. Ubuntu 24.04 x86-64 with Lua 5.4.6 is the tested configuration; other systems and versions have not been validated.

Refine that wording to avoid implying the aim is already delivered. In INSTALL explain the actual Linux-oriented constraints: `.so` dependencies, GNU/ELF linker assumptions, `$ORIGIN`, the Linux-only rockspec, and required `lua5.4` pkg-config discovery even when custom executable/header paths are selected. Lua 5.3 is rejected by the present ABI check, not merely an untested drop-in alternative. Separate C++20/CMake minimum requirements from the tested GCC/CMake versions. Keep locked dependency/profile instructions; do not promise that changing a label makes other UNIX systems build. Also distinguish **host OS/CPU** from **input binary architecture**; x86-64 ELF is the exercised input route, not the portability aspiration.

**Grounding:** `CMakeLists.txt:2–5,39–64`; `cmake/LuaABI.cmake:2–3,18–25,35–53`; `cmake/Binding.cmake:9–22`; `lua-libghidra-scm-1.rockspec:11–12`. Current development/SPEC:3–7 and COVERAGE:61–63 need consistent wording so later editorial work does not reintroduce the obsolete scope. No native/build feature work is requested.

### R2 — High: teach a first Lua program, not only how to launch the supplied CLI

**Locations:** TUTORIAL “Run the task” through “Interpret the result”; EXAMPLES introduction; README opening.

**Reader problem:** a Lua library tutorial contains no Lua code. Users can run a utility but cannot see how `require`, `open`, the program options, `get_decompilation`, result checks and `<close>` fit together. Sending them to API's signatures or the full CLI's argument-validation machinery does not teach this sequence.

**Fix:** retain the CLI as a quick run, then add a compact, annotated Lua walkthrough using the same independently verified input/address. Show an opened Session in a `<close>` scope, a decompilation request, explicit handling of absence/failure and the complete/nonfallback/error-message conditions, and access to pseudocode. Explain each stage in ordinary terms rather than copying the entire CLI. Establish the mental model first: Ghidra supplies the decompiler engine, libghidra exposes its native API, and this binding makes that API callable from Lua; a client owns the engine, a program is the opened input, and records are detached Lua data. Opening does not perform a full analysis. Explain that pseudocode is reconstructed output, not recovered original source or proof of correctness.

Place crash/address and synchronous-call limits just before the first native operation. Move helper-library layout and LuaRocks install-record discussion out of the middle of the programming lesson into a short INSTALL link. Move specialized FileBytes/retyping limits out of the beginner's closing list into the related advanced task/reference context. Do not delete them.

**Grounding:** `examples/decompile.lua:21–55`; `lua/libghidra/init.lua:55–72,107–129`; API “Construction and return shapes” and “Input and engine limits”. A prose code excerpt can use the existing implementation without adding a third shipped executable or framework.

### R3 — High: make processor/compiler/address selection a usable procedure

**Locations:** TUTORIAL “Before calling the engine”, “Run the task”; API “Construction and return shapes” / `open_program`; EXAMPLES argument descriptions.

**Reader problem:** “confirm [the address] belongs to a loaded region” and “supply explicit supported language and compiler hints” state obligations without teaching how to fulfill them. `nm` prints non-function symbols too. Readers are not told how processor, endianness, bit width, compiler conventions and load address differ, nor how to find valid IDs. PIE/rebased input can make an otherwise plausible address wrong. The safety warning is important but does not supply a safe path forward.

**Fix:** add a worked **ordinary non-PIE x86-64 ELF** selection example. Explain how file/header information establishes the binary architecture, how to select a defined text/function symbol, and how ELF load-segment information and disassembly corroborate a virtual entry and the bytes that will be read. Use illustrative output clearly labeled as such, never a universal runnable address. Explain `x86:LE:64:default` (including LE and 64) and why `gcc` is a compiler-spec convention rather than a compiler executable to launch. Tell readers where matching `.ldefs`/compiler specifications live and how to identify IDs in the supplied specs, after verifying that advice against the pinned files. Do not invent a binding enumeration/autodetection API.

Briefly address stripped and PIE/rebased inputs: the simple `nm` path may not apply, process runtime addresses/file offsets are not interchangeable with this loader's addresses, and the tutorial should not guess a relocation rule. Explain `format`, `base_address`, `default_arch`, `program_path` versus `project_path` enough for a user to decide when to leave defaults; verify effective behavior before claiming those options override a loader. Distinguish a saved binding state file from an analyzed project input. Preserve the warning that an open response echoes hints rather than proving detection.

**Grounding:** API:53–77,301–310,1113–1117; `examples/decompile.lua:26–29`; `examples/inspect_function.lua:32–53`. These sources establish what the wrapper forwards, not a universal address mapping algorithm. Additional pinned loader/spec inspection is needed for any new loader-specific advice.

### R4 — High: add an edit → inspect → save → close → reopen walkthrough

**Locations:** EXAMPLES (new short task section); API `save_program`, `close_program`, `discard_program`, “What survives saving and reloading”.

**Reader problem:** the manual lists many edits and an excellent persistence-limit table but never demonstrates a useful edit or how the state file is selected/reused. “The path used for saved state” does not tell the reader whether saving writes the input executable, exports a Ghidra project, or creates separate binding state. Repeated “not rollback/not autosave” warnings need a positive account of what to do.

**Fix:** walk through renaming a discovered function with a separate disposable `state_path`, inspecting the changed name, explicitly saving and checking the acknowledgment, closing, then reopening the same input with the same state path and checking the name again. Explain that this state is not a rewritten binary and persistence is category-specific. Include the lifetime distinction in the flow: program closure allows reuse of the owner; `close()` ends all aliases and releases the process slot. Do not create a second owner while the first remains live. Present byte overlays as a separate short note or small read-back example: writes affect the engine's view, not the source file, and save/reopen is not patch export. A table mutation is not a native edit.

Keep the existing persistence table immediately reachable from this task. Do not extend tested function-name persistence to signatures, locals, comments, types as a whole or byte patches. If describing state-file creation/error behavior or cross-input reuse, verify it rather than assume a general project database.

**Grounding:** `tests/m3_persistence.lua:7–29` gives an existing, narrowly evidenced save/reopen sequence; `lua/libghidra/init.lua:24–40,49–54`; API:1046–1101. These tests were inspected, not rerun by this review.

### R5 — High: turn return-value and error contracts into decisions a Lua programmer can make

**Locations:** API “Construction and return shapes”, “Values and validation”; TUTORIAL result handling; EXAMPLES “Shared invocation and error contract”.

**Reader problem:** exact triples and names are documented, but readers have to translate dense rules into code themselves. They can easily mistake a record's presence for successful decompilation, use a UInt64 as a number/table key, or treat every missing lookup as fatal. Error codes are listed with no recovery guidance.

**Fix:** add small contrasting snippets for (1) a Session record with its optional third envelope, (2) a complete page with its array field, and (3) the same underlying lowlevel response. Demonstrate `response['function']`, `hex()` for display/keys, checked `to_integer()`/`add()`, and a binary string's length/hex bytes rather than assuming printable text. Explain that `check` raises on absence only, and show when to use explicit `value,err` handling instead.

Add a compact actionable error guide: `CLIENT_IN_USE` → close/reuse the existing owner; `NO_PROGRAM` → open on the live owner; `CLOSED` → create a new owner rather than reopen this alias; `NO_STATE_PATH` → select state storage at construction; `NOT_FOUND` → missing optional observation, possibly lazy discovery, not proof of no code; `INVALID_ARGUMENT` → correct shape/type/bounds; `NOT_SUPPORTED` → consult input/method limitation instead of retrying unchanged. Show `pcall` handling both structured tables and ordinary Lua error values. Native crashes remain outside recoverable Lua exceptions. Do not promise that retrying a failed mutation is harmless.

**Grounding:** `lua/libghidra/init.lua:11–12,31–46,55–72`; `examples/decompile.lua:4–7,32–55`; API:93–149. Preserve false/zero/empty-value semantics.

### R6 — Medium-high: show safe traversal and explain what can actually be learned from records

**Locations:** EXAMPLES “Inspect a known function”; API iterator entries, “Iteration guarantees”, instruction/function/decompilation domains; field-reference links.

**Reader problem:** the inspection script has nine mandatory arguments and only prints instruction addresses. Users are told their bounds must cover full instructions without an example of choosing those bounds or using returned disassembly. Iteration is described as an implementation contract, not demonstrated as a task. The generated field table tells users types/defaults, not how records fit together.

**Fix:** extend the same mapped-input walkthrough with a bounded byte read and instruction page, explaining `data` versus `instructions`, `length`, `disassembly`, inclusive end bounds and count versus byte extent. Tie the bound choices to R3's external mapping/disassembly evidence. Do not imply post-read validation prevents an earlier native crash or that BYTE_COUNT bounds instruction decoding.

Show `for fn in session:iter_functions{...} do ... end` after discovery, plus a practical two-phase pattern: collect detached addresses/names first, then edit after traversal. Explain why changing through `session:native()` also invalidates traversal, and that an invalidated iterator must be replaced, not resumed. Explain a short page versus exhaustion, and keep signature filtering's special rule next to signature queries rather than offer a universal page loop. Explain how entry addresses connect function, decompilation and signature records, and how `local_id`/`kind` differ from parameter ordinals and Lua array positions. Tokens may remain empty; do not sell token-driven output as available.

**Grounding:** `examples/inspect_function.lua:30–38,47–53,72–98`; `lua/libghidra/iterator.lua:19–61`; `lua/libghidra/init.lua:74–104`; `tests/examples/core_mutation.lua:8–13`; `api/FIELDS.md` FunctionRecord, InstructionRecord, DecompileLocalRecord and ParameterRecord. Add explanation in hand-written pages; do not manually edit generated FIELDS.

### R7 — Medium: add meaning to compressed domain reference entries

**Locations:** API “Types aliases enums and members”, “Functions and decompilation”, “Symbols and cross references”, “Performance records”.

**Reader problem:** several entries effectively say “sets X, returns XResponse”. A reader still cannot supply a `prototype`, `data_type`, `type_id_or_path`, `query`, `ordinal` or benchmark record confidently. Related type tasks are scattered in alphabetical order. Links to native default/type tables are necessary but insufficient.

**Fix:** keep method anchors/index; add short domain introductions and a few verified examples. For types, explain the useful sequence list/lookup → create struct → add member → inspect, how a returned name/path/ID is used by each relevant operation, and whether `query` is an empty/all selector or a filter and of what kind. Do not generalize `get_type`'s name-only lookup to all selectors without checking producers. For signatures, provide a known-working prototype/type spelling and explain zero-based ordinal versus returned local ID. Explain what xref range selects and the relevant source/destination fields after source verification. For benchmarks, say whether records are user-supplied measurements or engine-generated timing; do not imply adding a record runs a benchmark.

Place ignored size/enum settings and local-retyping limits beside those concrete tasks. The target is informed use of existing operations, not tutorial examples for every setter or an exhaustive API expansion.

**Grounding:** API:499–546,700–710,767–1025; generated record/request sections provide shapes, not selector semantics. New semantic explanations require targeted pinned implementation checks; this review does not certify currently undocumented filter/path behavior.

### R8 — Medium: make the recommended install path easier to execute and troubleshoot

**Locations:** INSTALL prerequisite paragraphs, “Absolute paths and input preparation”, source LuaRocks route, “Installed paths and use”.

**Reader problem:** there is no concise prerequisite acquisition/preflight sequence for the tested machine, while a long absolute-path loop and dependency-policy details precede the useful commands. “Fresh WORK” in the LuaRocks route can leave readers unsure whether to rerun setup (which also changes INPUTS), reuse the prepared inputs, or repeat downloads. Successful module-load checks are shown; common failures have no diagnostic path.

**Fix:** make source CMake the clear first route, with a short tested-Ubuntu prerequisite example or equivalent actionable package/tool checklist, including headers and runtime libraries. Label versions as tested/locked versus required. Explain exactly which variables carry across preparation and which directories must be fresh for each alternative route. Keep SDK instructions after the ordinary route and explain SDK in one sentence before its CONFIG/PIC detail.

Add a short problem → check section for missing `lua5.4.pc`, host/header ABI mismatch, `module not found` (LUA_PATH/LUA_CPATH), helper/native shared-library load failure, missing prepared archives in offline mode, and unwritable embedded-spec cache. Give the cache path (`$HOME/.ghidracpp/cache/sleigh`) and external-spec alternative where relevant. Avoid treating a successful `require` as proof that a program can open/decompile; link the next real task.

**Grounding:** `cmake/LuaABI.cmake`; `cmake/Binding.cmake:9–23`; `scripts/prepare-native.lua`; DESIGN:73–75; INSTALL:43–85,110–136. Retain existing commands and safety constraints where needed; this is editorial assistance, not a requirement to build additional platform matrices.

### R9 — Medium: remove internal-policy prominence while retaining exact legal attribution

**Locations:** README “Dependencies and license”; INSTALL Python paragraph; NOTICES opening and “Build-time specification generator”.

**Reader problem:** README spends almost as much space on pins, generator provenance, no-project-owned-Python policy and legal caveats as on what users can do. “Native integration uses **libghidra by [author]**” reads as promotional framing rather than a neutral notice. Repetition obscures the useful distinction between build prerequisites and runtime needs.

**Fix:** keep README focused on capabilities, the three-layer engine model, installation/testing scope and a concise license pointer. Retain exact dependency pins and applicable source/license attribution in NOTICES/locks. Replace the bold author-credit framing with neutral dependency identification; preserve any author attribution actually required by the license in the legal notice and associated attribution text. Use “upstream author” in nonlegal explanatory prose if needed. Explain Python as a source-build dependency versus SDK/runtime absence; project-owned tooling/test-oracle exclusions and unchanged-generator policy do not need repetition in a user installation lesson. Do not weaken HOS/GPL/LGPL obligations or modify exact notice texts.

**Grounding:** README:39–55; INSTALL:29–35; NOTICES:3–13,71–110. The present author name is localized to NOTICES, not pervasive; this is a framing adjustment, not a search-and-delete demand.

## Thoroughness and limits

- Read README and all five hand-written user pages, the four required development documents, repository AGENTS, and the existing delivery plan context. The method/reference navigation and major limits are present and mostly well organized; no wholesale page split is needed.
- Inspected generated FIELDS index and the principal function/decompilation/local/signature/instruction/memory/value records. Did not manually edit it or independently audit every generated field/native-only schema.
- Grounded recommendations against both public Lua scripts, Session facade, iterator implementation, relevant CMake/ABI rules, rockspec, preparation entry point, owner declarations and existing mutation/persistence test sources. No tests, builds, native probes, deployment operations, publication or commits were performed.
- Did not inspect every pinned upstream loader/type/filter implementation, external spec file or retained third-party license byte. R3/R7 expressly identify semantics requiring targeted verification before adding factual explanations. No claim of cross-platform/version compatibility or newly reproduced persistence evidence is made.
- Review followed the install → identify input → open → decompile → interpret → inspect → edit/save/reopen → traverse/escape → clean up journey. Remaining weaknesses are substantive learning/completeness gaps, not failed checker requirements. Source-bound document/site checks are suitable for the prose revision; no all-native rebuild or new validation framework is requested.

## Small coherent rewrite brief

1. **Orientation and installation (R1, R8, R9):** correct intent/evidence/constraint framing, simplify README, add actionable prerequisites and troubleshooting without losing legal attribution or Linux/Lua limitations.
2. **One continuous learning path (R2–R6):** extend TUTORIAL with explained input selection and a small Lua program; extend EXAMPLES with bounded inspection, safe traversal and one honest rename/save/reopen task. Reuse the same mental model and input assumptions. Keep existing CLI contracts available as reference.
3. **Reference completion (R5, R7):** add short return/error examples and domain introductions, verify new selector/loader claims against source, preserve method anchors and generated field links. Review for local context so essential information does not require a chain of page hunts.

Re-review should ask whether a reader can now make these decisions and adapt the code, not merely whether the requested keywords were inserted. Correct any new misleading portability, address-safety, success or persistence implications introduced by examples.

**Verdict: NEEDS_REVISION**
