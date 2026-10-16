# Independent documentation review — round 2

Reviewed revisions: `67b5509` and `a5cb079`, against their actual current files and the preceding diff. Fresh independent review; no production edits.

## Overall reader-quality assessment

**Approved.** The revision substantially closes the original teaching gap. A Lua programmer without Ghidra experience can now author a small input, establish what its addresses mean, choose processor/compiler conventions, run a complete Lua program and assess reconstructed output. The explanations connect the operations rather than merely adding snippets. The first lesson remains bounded and readable; installation mechanics and advanced limitations have appropriate separate homes.

The inline inspection, two-phase traversal/editing, and separate save/reopen program provide useful next steps. The reference now explains consequential choices: absent observations versus failed calls, record versus envelope returns, exact values versus Lua numbers, names versus enumeration IDs, parameter ordinals versus local selectors, and acknowledgments versus durable effects. No important reader-quality or accuracy blocker was found.

## R1–R9 closure

| Item | Assessment |
| --- | --- |
| **R1 — scope and portability** | Closed. README, INSTALL, API and contributor scope distinguish broad UNIX/Linux/modern-Lua intent, present Linux/Lua 5.4 implementation constraints, and tested Ubuntu/x86-64/5.4.6. INSTALL identifies ELF/GNU/DSO assumptions, mandatory pkg-config discovery, actual minimum tool requirements and host versus input architecture. Lua 5.3 is correctly described as rejected. |
| **R2 — first Lua program** | Closed. TUTORIAL contains the authored C program, compilation, complete inline Lua program, ownership model and result interpretation. The engine → native API → Lua binding explanation is neutral and understandable. Reconstructed pseudocode is explicitly not original-source recovery or proof. |
| **R3 — architecture and address decisions** | Closed. The non-PIE ELF procedure checks header, defined FUNC/text symbol, executable file-backed LOAD extent and complete disassembly. Illustrative addresses are clearly non-runnable examples; the actual entry is derived from the reader's binary. Language/compiler IDs, specification lookup, virtual address/file offset distinction, PIE/stripped limitations and loader options are explained without inventing autodetection or relocation guarantees. |
| **R4 — edit/save/reopen** | Closed. EXAMPLES supplies a complete separate program with a fresh writable state filename, discovery, rename, inspection, explicit save, required close policy, same-owner reopen and checked restored name. It explains separate state, best-effort reload, owner versus program closure, no rollback/autosave and nonpersistent byte overlays. The adjacent category-table link prevents function-name persistence being generalized. |
| **R5 — values and errors** | Closed. API contrasts Session records, pages and native envelopes; explains `response['function']`, presence-only `check`, exact UInt64 conversion/arithmetic/keying and binary strings; gives actionable error-code guidance and a `pcall` pattern for structured and ordinary Lua errors. Native crashes and possible partial mutation effects remain explicit. |
| **R6 — traversal and observations** | Closed. The first-instruction example derives its independent extent from external disassembly, explains inclusive bounds and instruction-count versus byte-count limits, and prints useful disassembly. The two-phase example collects detached addresses before mutation. Native-alias invalidation, short-page behavior, signature filtering, lazy discovery, record relationships and local IDs/ordinals are explained. |
| **R7 — domain meaning** | Closed. Signature and struct examples are small and useful. Name/path normalization, non-durable enumeration IDs, substring filters, ignored size/enum settings, true-local limits, xref range selection and caller-supplied benchmark storage now have substantive explanations. Existing method/model anchors remain available. |
| **R8 — installation** | Closed. Source CMake is the clear starting route. Prerequisite packages/preflight, prepared-input reuse, fresh route work directories, SDK meaning, module/helper layout and common failures have actionable guidance. Successful `require` is expressly distinguished from actual decompilation. |
| **R9 — presentation/legal boundaries** | Closed. README focuses on capabilities and navigation; generator details live in installation/legal material. Personal upstream attribution is confined to NOTICES and retained legal assets, without promotional emphasis. Pins, source links, HOS/GPL/LGPL qualifications and exact notices remain intact. |

## Required fixes

None. No further correction round is needed for documentation acceptance.

## Optional polish

In TUTORIAL's final supplied-script command (lines 205–215), consider using the installation guide's retained `SOURCE` path, for example `"$SOURCE/examples/decompile.lua"`, or saying to run it from the checkout root. The lesson begins in a new working directory, where the relative `examples/decompile.lua` path need not exist. Similarly, an explicit reminder to substitute the selected `GOOD_LUA` for `lua5.4` would help custom-host users. These do not obstruct the complete inline first lesson or the documented installed-script path and are not acceptance blockers.

## Accuracy, scope and authority checks

- Reviewed all six user-facing Markdown files in full, R1 and AUTHOR-NOTES, repository AGENTS and the four required contributor documents, with the delivery-plan authority/boundary context.
- Read the actual revision diff, including the narrowly scoped SPEC/COVERAGE changes and package policy/probe changes. No binding feature change, unsupported portability promise, new validation framework, generated-reference hand edit or user-manual process/history narrative was introduced.
- Checked Session unwrapping, construction cleanup, save-close policy and native aliases against `lua/libghidra/init.lua`; checked lazy paging/generation handling against `lua/libghidra/iterator.lua`. Read both public scripts and `tests/m3_persistence.lua` rather than treating the new prose as its own evidence.
- Confirmed the inspected upstream checkout `/home/salva/g/ml/tmp/lua-libghidra-upstream` is at `d51ca813ae1b6b59519551a9be8c0b1ad74d862d`. Targeted inspection of `cpp/src/local_client.cpp`, `local_arch_adapter.cpp` and `engine/ghidra_decompiler.cpp` supports the newly documented architecture/default handling, raw-only rebasing/PE preparation, state loading/save behavior, function-selected xrefs, name/path selectors, substring queries, local identity/ordinal distinctions and benchmark storage semantics.
- Read the matching prepared `x86.ldefs` language entry: `x86:LE:64:default` selects the 64-bit little-endian language and compiler ID `gcc` names `x86-64-gcc.cspec`. No guessed native address was dispatched.
- Checked present ABI/build constraints against `cmake/LuaABI.cmake` and `cmake/Binding.cmake`. The default installation recipes and shared-library layout are consistent with the explanations.
- Reviewed the package policy relocation and six new removal probes. Essential beginner crash/owner/synchronous facts remain required in TUTORIAL; advanced FileBytes/local-retyping/no-autosave facts are required in API; generator requirements remain required in INSTALL/NOTICES. Product-member recognition, graph validation and installed byte checks remain active. This is an appropriate authority relocation, not removal of safety/legal substance.
- Exact legal assets, LICENSE, all three lock files and generated FIELDS have no diff across these revisions. The retained attribution and notices were not cosmetically rewritten.

## Evidence inspected and checks actually run

Inspected the author's extracted `inspect.lua` and `types.lua` examples and the available `document-probes.log` and complete `source-tooling.log` under `/home/salva/g/ml/tmp/documentation-quality-author-r1`. The document log shows each new fact-removal rejection followed by restored passing content, along with existing membership/graph/content/byte rejection cases. The tooling log concludes with the full source-inventory and package grammar/policy passes.

AUTHOR-NOTES records the actual native tiny-program result (`param_1 * 3 + 7`, completed/nonfallback), bounded inspection, signature/type/return-shape tasks, save/reopen and existing persistence regression. Those are reused author-reported native runs, not independently rerun or claimed as this review's executions. Their extracted programs and the targeted implementation checks are consistent with the claims; a fresh native build would add little to this documentation review.

Independently ran:

- `lua5.4 scripts/render-fields.lua --check` — passed.
- `lua5.4 tests/installed_documents.lua source /home/salva/g/ml/lua-libghidra /home/salva/g/ml/lua-libghidra/.saivage/work/cards/card-h-c-c/routes/sdk-check-build/package-documents.txt` — passed, 27 manifest members, graph/content. This checks the actual exported selection and heading/model-link graph.
- `git diff --exit-code 67b5509^ a5cb079 -- api/FIELDS.md docs/notices LICENSE native-inputs.lock.json native-patched.lock.json native-system.lock.json` — passed, unchanged assets.
- `git diff --check 67b5509^ a5cb079` — passed.

Limits: targeted semantic review, not an exhaustive re-audit of every unchanged native method or legal compatibility determination. No native rebuild, native dispatch, site rebuild/rendered-layout check, deployment/runtime control, publication, commit or delegated review was performed. Site regeneration/check remains the coordinator's next step using the existing pinned Pandoc. Only this report was written.

VERDICT: APPROVED
