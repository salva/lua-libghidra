# Fresh independent review: validation and execution plan

Reviewed HEAD `31cb7ee846f6cea4b583e1a4f633c4a46b71d6bd` against upstream
`d51ca813ae1b6b59519551a9be8c0b1ad74d862d` in
`/home/salva/g/ml/tmp/lua-libghidra-upstream`. Read AGENTS, README, SPEC,
DESIGN, PLAN, COVERAGE, EXAMPLES and workflows/OPERATIONS. No prior review
contents were read. Scope: objective acceptance, milestone dependencies,
feasibility, fixtures, complexity and autonomous-execution clarity.

## Findings

No necessary concrete defects found. No corrective edits requested.

## Evidence and assessment

- **Objective acceptance:** SPEC:259–275 and PLAN:17–27 require known bytes,
  instructions and completed nonfallback decompilation with semantic assertions.
  Mere nonempty output, unsupported results and missing evidence cannot pass.
  COVERAGE:89–97 requires per-operation fixture/assertion and field manifests
  before adapters ship; this makes later service slices executable without
  prematurely inventing their contracts.
- **Dependency order:** PLAN:7–44 places licensing, dependency/spec compatibility,
  real fixture readiness and ownership/error-boundary proof before broad adapters.
  PLAN:94–125 explicitly permits core → M5 without full-tier M4, while requiring
  M5 for either release. M0 native fixture probes do not require a Lua binding.
  Unresolved operator decisions remain explicit at PLAN:135–138.
- **Fixture feasibility:** PLAN:17–23 calls for both authored binaries and generated
  analyzed projects, with reproducible provenance. This matches upstream
  `cpp/src/local_client.cpp:377–403`, where leaf queries require the analyzed
  project reference index, and `cpp/examples/decompile_project.cpp:39–45`, which
  demonstrates project-backed native OpenProgram. Development Java/Ghidra use is
  explicitly distinguished from installed-runtime dependencies (SPEC:14–18).
- **Attainable qualification:** upstream `local_client.cpp:1299–1308` confirms
  constant-empty ListDefinedStrings; SPEC:268–271 and PLAN:82–91 correctly demand
  fidelity rather than impossible populated discovery. Upstream lines 1059–1070
  paginate function candidates before filtering missing signatures; DESIGN:121–130
  and PLAN:82–84 correctly avoid an unjustified signature iterator. These are
  concrete native limitations, not silently weakened positive-operation gates.
- **Scope and complexity:** SPEC:9–26, DESIGN:4–17 and COVERAGE:38–45 constrain
  delivery to local native functionality, one process-owned client, one conversion
  path and explicit tiers. HTTP, SWIG and extra object hierarchies are excluded.
  DESIGN:40–70 identifies a substantive longjmp/finalizer qualification gate,
  including direct C API fallback, rather than assuming a wrapper library solves
  lifetime safety. PLAN:38–41 avoids impractical multi-gigabyte boundary reads.
- **Examples and execution:** EXAMPLES:3–7 assigns manifest-backed execution to M2
  and mutation execution to M3, matching PLAN:55–59 and 89–92. M5 covers clean
  offline installs, both spec profiles, existing-VM linkage, normalized Python
  comparisons and provenance. OPERATIONS:15–25 separates deployment/Run approval
  from product planning; AGENTS:6–9 and PLAN:27 prohibit treating these proposals
  as implementation authorization.

This approves the reviewed planning baseline in this dimension. Native runtime,
licensing applicability and dependency compatibility remain explicitly unpassed
milestone gates; their future results are not asserted by this review.

VERDICT APPROVED
