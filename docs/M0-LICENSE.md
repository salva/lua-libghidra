# M0 license applicability determination

Research for [[card:card-a-a]], 2026-10-15. This is a factual license/authority
assessment, not legal assurance or permission to publish. The operator has
selected MIT for original wrapper code/documentation (see update below). No binding was implemented and no permission request was sent.

## Owner MIT decision — current authority update

Inspected owner commit `eeb4315816046819c92902a2db1e2e1a8082c66e`, root
[LICENSE](../LICENSE), and its README/SPEC/PLAN/LAUNCH changes. This is new
repository authority, not a permission inferred from prior research. The root
license says “Copyright (c) 2026 Salvador Fandiño” and grants MIT rights for
original wrapper code/documentation. LAUNCH explicitly says this “settles the
wrapper-license choice, not third-party license applicability or permission to
publish”. Use MIT for future wrapper package metadata; no license choice remains
for the owner to make here.

Keep the complete MIT copyright/permission notice and disclaimer with copies or
substantial portions of original wrapper material. Keep upstream HOS and each
third-party license/notices separately scoped in packaging; do not label the
entire linked module/dependency bundle MIT or replace upstream copyright with the
wrapper copyright. Visible libghidra/Elias Bachaalany origin/provenance disclosure,
exact applicable HOS license/source references and other dependency obligations
remain as described below. MIT does not grant rights in HOS-covered expression
or cure the HOS/GPL BFD compatibility obstacle. MIT itself is permissive and is
not the source of that obstacle.

Earlier statements below about no tracked root LICENSE or a missing wrapper
license describe the original pre-eeb4315 investigation only, not current state.
The planned-artifact mapping and upstream source manifest remain useful: no
upstream pin/terms or planned binding behavior changed in this owner commit.
What changed is one owner decision; this is not a research reset. The remaining
pre-implementation gate is a defensible applicability determination for the actual
source-informed method, or adequate written rightsholder permission if covered
protected-expression derivation is involved. Intended-use/profile confirmation
and actual dependency/link inventory remain needed only to settle the applicable
distribution obligations; publication direction remains separate. Neither blanket
prohibition nor automatic wrapper exemption follows from the MIT decision.

## Determination and boundary

**The repository does not establish authority to implement the proposed
source-informed, AI-authored binding yet.** It also does not establish that every
Lua wrapper is prohibited. The exact upstream license expressly permits
unmodified dependency use, and expressly conditions its derivative-implementation
restriction on material reliance on protected expression. The accepted baseline
acknowledges upstream source/API/documentation-informed AI-assisted design; its
native-behavior observations alone do not prove protected-expression derivation,
but that provenance is not evidence of independent development either. An
unqualified exemption for this actual plan would be unsupported.

M0's upstream applicability/permission and intended-use gate therefore remains
open **before binding implementation**, as SPEC §6 requires. A decision on whether
the actual planned adaptation crosses the defined protected-expression boundary,
or written permission sufficient to cover it, is needed. Merely calling it a
wrapper, linking unchanged upstream, writing separate files, not distributing,
changing language, or choosing a permissive binding license cannot resolve that
question. Nor does AI authorship alone establish a prohibited derivative.

**Independent prerequisite work need not stop.** Reading licenses, inspecting
build dependencies, compiling/running/evaluating unchanged upstream, validating
engine/spec inputs with the existing upstream interfaces, and authoring unrelated
fixture inputs are distinct from implementing/testing a new derivative binding.
Keep such experiments dependency-focused; do not use them as a disguised binding
prototype or implementation-mining pipeline. Build flags, compiler options,
generated artifacts and external build integration alone do not modify upstream
(§1.10). A source patch is different: §2.4's narrow contribution-back exception
has conditions and is not general permission for an operational local fork.

## Authority and method

Read project AGENTS, LAUNCH, SPEC (especially §6), DESIGN, PLAN, COVERAGE and
README. LAUNCH authorizes implementing reviewed baseline `6d023d7`, but expressly
retains M0 licensing checks and says not to invent a license choice or publication
authority. `git diff 6d023d7 -- README.md docs/{SPEC,DESIGN,PLAN,COVERAGE}.md`
was empty at investigation. README says: “These AI-assisted design documents are
informed by upstream API, documentation and source review”. DESIGN §6 identifies
headers, local implementation, pool/adapter implementation and build files as
sources. These establish exposure and design provenance, not a judicial finding
that particular expression is protected. PLAN requires recording binding license
and intended distribution at M0. No tracked LICENSE/NOTICE or history for such
paths was found by `git ls-files` / `git log --all -- '*LICENSE*' '*NOTICE*'`.
No explicit upstream permission grant for this binding was found in the inspected
project authority. This is not a search of private correspondence or all issues.

Fetched the exact upstream source archive and raw LICENSE over public HTTPS;
compared license bytes against the archive; inspected README license/contact
section, public local header notice, cpp/CMakeLists.txt, GhidraSources.cmake and
CI pin. Third-party primary license texts were fetched separately. Paths and
SHA-256 are in [the source manifest](M0-LICENSE-SOURCES.tsv); hashes identify
observed bytes, not signed authenticity or an approved dependency lock. Temporary
copies are in this card's ignored `license-evidence` work directory. No runtime,
link-closure or full dependency-license qualification is claimed.

## Operative upstream terms

Source base: <https://github.com/0xeb/libghidra/tree/d51ca813ae1b6b59519551a9be8c0b1ad74d862d>.
The LICENSE is Human-Origin Source License v1.0 (HOS), not MPL 2.0 and expressly
not an OSI-approved open-source license. `cpp/include/libghidra/local.hpp` and
`cpp/CMakeLists.txt` bear Elias Bachaalany copyright and
`LicenseRef-Human-Origin-Source-1.0`. README's “License and Terms of Use” identifies
Elias Bachaalany for prior written permission and names
<https://github.com/0xeb/libghidra/issues> as the permission-request path.
Those facts establish the advertised contact, not proof that one person can
relicense every contributor's or third party's rights. §1.1 scopes multiple
Authors to rights each owns/controls; §2.6 requires the Author or an authorized
representative to grant additional permissions in writing.

Decisive quotations (operative sections, not just the non-normative FAQ):

- §1.14 includes any “binding” or “wrapper” that is “copied from, adapted from,
  materially derived from, or Substantially Informed By” covered software,
  including “other protected expression”. It is a conditional definition, not
  a ban on all bindings.
- §1.15 requires access **and** material reliance on “protected implementation
  expression”; “Mere knowledge ... compatibility goals, use of public behavior
  ... or access without material reliance ... is not Substantially Informed By.”
  §§0.1, 6.2–6.4 likewise preserve abstract facts/ideas and independent development.
- §2.1 grants rights “to read, inspect, build, run, reproduce, make available,
  distribute, and otherwise use unmodified copies” including unmodified dependency
  use in a Larger Work. §1.17 excludes Derivative Implementations from Larger Work.
- §2.5 does not grant permission to “create, use, keep, distribute, or make
  available any Modification or Derivative Implementation, including for private,
  internal, experimental, or non-public use, without prior written permission”.
  Waiting until packaging would not satisfy this term if the binding is covered.
- §§1.19, 5.1–5.2 cover AI source/context/prompt/evaluation use **for the purpose
  of** creating, improving, testing, documenting or validating a Derivative
  Implementation. §5.4 permits non-clone automation subject to that same boundary;
  §§3.8/5.4 are not a general experimental-binding exception.
- §2.6: “No additional permission is implied by discussion, silence, availability
  of source code, repository access, issue comments, pull requests, or prior
  dealings.” An actual written grant must convey the required permission, not
  merely acknowledge a request.
- §2.4 allows good-faith contribution-purpose modifications, requiring preserved
  notices, visible changes, offer/submission within 90 days after completion,
  no independent product/divergent fork and no ongoing operational use beyond
  temporary contribution evaluation. Rejection/nonacceptance leaves archival
  retention only under that permission. This planned independent binding has no
  demonstrated contribution-purpose authorization.
- §3.5 allows choosing terms for one's own separate Larger Work files only if
  they do not limit/obscure/contradict covered-software terms. Attribution does
  not substitute for permission. §9 protects rights in actually received prior
  differently licensed versions; it does not relicense the current pin.
- §10 provides automatic termination; its limited 30-day cure for accidental
  notice/packaging failures does not extend to unauthorized derivation/mining.

### Branch-by-branch application

| Actual activity | Evidence-based treatment |
| --- | --- |
| Unchanged upstream dependency/build/engine evaluation | Public grant available subject to terms and third-party licenses; no binding-license decision needed just to run it privately. |
| Independent compatibility adapter using public facts/behavior only | Not automatically derivative under §§1.15/6.4; must establish this is the actual method/provenance, not assert it from the label. |
| Source/expression-informed adaptation of upstream models, implementation structure or examples into a binding, including AI tests/docs | Potential §§1.14/1.19 scope; prior written permission required if material protected-expression reliance exists. Current evidence cannot safely rule it out. |
| Upstream source patch for experiments | Not unmodified use; evaluate §2.4 conditions or obtain permission, not an assumed internal-use exemption. |
| Shipping dependency or combined native module | HOS notices/source/attribution plus actual third-party terms; BFD combined-work problem below. No publication authority granted here. |

## Distribution duties (not a distribution approval)

For permitted HOS-covered distribution: preserve copyright, SPDX, author,
license, patent, origin notices and disclaimers (§3.1); supply complete exact
license or durable direct exact-version link (§3.2); provide corresponding
unmodified covered source (exact upstream-version public link is sufficient for
unchanged HOS copies, §3.3); retain these obligations through package managers and
containers (§3.4). Visible author/project credit belongs in README/docs/notices
and applicable About/credits/package pages (§§4.1–4.5), disclosing copied/adapted/
ported/substantially informed/AI-assisted relationship as applicable. No implied
endorsement (§3.7) or false independence (§3.6). Current README provides visible
origin and AI/source-informed design disclosure; a future package still needs its
actual full notices and provenance inventory. §8 leaves all third-party rights
untouched; the HOS exact-source link shortcut cannot replace GPL source duties.

## BFD and transitive constraints

The approved DESIGN requires Linux BFD; no-BFD is deferred and cannot be silently
substituted here. At the libghidra pin, GhidraSources.cmake discovers BFD and
prefers `libbfd.a`, compiles BFD loader objects, links BFD and optionally libiberty,
sframe, zstd and dl; cpp/CMakeLists propagates dependencies to the local target.
DESIGN's whole-archive module path is a linked combination, not established to be
mere aggregation. Ghidra's pinned `loadimage_bfd.hh` explicitly says “Interface to
GNU BFD library which is GPL 3”. As a concrete primary-source cross-check,
binutils **2.44 is an illustrative version, not a selected/qualified lock**:
`bfd/bfd.c` grants GPL version 3 or later. GPLv3 §5(c): “You must license the
entire work, as a whole, under this License”; §10: “You may not impose any further
restrictions”. §6 requires an applicable corresponding-source conveyance method
for object distribution. HOS restrictions on modification, derivation and AI use
are not GPL freedoms. Thus a BFD-linked combined distribution under the present
HOS grant has a material compatibility obstacle, not just missing credit. A
GPL-compatible grant/exception from the necessary HOS rightsholders, appropriate
separate BFD permission where available, or an explicitly approved different
architecture/profile with its own qualification would need resolution. Dynamic
linking, source-only recipes and separate package names must not be declared
automatic cures. Private unchanged-dependency experiments do not themselves
convey a combined work; this distribution obstacle does not prohibit those
experiments by assumption.

Other evidenced constraints and remaining inventory:

- Ghidra engine pin `2035b8153afaf7ce2edde24a2c80b62bbcf5127f`: root Apache-2.0;
  preserve applicable notices/license and any NOTICE, mark changes if made (§4).
  Its bundled zlib header identifies zlib 1.3.1 and zlib terms (no origin
  misrepresentation, mark altered sources, retain source notice). Root Apache
  alone is not a license for every engine/spec/third-party file.
- Protobuf v29.3 LICENSE: BSD-3-Clause style source/binary copyright, conditions
  and disclaimer retention, no endorsement. Generated source ownership remains
  with input owner; runtime licensing does not relicense libghidra generated code.
- cpp-httplib v0.16.3: MIT, retain copyright/permission notice for copies or
  substantial portions. Local-only product scope does not prove its fetched or
  linked footprint absent; inspect actual build outputs.
- libiberty is not safely summarized by a single permissive label. At illustrative
  binutils 2.44, `xmalloc.c` says GNU Library GPL v2 or later, while COPYING.LIB is
  LGPL 2.1. Audit actual archive members/file terms, exceptions and relinking/source
  obligations for the chosen build. BFD's GPL issue remains regardless.
- Abseil, utf8_range, sframe, zstd/compression, libc/toolchain runtime, Lua, optional
  sol2, compiled Sleigh archive and other actual linked/bundled material still
  need exact selected-version/file-license/notices/source inventory in the M0
  dependency lock and release link-closure audit. No final license clearance or
  exhaustive transitive lock is claimed by this bounded report. Engine/spec and
  dependency qualification remain independent outstanding M0 work.

## Exact unanswered owner questions

1. **Actual derivation authority:** Does the owner have a written upstream grant
   already? Supply its text, scope, grantor authority and covered revisions/rights.
   If not, obtain a written determination/permission covering this AI-assisted
   source-informed Lua/C++ binding, its tests/docs, internal implementation and
   later distribution, or provide a defensible applicability decision that the
   actual method uses no protected-expression derivation. Owner preference alone
   cannot waive upstream rights. If permission is needed, authorize a request via
   the published issue path; none has been sent by this research task.
2. **Intended use only (wrapper license settled):** MIT is selected for original
   wrapper code and documentation, Copyright (c) 2026 Salvador Fandiño. Is intended
   use internal-only, source distribution, binary/LuaRocks/container distribution,
   commercial or another model? The MIT grant permits these uses of the original
   wrapper material; it does not establish the intended dependency-distribution
   profile or authorize this agent to publish. Confirm that profile only as needed
   to resolve dependency obligations. Do not ask for wrapper license selection again.
3. **BFD distribution strategy:** If combined artifacts will be distributed, what
   rights/approved profile will make HOS and GPL obligations simultaneously
   satisfiable? Obtain the necessary rightsholder grants, or explicitly approve
   a scope/profile correction before pursuing a different integration. Do not
   choose no-BFD or a license unilaterally. A final answer also needs the actual
   binutils/dependency lock and link closure, not the illustrative 2.44 texts.

## Follow-up: planned-artifact/provenance discriminator

A second bounded pass maps the planned files to the provenance already recorded
in the accepted design. This is analysis of the proposed work, not implementation
or a claim that an uncreated artifact has copied expression. Sources are the
unchanged SPEC §§1–6, DESIGN §§1–6, COVERAGE and the committed historical review
`docs/reviews/fresh3-upstream.md`. That review reports source locations and its
own documentation approval; it is corroborating provenance, not legal authority
or runtime acceptance. `git ls-files src lua api '*lock*'` found no such tracked
implementation or lock at this pass, so there is no actual new binding body or
selected BFD build to compare or clear.

| Planned artifact / decision | Traceable influence | What this does and does not establish |
| --- | --- | --- |
| `src/client.*`, shared owner and process guard | DESIGN §1 names IClient ownership, logical program close versus retained slot engines, plus independent Lua lifecycle restrictions. Historical upstream review cites local_client.cpp and decompiler_pool.cpp for native lifecycle facts. | Calling the factory and preserving observable close/error semantics is compatible with mere interoperability. Copying upstream owner/adapter implementation would be different. The plan does not require copying that implementation; its new Lua state/process guard is binding policy, not demonstrated upstream expression. |
| `src/convert/`, `src/bindings/`, `api/coverage.*` | DESIGN §1 explicitly requires field converters, native operation relationships, defaults and complete field inventory; SPEC §3/COVERAGE identify types and names from public models and headers. | Strongest planned direct correspondence is model/API mapping. A list of native names, field widths and callable relationships can be compatibility facts; reproducing a protectable selection/organization or translating expressive bodies may cross the boundary. No implemented converter exists to establish which method is used. Fidelity alone does not decide protectedness. |
| `lua/libghidra/lowlevel.lua` and Session facade | DESIGN §1 and SPEC §2 propose separate Lua modules, shared-owner alias, detached responses, error tuples and explicit Lua validation. | New interface/language choices are not evidence of copying upstream code. Neither a new file nor a new language makes an expression-derived adaptation independent. No evidence here that upstream facade code is to be translated. |
| Page validation, generation and iterator algorithms | DESIGN §3 adds bounded progress checks, compound integer validation and invalidation policies; its reasons include source observations about candidate filtering, zero-end sentinel and gap stopping. Historical review identifies local_client.cpp/local_arch_adapter.cpp as observation sources. | Distinguish factual native limitations from an algorithm body. These facts justify compatibility constraints; the proposed rejection/invalidation policy is not shown to be an upstream algorithm copy. A blanket inference that all source-informed debugging facts are protected would exceed the evidence. |
| Build scripts and tests/docs | DESIGN §§5–6 cite whole-archive registration, dependency pins, spec-loading paths and source limitations; SPEC §6 requires real/Python comparisons. | A fresh build description or black-box oracle comparison need not be derivative. Copy/adaptation of HOS build/example/test bodies for a covered derivative remains conditional restricted conduct. Current evidence specifies requirements and observations but no selected copied body. |

**Refined finding:** the current architecture describes an adapter around an
unchanged dependency, not an engine replacement or upstream source fork. This
makes the public-compatibility branch a genuine possibility, not merely a label.
However the plan deliberately draws from upstream model/API structure and
source-derived design/debugging observations. The available documents do not
identify a particular protected body that must be copied, nor establish a
rights-holder/legal determination that the planned structural reliance is
outside §§1.14–1.15. Thus source exposure is established but material reliance
on protected expression remains unproven in either direction. This mapping
narrows the missing decision: assess **this adapter's intended model mapping,
structure and development inputs**, not AI use in the abstract. It does not
supply legal clearance and cannot choose the owner's binding license.

This pass exhausts the useful planned-artifact comparison available before
implementation within this task. No further upstream reading is proposed merely
to repeat the conditional terms. A prospective independent-development route
would require an explicit provenance/method determination consistent with the
accepted plan; it is not silently adopted here as a replacement scope. Existing
private permission, intended use and licensing authority must be supplied by the
owner; a request would require authorization and would itself prove no grant.
Actual transitive lock/member evidence belongs to outstanding dependency work,
not a fictional selected binutils version. Research is ready for assessment on
this bounded evidence, with the three owner questions above still open. This
is a completed inconclusive applicability determination plus precise external
inputs, not an indefinitely renewable evidence gap or an M0 clearance.

These are concrete missing authority/use decisions, not requests to reconfirm
already authorized Lua 5.4/Linux/local-only engineering scope. Research is ready
for assessment with a precise external decision gate; implementation is not
license-cleared. Independent unchanged-dependency/fixture work can proceed.
