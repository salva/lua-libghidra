# Dependency integrity, notices and source/shipping audit

Audit baseline: `4903eb7`, 2026-10-16. Independent, bounded source/document
inspection; no package changes, builds, tests, runtime controls or publication.
Paths below are relative to this report and resolve to repository files. The
reviewed product files have no diff from the baseline despite subsequent audit
commits. The coordinator's existing 18/18 result is not a dependency provenance
or conveyance test and was not rerun here.

## Result

Three actionable documentation/accounting findings: one medium and two low.
No pin/license-text mismatch was established. These findings do not reopen the
operator's planning disposition or establish a legal verdict about the linked
work. In particular, no new upstream BFD investigation or repair is proposed.

### DEP-01 — Medium: current dependency pointer leads to a removed preparation recipe

- **Evidence:** [docs/NOTICES.md#L44](../../../../docs/NOTICES.md#L44) directs
  readers to native readiness for actual patch/source integrity. Its
  [Reproduce section, docs/NATIVE-READINESS.md#L19](../../../../docs/NATIVE-READINESS.md#L19)
  requires Python 3.12 preparation and invokes `scripts/prepare-native.py` at
  line 28. That file is absent from baseline `4903eb7`; the shipped source
  entry point is [scripts/prepare-native.lua#L1](../../../../scripts/prepare-native.lua#L1).
  The current, approved Lua recipe already exists at
  [docs/PACKAGE-FOUNDATION.md#L84](../../../../docs/PACKAGE-FOUNDATION.md#L84).
  The old readiness page also refers to retired Python validators at
  [line 111](../../../../docs/NATIVE-READINESS.md#L111) and
  [line 142](../../../../docs/NATIVE-READINESS.md#L142).
- **Observed versus static:** observed tracked-file absence and contradictory
  recipes, not an attempted failing build. The page calls itself an M0 experiment,
  but the unqualified current NOTICES pointer and imperative reproduction section
  do not tell a reader which commands are historical.
- **Impact:** following the notices-to-provenance path cannot reproduce preparation
  from this checkout and incorrectly suggests a project-owned Python prerequisite
  beyond the narrow upstream generator exception. This is a wrapper handoff defect,
  not evidence that historical offline results were fabricated.
- **Focused remedy:** point current notices directly to the maintained Lua
  preparation/integrity instructions; mark the old reproduction commands as
  historical and identify their historical revision. Preserve old evidence.
  **Proportional alternative:** update just the actionable recipe and validator
  names in native readiness, leaving its chronological results intact.
- **Verification/confidence:** high confidence from baseline file inventory and
  text. Check that current entry-point links/commands resolve in the source
  checkout; no native rebuild is necessary for this documentation correction.
  Coordinate with the documentation audit rather than create a duplicate issue.

### DEP-02 — Low: runtime identity row conflates GCC compiler and runtime packages

- **Evidence:** [docs/NOTICES.md#L33](../../../../docs/NOTICES.md#L33) describes
  the C/C++ runtime as “Ubuntu glibc 2.39 / GCC 13 profile”. However,
  [native-system.lock.json#L60](../../../../native-system.lock.json#L60) records
  `libstdc++6` and `libgcc-s1` version `14.2.0-4ubuntu2~24.04.1`, sourced from
  `gcc-14`. [docs/evidence/native-toolchain.txt#L18](../../../../docs/evidence/native-toolchain.txt#L18)
  independently records the libstdc++ package. GCC 13.3.0 is the compiler identity,
  already separately stated at [docs/NOTICES.md#L40](../../../../docs/NOTICES.md#L40).
- **Observed versus static:** observed metadata inconsistency; no new ELF/package
  inspection establishing the current machine's installed runtime is claimed.
- **Impact:** readers using the concise selected-runtime table can choose the wrong
  GCC source/version when matching the retained closure. The correct lock reduces
  severity; no wrong runtime license text or binary is demonstrated.
- **Focused remedy:** identify the GCC 14 runtime package versions in this row,
  keeping GCC 13.3.0 under compiler tooling. **Proportional alternative:** remove
  the compiler-major shorthand and explicitly defer runtime versions to the lock.
- **Verification/confidence:** high confidence in the table/lock discrepancy.
  Review the edited row against both locked runtime entries; no build or new
  dependency qualification is needed.

### DEP-03 — Low: bundled zlib lacks a direct exact-notice entry in the current table

- **Evidence:** [docs/NOTICES.md#L30](../../../../docs/NOTICES.md#L30) combines
  engine zlib and system zlib under “bundled source / system lock” and “zlib terms /
  zlib1g.txt”. The retained
  [zlib1g.txt#L39](../../../../docs/evidence/native-notices/zlib1g.txt#L39)
  is a system-package copyright inventory with a 1995–2013 main copyright range.
  The separate engine zlib 1.3.1 notice has a 1995–2024 copyright range, as
  inspected in the prepared pinned engine's `decompile/zlib/zlib.h`. Its exact
  source URL and digest already exist at
  [docs/M0-LICENSE-SOURCES.tsv#L11](../../../../docs/M0-LICENSE-SOURCES.tsv#L11),
  and the distinction was documented at
  [docs/M0-LICENSE.md#L273](../../../../docs/M0-LICENSE.md#L273).
  [engine.txt#L1](../../../../docs/evidence/native-notices/engine.txt#L1)
  contains the root Apache text, not this bundled zlib header notice.
- **Observed versus static:** observed notice inventory and cached source-header
  comparison. No claim that all bundled third-party notices were exhaustively
  inventoried, or that this omission alone determines conveyance legality.
- **Impact:** the current component table does not itself provide the promised
  exact bundled-zlib identity/notice reference. A reader must mine historical
  research to distinguish it from the system library; the broad claim at
  [docs/INSTALLED-FULL.md#L82](../../../../docs/INSTALLED-FULL.md#L82) that NOTICES
  retains each exact license/source link is stronger than this row provides.
- **Focused remedy:** split bundled zlib 1.3.1 from system zlib, linking directly
  to the already identified pinned header notice and retaining the system entry.
  **Proportional alternative:** retain the combined row but give both versions and
  two clearly labelled references. If offline notice completeness is intended,
  retain the exact short bundled notice locally; otherwise describe it as an
  external reference, without promising a self-contained bundle.
- **Verification/confidence:** high confidence in the identity/reference gap;
  bounded confidence in broader bundled-component completeness. Compare the
  selected notice bytes with the pinned header and verify any installed local
  notice/reference follows the install manifest. No native test is needed.

## Verified boundaries and non-findings

- **Exact upstream and license:** [native-inputs.lock.json#L5](../../../../native-inputs.lock.json#L5)
  selects `0xeb/libghidra` at
  `d51ca813ae1b6b59519551a9be8c0b1ad74d862d`, with archive SHA256
  `bdec124301f9ebb9660306f324180e1e948307ba3174019be504f6a65693c76f`.
  The root [LICENSE#L23](../../../../LICENSE#L23) gives a direct exact-version
  HOS license link without substituting wrapper terms. A read-only HTTPS fetch of
  that revision's raw LICENSE, both local prepared LICENSE copies, and the retained
  [libghidra notice](../../../../docs/evidence/native-notices/libghidra.txt#L1)
  all hashed to
  `b5c3ae62196909d49188ae54aeda24cb36fc56c6e4da42777df811c1ffc95860`.
  This verifies these bytes, not signed provenance or legal applicability.
- **MIT authorship boundary:** [LICENSE#L1](../../../../LICENSE#L1),
  [README.md#L3](../../../../README.md#L3), and
  [rockspec#L8](../../../../lua-libghidra-scm-1.rockspec#L8) distinguish Salvador
  Fandiño's original wrapper work from Elias Bachaalany's dependency. README
  discloses AI-assisted upstream-informed documentation and denies endorsement.
  There is no assertion here of a clean-room history or that MIT covers upstream.
  The retained upstream text and exact link are noninterpretive evidence;
  surrounding research summaries are not additional license grants.
- **Hash chain:** the current input lock SHA256 is
  `406e6e67983b62672a697131c566ca464c7dcb7aa39833d3148a0d5ee758b15b`, matching
  [native-patched.lock.json#L3](../../../../native-patched.lock.json#L3).
  The prepared upstream patch hash matches the recorded
  `488eda3edc8c26cc93155240663f20d0512318428c4b69e2fbb3b409989ac82d`.
  [scripts/native_prepare.lua#L12](../../../../scripts/native_prepare.lua#L12)
  verifies all six archives before extraction and checks base/revision/patch
  identities before recording the patched profile. This audit did not redownload
  or rehash all six original archives or reconstruct whole source trees.
  Arbitrary source overrides/SDKs are not certified by these checks; that limit is
  already stated at [docs/NATIVE-READINESS.md#L38](../../../../docs/NATIVE-READINESS.md#L38)
  and [docs/PACKAGE-FOUNDATION.md#L35](../../../../docs/PACKAGE-FOUNDATION.md#L35).
- **Other retained notice bytes:** engine root Apache, Protobuf, Abseil, httplib
  and Protobuf's utf8_range notices match their locally prepared source LICENSE
  files by SHA256. No independent remote/archive authentication of those copies
  was performed in this audit.
- **Bundled versus external:** the documented incorporated local/engine/
  Protobuf/Abseil/utf8_range archives versus shared BFD/sframe/zlib/zstd/C/C++
  closure is consistent with inspected CMake and retained link evidence.
  httplib is an input, not a newly enabled HTTP service; libiberty-dev accounting
  is not a claim of libiberty.a linkage. Lua is borrowed from the host:
  [cmake/Binding.cmake#L18](../../../../cmake/Binding.cmake#L18).
  No fresh binary linkage audit is claimed.
- **Shipping/source scope:** [cmake/Binding.cmake#L143](../../../../cmake/Binding.cmake#L143)
  installs root locks/LICENSE/README plus docs/api; the existing ignored
  `build/install_manifest.txt` corroborates those destinations. This does not
  install dependency source archives, a matching corresponding-source bundle,
  or the repository's preparation scripts into the documentation tree. System
  copyright files also refer to host `/usr/share/common-licenses` material.
  These facts do not contradict the explicit incomplete-bundle qualification at
  [docs/NOTICES.md#L58](../../../../docs/NOTICES.md#L58); no newly invented legal
  gate or wholesale source-vendoring requirement follows. Installed reproduction
  instructions need a source checkout, as package foundation already states.
- **Offline evidence applicability:** current
  [docs/INSTALLED-FULL.md#L33](../../../../docs/INSTALLED-FULL.md#L33) and
  [#L44](../../../../docs/INSTALLED-FULL.md#L44) distinguish SDK wrapper installs
  from fresh source-route builds and say the latter generated 385 specs.
  [source-generator-qualification.txt#L32](../../../../docs/evidence/source-generator-qualification.txt#L32)
  explicitly describes an earlier incremental/up-to-date run, not fresh generation.
  The non-isolated SDK dependency build is expressly qualified at
  [docs/PACKAGE-HANDOFF.md#L42](../../../../docs/PACKAGE-HANDOFF.md#L42).
  Offline install evidence is not proof of downloaded system source archives or
  an offline source-delivery kit. Latest `work:///` primary logs were not accessed;
  their reported successes remain documentary evidence, not independently replayed.
- **Python exception:** the prepared upstream generator and EmbedSpecs.cmake
  hashes match [source-generator-qualification.txt#L15](../../../../docs/evidence/source-generator-qualification.txt#L15).
  [CMakeLists.txt#L8](../../../../CMakeLists.txt#L8) returns through the SDK route
  before Python discovery; source mode disables upstream Python bindings at
  [#L37](../../../../CMakeLists.txt#L37). The unchanged Python >=3.10
  stdlib/zlib/XML source-generator exception is settled, not a new finding.

## Historical baggage / evolutionary-bias conclusion

The main pattern is accumulated milestone prose surviving beneath current
summaries, not a need for new dependency architecture or a compliance framework.
DEP-01 is a concrete consequence: an obsolete reproduction path remains reachable
from current provenance documentation. DEP-02/03 are compact metadata corrections.
Prefer a maintained current dependency table/recipe with clearly dated evidence
links, preserving historical failures and research without treating their old
instructions as today's requirements. Do not reinterpret every historical
“pending” statement as a present blocker, or weaken the source/notice qualifications
to make the package appear complete.

Known upstream loader/producer limitations, the incomplete corresponding-source
collection, and unresolved eventual conveyance choices are already documented;
they are not newly discovered wrapper defects. Planning acceptance is not
conveyance clearance. The FSF draft remains unsent; no mail or browser was used.
Only this report was written. No assurance of exhaustive license coverage,
independent authorship adjudication, archive authenticity, release readiness or
legal compatibility is made.
