# Package documentation — selected design

Draft awaiting fresh independent review. Baseline `4903eb7`, 2026-10-16.
Scope F04–F07, F11–F13; proposal only. Paths below are repository-relative.

## 1. One compact manual and an explicit shipping boundary

Retain these familiar paths as the maintained package documentation:

* `README.md`: product entry, supported profile/status, installation and manual
  links, authorship, optional exact creation credit, and one secondary exact-
  revision external source/developer-index link.
* `docs/EXAMPLES.md`: one user guide with installation, own-input quickstart,
  practical limitations/troubleshooting and a clearly separated fixture-demo
  section. Rename its title, not its path. No separate support/quickstart tree.
* `docs/API.md`: single current call-reference authority, both surfaces, values,
  errors, lifecycle/persistence and complete subsystem operation tables.
* `docs/NOTICES.md`: current identities, direct exact notices, provenance and
  substantive source/conveyance obligations, without planning/process dialogue.
* `api/FIELDS.md`: generated native field reference, at its existing path.

The future `cmake/PackageDocuments.cmake` is the sole shipping list, with explicit
repository-relative file paths, no directory recursion or globs. It defines
`LLG_PACKAGE_DOCUMENTS`; Binding.cmake includes it and installs each file under
`share/doc/lua-libghidra/<same relative path>`. The exact initial list is:

```text
README.md
LICENSE
native-inputs.lock.json
native-patched.lock.json
native-system.lock.json
docs/EXAMPLES.md
docs/API.md
docs/NOTICES.md
api/FIELDS.md
docs/evidence/native-notices/libghidra.txt
docs/evidence/native-notices/engine.txt
docs/evidence/native-notices/protobuf.txt
docs/evidence/native-notices/abseil.txt
docs/evidence/native-notices/utf8-range.txt
docs/evidence/native-notices/httplib.txt
docs/evidence/native-notices/binutils.txt
docs/evidence/native-notices/libiberty-dev.txt
docs/evidence/native-notices/zlib1g.txt
docs/evidence/native-notices/libzstd1.txt
docs/evidence/native-notices/libc6.txt
docs/evidence/native-notices/libstdc++6.txt
docs/evidence/native-notices/lua.txt
docs/evidence/native-notices/engine-zlib.txt
```

The final entry is new future work, conditional on verified extraction. All
others must be checked present before adopting the manifest. Manifest entries
preserve source/install-relative links; every local documentation link must end
inside this list. Avoid directory links without an installed index: NOTICES
links to each file individually. Machine locks are installed unchanged as
provenance, not silently transformed into human manuals. References within them
are retained provenance, not claims that source archives/scripts are installed.

The runnable future `examples/decompile.lua` is an example deliverable installed
at `share/libghidra/examples/decompile.lua`, outside the document root. Keep
existing fixture examples installed there, explicitly described as source-fixture
regression demonstrations, not standalone quickstarts. The guide provides their
location as code text, not a broken local Markdown link. Example source is not
subject to a source-wide Saivage ban; the new user example naturally requires no
harness. All actual documentation installed anywhere must be accounted for by
the final-doc list; do not evade the policy by installing extra prose elsewhere.

## 2. Documentation disposition without blind moves

Create only `docs/development/README.md` as the source-only audience/authority
index. It identifies current package pages, contributor requirements, architecture,
tooling commands and dated evidence. It must not be installed. README uses an
exact existing source commit URL for this index once available; never invent a
public URL for an unpublished commit. Until then, source-only navigation can be
plain repository-path text rather than a falsely resolvable installed link.

| Existing material | Future disposition |
| --- | --- |
| README, EXAMPLES, API, NOTICES | Rewrite in place as the maintained user layer. Extract durable facts before removing process narrative. |
| `docs/SPEC.md` | Retain developer requirements at this path. Remove duplicate current call grammar after transferring it into API; link to that authority. Keep safety/design requirements and truthful source-generator exception. |
| `docs/DESIGN.md` | Retain developer architecture; correct map to `src/owner.cpp`, `boundary.*`, `slice_convert.hpp`, `core_convert.hpp`, `full_convert.hpp`, and Lua modules. Link current qualification with bounded dates. |
| `docs/COVERAGE.md` | Retain developer coverage methodology/inventory; link API for current grammar/support instead of maintaining a second signature table. |
| `docs/PLAN.md` | Retain original historical planning in place, index as dated history; no current installation/status authority. |
| M0 license report/TSV, M1 boundary/ownership, M2, M3, M4, INSTALLED-CORE/FULL, FULL-CROSSWALK, NATIVE-READINESS, PACKAGE-FOUNDATION/HANDOFF | Preserve reports and chronology at original paths. Index as revision-scoped development evidence. Extract unique effective limits/signatures/recipes into maintained pages; no rewriting old results as current results. |
| `docs/evidence/*` | Leave raw artifacts, toolchain captures, generator qualifications and notice bytes in place. Only explicitly listed notice files ship. Link historical evidence externally at an exact available revision when useful, never make it a prerequisite for first use. |
| `docs/reviews/*`, `docs/history/*`, `docs/development/plans/*` | Source-only development/history, including this plan and current audit. Exclude by construction; do not purge or rewrite. |
| `api/coverage.json`, `coverage.md`, `README.md` | Keep source accounting/research in place; update api/README current regeneration and authority links. Current JSON is regenerated only through its owner, not installed as a competing contract. |
| `api/history/coverage-m3.json`, `api/runtime-evidence-m3.json` | Immutable retained evidence and digest/index, unchanged location/bytes, never generation input. |
| `tests/fixtures/README.md`, existing example code | Keep fixture provenance with tests; explicitly distinguish special analyzed-project route in guide. No fixture relocation. |
| `workflows/*`, AGENTS, skills, deployment/runtime files | Retain independent operator/developer authority; not package docs, no edits required here. |
| root LICENSE and native locks | Keep exact bytes and locations; include manifest copies. |

The index supplies historical classification without adding banners to every
immutable record. Current user pages must not direct a reader into historical
recipes as today's instructions. Any obsolete internal anchors in retained
history can remain historical; source link checking of the maintained developer
index and modified developer pages must still resolve its explicit links.

## 3. Installation and first-use contract

The guide starts with the supported platform, ordinary Lua 5.4 ABI requirements
from A, system/compiler/build prerequisites and route selection. Source checkout
is necessary for source builds; installed docs are not an installed build kit.
There is no claimed public prebuilt SDK download. An SDK route requires a caller-
supplied qualified local SDK with exact Protobuf 29.3.0 CONFIG and PIC closure.

Use ordinary absolute `SOURCE`, `WORK`, `ARCHIVES`, `INPUTS`, `PREFIX`, `ROCKS`
and optional `SDK` variables, defined before use. A writable fresh child of HOME
is a reasonable example; explicit caller overrides are allowed. Guard missing
paths and reject nonabsolute paths before build commands. Do not require root,
card variables or a deployment container. Show explicit online preparation via
`scripts/prepare-native.lua`, offline reuse via `--offline`, and disconnected
configure/build as different phases. Offline preparation requires all six locked
archives already cached; a successful online preparation is not an offline claim.

Show source CMake first, then its source LuaRocks counterpart, with concise SDK
substitutions. Source mode retains unchanged pinned `cpp/embed_specs.py` invoked
by `cpp/cmake/EmbedSpecs.cmake`, Python >=3.10 with standard-library zlib/XML.
It does not enable upstream Python bindings, project-owned Python tooling/oracles,
SDK-consumer Python or installed-runtime Python. Preserve patch name/hash and
locks, shared BFD constraints, spec cache requirements and override limitations.
Do not claim a source wrapper install alone supplies a reusable Protobuf/Abseil
SDK; point source contributors to the actual `scripts/build-native-sdk.sh`
instructions through the development index if they need one.

First use is `require` → checked exact address → `open` → `get_decompilation` →
inspect outcome → deterministic close. A future executable accepts binary path,
known mapped function address, language ID, compiler-spec ID, and optional external
spec root. Address is a native virtual address, not a file offset; obtain it from
the binary's symbols/mapping using a suitable tool, not arbitrary guesses. Place
the known native crash/extreme-address limitation next to this instruction.

Use `u64` without floats and check its `nil,error`. Use `session <close>` after a
successful open (Lua 5.4) so normal scope exit and raised Lua errors release the
owner. Print structured error code/message/backend when present. Inspect present
`completed=false`, `is_fallback` and `error_message` separately from `nil,error`;
print `pseudocode` without turning presence into success. Explain `check` tests
presence only. No function lookup is required before decompilation: discovery is
lazy. Optional later lookup must handle `NOT_FOUND`. No Java, Ghidra application,
Python or network is needed for installed execution; an embedded-spec cold cache
does require writable HOME, or supply a valid external root.

The prose references the single executable sequence; avoid a second drifting
full script. Tiny snippets may illustrate return shapes. Verification uses a
known supported authored ELF/address but the example interface has no fixture-
manifest dependency. Explain special no-FileBytes external-ELF analyzed projects
separately; do not imply ordinary project/raw FileBytes support.

## 4. API and limitations authority

API contains all accepted low-level and Session signatures by subsystem; exact
arguments/defaults/rejected keys, envelopes/extraction, outcome flags and per-call
ignored fields. Extract current M3/M4 grammar, reconcile exports and A's final
reopen/Shutdown policy, include `get_revision` envelope, and link field models.
No inferred facade expansion or native method removal. Implemented full surface
and bounded qualification are separate from independent acceptance/publication.

Keep these durable facts prominent in the guide or API, with one authority for
each detailed contract: one client/process and no independent-engine mixing;
host Lua ABI; alias lifetime, logical program close versus owner release; no
autosave/rollback; limited category persistence and byte overlays; lazy/default
fields; ignored read-only/project metadata/deadline settings; extreme-address
crash limits and raw/FileBytes loader gaps; effective ReadBytes INT32_MAX bound;
exact UInt64/integers/enum fallback; range-end sentinel, linear instruction gaps,
pagination bounds and invalidation; pages-only graph/signature families and
candidate offsets; constant-empty defined strings; batch partial outcomes/no
atomicity; unsupported union producers; no dependency-internal OOM recovery
guarantee. Do not broaden fixture observations or demand new upstream repairs.

## 5. Generated field reference

Keep `api/FIELDS.md` in place; change its generation, not its rendered rows by
hand. Add `std::int32_t` to scalar classification in `inventory_source.lua`.
Resolve named types against assembled ledger model/enum tables, including
optional/vector wrappers. Use the existing model/enum extraction, not a new C++
parser. Native enums have explicit names/numeric values in source accounting;
the renderer obtains actual public spelling/fallback from inspected converters
in `src/slice_convert.hpp`, `core_convert.hpp`, `full_convert.hpp` and owner/
boundary code. Add a small explicit representation mapping if necessary; unknown
names fail or remain clearly native-only, never default to “table/enum”.

For included conversions, render integers as Lua integers, uint64 as exact
UInt64, bytes as binary strings, records as linked table models and enum strings
with numeric fallback. Render exact documented enum names, not an assumed naming
algorithm. Label models/enum types used only by excluded operations as native
schema with no supported Lua conversion claim. A native schema may describe an
excluded value without promising a converter. Coverage through nested models
must be computed from included request/response references rather than a list
based on milestone labels. Preserve native defaults independently of Lua argument
optionality and effective bounds.

Update renderer introduction/links to API (including validation anchors), removing
local links to M3/M4/SPEC from final docs. Regenerate current coverage and fields;
verify changed `lua` representation text and relevant references only, with all
runtime evidence slots still unqualified. Update affected current generator/
consumer expectations, not retained historical artifacts or source body hashes.

## 6. Notices and content policy

NOTICES identifies GCC 13.3.0 as compiler; GCC 14 `libstdc++6`/`libgcc-s1`
`14.2.0-4ubuntu2~24.04.1` and glibc `2.39-0ubuntu8.9` as retained runtime packages.
Split bundled engine zlib 1.3.1 and system zlib `1:1.3.dfsg-3.1ubuntu2.2`.
Verify the complete pinned header against the known SHA256, extract its full
license/copyright block byte-for-byte into `engine-zlib.txt`, record exact URL,
whole-header hash, line/byte boundaries and separately computed extract hash in
NOTICES. Do not use the header hash as the extract hash. Preserve retained system
and upstream notice bytes. If the source cannot be verified, leave F12 incomplete
with an explicit blocker rather than inventing bytes or silently shipping a
placeholder. This is notice accounting, not a complete third-party audit.

Keep exact upstream license attribution, no endorsement, wrapper-original MIT
boundary, dependency/patch provenance and incomplete corresponding-source-bundle
qualification. Keep practical GPL BFD/sframe, LGPL and applicable exception,
Apache/BSD/MIT/zlib and HOS obligations without claiming compatibility clearance.
Replace historical reproduction pointers with the maintained guide. Source URLs
and lock metadata are not proof of corresponding-source delivery.

Check the manifest-selected bytes in both source and installation for case-
insensitive `saivage`, card/record/work URIs and `[[card:` markers. Only optional
exact line `Saivage was used in creating this project.` in README's acknowledgment
section is allowed, at most once. No path-wide or substring exemptions. Check
paths too; no final-doc filename may introduce harness/process terminology.
Current headings/links must not reintroduce audit plans or operator instructions
under different wording; this last audience check is editorial, not a magic
keyword proof. Scan complete doc bytes including HTML comments/code fences.

Exact mandated license bytes and immutable provenance must never be rewritten
to satisfy a lexical rule. Scan them without broad exemption; if a real conflict
is found, report the exact file/hash/context and obtain an explicit requirement
resolution before acceptance. Do not preemptively ban license URLs, source paths,
or general build terms, or claim such a conflict was observed.

## 7. Source/install validation boundary

Export the manifest list during CMake configure for the Lua document checker;
do not independently maintain another installed-file list. Reject duplicates,
absolute/parent-escaping entries, missing files and unlisted installed documents.
Walk supported Markdown inline/reference links, images and fragment-only links;
validate anchors with the heading conventions actually used. Explicitly detect
unsupported local HTML link syntax instead of silently skipping it. External
URLs are inventory/review inputs, not local closure passes or claimed online
availability. Preserve notices' raw textual system paths as verbatim notices,
not Markdown links invented by the checker.

Run the same graph/content check rooted at the checkout and each real installed
doc root, plus byte equality for every manifest file. Keep installed data-root
selection explicit for LuaRocks's versioned package prefix. A clean install must
contain exactly the listed doc files; do not silently delete old user installs
to make an upgrade look clean. Validate clean destinations and document that
replacing an old dossier install needs removal of its old doc subtree only.
