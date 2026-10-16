# Master author companion

2026-10-16; planning baseline `4903eb7`. Review coordination record, not package
documentation or implementation authorization.

## Status and inspection

Initial synthesis read AGENTS, SPEC/DESIGN/COVERAGE/PLAN, the audit index/map,
F01–F13 and all nine A/B/C component documents. This refinement additionally read
all three D-website documents, F14, and A/B independent r1 review reports. No
ongoing agents or revised component drafts were polled. Only master, handoff and
this companion are edited; no component docs, audit index or production changes.
No builds, runtime experiments, commits, pushes, submission or site publication
were performed. All acceptance commands describe future checks, not executed passes.

C's separate r1 review is APPROVED. A/B r1 design and plan reviews are
CHANGES_REQUESTED; their authors are independently revising. D's fresh independent
review is active, including justification of framework choice. Pandoc plus Lua is
provisional, not a settled toolchain decision. The user asked about LDoc/Jekyll;
the coordinator reports no current framework and preference against a duplicate
API generator. This master does not independently redesign D.

The master remains a draft refinement. After component authors settle their
revisions and cross-plan interfaces, another master reconciliation and fresh
independent master review are required. No readiness/approval claim follows from
these edits.

## Concrete gates carried forward

1. **A R1: header directory.** Removed the master's incorrect base
   `pkg-config --variable=includedir` command. GOOD_INC must be the actual directory
   containing lua.h/lauxlib.h/luaconf.h, explicitly checked. A owns the exact default
   search/selection recipe; no blindly appended suffix or silent fallback.
2. **A R2: negative fixture.** A must supply pinned reproducible standalone mismatch
   fixture provisioning and configuration validation, not an unnamed external
   promise. Reviewer proposes the bounded amd64 PUC 5.4.6 int64/float32 lane and
   requires actual sizes/version/loading-symbol checks, configure probe and real
   module protected rejection, no publication, and continued execution/GC. A owns
   final fixture selection/recipe. The master keeps this prerequisite blocked
   until concrete; luaL_checkversion is not described as a universal custom-ABI
   firewall because its own C signature involves lua_Number.
3. **A R3: discriminating selection.** A must require a real nondefault compatible
   prefix, compare resolved LuaRocks executable/includes with CMake cache and actual
   compile flags, and test with the selected host. System embedded shared/static
   lanes need their own resolved library identities. Master now makes these
   mandatory rather than optional `/usr` evidence. Exact provisioning commands
   await A's owner revision.
4. **B R1: manifest propagation.** B chooses exact export filename and source,
   installed and disposable-probe commands, plus the manifest-bearing shell
   interface and rock-build export identity. C owner then aligns both pristine and
   mutation callers. Removed master's preservation of the old three-argument shell
   signature and its purported exact command. B replaces old M4-FULL/coverage
   mutation targets with manifest members; pristine checks before and after each
   restoration are required. No implicit export lookup, legacy adapter or second
   inventory is invented. D must consume the same settled export contract.
5. **A/C registration.** A asks for non-skipping registration; C's explicit driver
   interface currently has no BAD_LUA flag. Mandatory standalone A tests remain
   siblings of full integration until owners settle registration. Do not invent
   flags/ambient selectors or claim full integration alone closes F03.
6. **B/C evidence placement.** C supplies corrected GetRevision/enum-sign and
   observed-state/reload claims; B retains historical M4/crosswalk reports. Current
   API/guide plus source-only developer explanation carry corrections, not edits
   making old evidence appear freshly qualified. Confirm this placement during
   final reconciliation without adding a runtime ledger.
7. **D framework and shared helpers.** D reviewer is comparing justified minimal
   choices, including Jekyll against the proposed Pandoc/Lua approach and avoiding
   a duplicate LDoc/API generator. Master's website commands follow the supplied
   D interface conditionally; no converter version/hash is invented. Final D
   decision must update the master if commands change. B finishes manifest/helper
   contracts, D proposes needed anchor/content compatibility, B integrates and
   revalidates source/install docs, then D validates rendered artifacts. No parallel
   helper/manual edits or second source-of-truth list.

## Sequence and authority

Six serial batches: A boundaries → C regression interfaces/oracles → B generated
fields/notices → B current manual → B manifest/final native package integration →
D site build/check. A contracts precede B grammar, C commands precede B recipe
freeze, generated content precedes final manifest, B acceptance precedes D content
integration. Binding.cmake ownership stays A → C → B. D's isolated tooling may be
prepared independently only after authorization; that does not satisfy B prerequisites.

D site gates cover current-source rendering/freshness, exact output allowlist,
source/decoded/raw HTML/download content, immutable notice equality, links/IDs/
assets under `/lua-libghidra` and empty baseurl, reproducibility, bounded browser
usability and negative mutations. Build-only converter/preview dependencies do
not become native package prerequisites. Existing native evidence is consumed,
not rerun merely for a website.

Read-only site CI and manual publication workflow preparation are implementation
work for later authorization. Push, Pages enablement/source-mode/environment
changes, deployment and rollback deployment require separate operator authority.
The target URL is not asserted live; publication is not required to call local
build validation complete. F13 applies to the site as package documentation, not
to all source/tools/tests/developer records. Exact license bytes are never redacted
to satisfy scanning. No new upstream repair, dependency patch or runtime authority.

The coordinator retains commit ownership; this subagent makes no commit. Reconcile
settled component revisions before requesting fresh independent master review.
