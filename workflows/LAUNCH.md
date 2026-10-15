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
M0 license applicability/distribution and engine/spec gates remain real checks:
record the actual evidence, and raise a specific operator question only when a
decision or permission cannot be established. Do not invent a license choice or
authorization to publish. Continue independent prerequisite work where possible.

Work only in `/work/lua-libghidra` and container-local dependency/build paths.
The Saivage runtime is at `/opt/saivage` read-only. Install build dependencies with
guest-local sudo as needed; preserve project-local credentials. Source/dependency
caches and temporary build outputs must be ignored by Git. Commit implemented
changes promptly and do not push or publish without operator permission.

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

## Wrapper license decision

The operator selected MIT for this wrapper's original code and documentation.
The root LICENSE records this choice; use MIT in future wrapper package metadata.
This settles the wrapper-license choice, not third-party license applicability or
permission to publish. Preserve libghidra and other dependencies' own notices.

Provider/model selection follows PM: planning uses `gpt-6-astra`; other roles and
compaction use `gpt-6.1-sol`. The fresh typed workflow retains its initialized
planner identity for both root and child planning. No PM gameplay workflows,
cards or history are used.
