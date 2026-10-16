# Authorized implementation objective

The operator authorized dedicated-container setup and autonomous Run after the
documentation review converged. This supersedes the earlier setup-only hold.

Implement the reviewed local-only Lua binding described by `docs/SPEC.md`,
`docs/DESIGN.md`, `docs/COVERAGE.md`, `docs/EXAMPLES.md` and `docs/PLAN.md`.
The accepted starting baseline is commit `6d023d7`: Lua 5.4/Linux x86-64 first,
two public layers over one native owner, exact integers, sol2 only if the native
boundary spike qualifies it, and no SWIG. HTTP functionality remains excluded.

Start with M0 prerequisites and follow the plan through a qualified core release,
then full local coverage and its qualification. A core milestone is not the end
of the overall objective. Review approval validates documents, not runtime code.
Do not repeat the completed document-review campaign in place of implementation.

Use the bundled general typed development workflow. Delegate environment and
fixture work normally; run real commands and retain evidence. Resolve ordinary
engineering choices autonomously within the approved requirements. The existing
M0 engine/spec gates and actual dependency-distribution obligations remain real
checks. Licensing research is closed for planning by the operator disposition
below; do not repeat the same applicability/permission question as a blocker.
Record actual technical and packaging evidence. Do not invent a license choice or
authorization to publish. Continue independent prerequisite work where possible.

Work only in `/work/lua-libghidra` and container-local dependency/build paths.
The Saivage runtime is at `/opt/saivage` read-only. Install build dependencies with
guest-local sudo as needed; preserve project-local credentials. Source/dependency
caches and temporary build outputs must be ignored by Git. Commit implemented
changes promptly and do not push or publish without operator permission.

## Operator update — prioritize the wrapper, not upstream repairs

The operator generalized the allocation-failure disposition to all upstream bugs.
We are here to deliver the Lua binding, not fix libghidra/Ghidra/dependencies.
Attribute a failure enough to document the upstream limitation and its practical
impact using available evidence, then move on to wrapper work. Do not require
exhaustive upstream diagnosis, repair, new fault campaigns or upstream fixes as
qualification deliverables. Preserve historical evidence and truthful capabilities.

When a useful workaround is already understood, a small tested wrapper-side
change may be appropriate if its delivery benefit justifies the effort. It is not
a new priority, mandatory investigation or upstream patch authorization. Keep the
public contract and boundary safety; do not fabricate success or hide corruption.
Normal real-backend tests and wrapper defects remain our responsibility.

Owners should remove upstream-repair expectations from downstream planning using
supported lifecycle/activation direction, preserving immutable history and honest
upstream-limited outcomes. Do not reset/restart or create a new upstream-fix task.
This broad policy extends, rather than reopens, the specific OOM disposition below.

## Operator update — allocation failures limited to wrapper qualification

The operator explicitly narrowed allocation-failure work to wrapper issues.
Failures inside libghidra/Ghidra/dependencies must be documented and then ignored
for this project's qualification: no continued internal OOM investigation, repair,
global-state recovery proof or exhaustive dependency allocation/destructor sweep.
This supersedes earlier delegated requirements for those upstream-internal gates,
not wrapper-owned cleanup, Lua longjmp safety, boundary exception handling,
ordinary native functional tests or other unrelated accepted criteria.

For card-b-c, preserve the existing native factory/specpaths finding and evidence
as an upstream limitation; stop its current attributable-global-accounting detour.
Reconcile uncommitted test instrumentation carefully without overwriting other
work. Exclude upstream-only fault reproducers from required passing suites; do not
report their historical failures as passes or silently drop wrapper assertions.
Owners must reconcile obsolete acceptance through supported lifecycle/activation
mechanisms, preserving history; notifications do not rewrite immutable briefs.
Do not reset/restart, create new upstream-fix work or change unrelated scope.

## Pending authority — upstream build-time spec generator

The unchanged pinned upstream `cpp/cmake/EmbedSpecs.cmake` invokes
`cpp/embed_specs.py`, using Python >=3.10 with standard-library zlib/XML during
native source configuration even with Python bindings disabled. SDK-consumer
builds and the installed Lua runtime need not run it. These are technical facts,
not evidence of operator permission.

The narrow build-time exception is **pending operator approval**, OR a
replacement/integration must be separately authorized and qualified. Neither
option is preapproved. This specific external authority gate for [[card:card-e]]
remains unresolved; independent wrapper work may continue. No generator change,
new upstream patch, Python-binding dependency, project-owned Python tooling/test
oracle or distribution permission is authorized here. Preserve technical source-build
evidence and historical records without claiming M5/release acceptance. An actual
operator decision must be reconciled by the owning root through existing lifecycle
controls, not inferred from a documentation assertion or successful test.

## Operator update — Lua-based deliverable, no Python-binding dependency

Python is allowed during initial development. The finished project must not
depend on upstream Python bindings for build, runtime or required acceptance.
Use Lua for project-owned tooling, generators and acceptance tests by release;
retain Python only for a documented compelling reason with operator acceptance.
Assess the pinned upstream spec-embedding generator as the pending narrow
exception above, not approval to retain Python. Native C++ probes/adapter and ordinary
CMake/LuaRocks/compiler tooling remain appropriate.

This supersedes earlier mandatory Python-oracle/comparison gates. For card-a-c,
preserve useful completed Python research, but do not prolong M0 to establish
exhaustive Python-binding parity or make its Python-only audit tooling a permanent
release prerequisite. Base support and acceptance on the native API and real
Lua/native tests. Do not delete active scripts or evidence in place; plan their
Lua migration as implementation work and retain explicit qualification unknowns.

## Authorized engine patch profile

The operator authorizes applying libghidra's bundled
`cpp/patches/0001-bfd-sleigh-target-autodetect.patch` to the pinned Ghidra engine
in a separate dependency source tree. This is a narrow exception to the
unmodified-engine constraint, not permission for arbitrary upstream modifications.
Keep libghidra itself unchanged. Identify the base engine revision, patch source
revision and patch digest in the dependency lock/provenance records.

Resume the work of `card-a-b` using this profile and qualify it with fresh builds,
installed-SDK whole-archive/PIC tests, external and embedded spec loading,
explicit Sleigh-hint regressions and existing automatic-detection controls.
Preserve unmodified-profile evidence and failures. Applying the patch does not
itself pass M0 or resolve the separate license/distribution gates.

## Operator disposition — licensing research DONE for planning

The operator explicitly directed [[card:card-a-a]] to accept the existing upstream
license as valid for project planning and mark licensing research DONE. This
supersedes the earlier planning blocker, not third-party terms or factual
uncertainties. Owner should propagate this settled disposition downstream without
reset/restart, repeated permission investigation, or unrelated card changes.
Preserve the full research and third-party notices. This is not legal clearance,
compatibility proof, new rightsholder permission or upstream relicensing.
No publication, send or push is authorized. See [report](../docs/M0-LICENSE.md).

## Wrapper license decision

The operator selected MIT for this wrapper's original code and documentation.
The root LICENSE records this choice; use MIT in future wrapper package metadata.
This settles the wrapper-license choice, not third-party license applicability or
permission to publish. Preserve libghidra and other dependencies' own notices.

Provider/model selection follows PM: planning uses `gpt-6-astra`; other roles and
compaction use `gpt-6.1-sol`. The fresh typed workflow retains its initialized
planner identity for both root and child planning. No PM gameplay workflows,
cards or history are used.
