# Fresh independent review — Lua public API

Reviewed HEAD `31cb7ee846f6cea4b583e1a4f633c4a46b71d6bd` against upstream
`d51ca813ae1b6b59519551a9be8c0b1ad74d862d`. Read AGENTS, README, SPEC, DESIGN,
PLAN, COVERAGE and EXAMPLES; no prior review documents were read.

## Findings

No necessary concrete document defects found in this dimension. No fixes required.

Evidence checked:

- **Return values and errors:** SPEC 50–68 separates absent optional records,
  native failures, incomplete decompilations and false mutation outcomes.
  Upstream `cpp/src/local_client.cpp:295–320,355–361,1191–1197` supports those
  distinctions. `check` preserves false values and the detached third-result
  envelope; EXAMPLES 19–38 uses its two-result output consistently.
- **Exact numbers and Lua ergonomics:** SPEC 113–168 defines 1-based arrays
  separately from native ordinals, exact UInt64 conversion, checked operations,
  Lua equality dispatch and userdata table-key limitations. Its concrete type
  examples agree with upstream `cpp/include/libghidra/models.hpp:282–300,559–595`.
  Open metadata preserves the separate presence flag and zero entry point
  (`models.hpp:47–60`; SPEC 33–40; EXAMPLES 27–29).
- **Pagination and iteration:** SPEC 94–107,166–170,238–257 and DESIGN 80–136
  address compound integer limits, zero-end normalization, linear instruction
  decoding, short pages, cursor domains and mutation invalidation before buffered
  yields. Upstream `local_client.cpp:364–374,1200–1211` confirms function paging
  and the instruction `limit + offset` boundary. Raising structured iterator
  errors is compatible with generic-for use and the examples' protected calls.
- **Shared public views:** SPEC 174–196 and EXAMPLES 60–75 consistently distinguish
  program closure, reopening and final owner closure; historical response tables
  remain detached. The public escape hatch does not imply a second client.

## Qualification versus defects

Per-family field maps/order comparators, real Lua execution, allocator-failure
behavior and positive backend cases are explicitly pending milestone gates
(COVERAGE 89–97; PLAN M0–M5), not claimed results. Their pending status is not a
document defect. Alternative numeric representations or iterator conveniences
would be optional API preferences, not required corrections. Approval is of this
proposed API contract, not runtime qualification or authorization to implement.

VERDICT APPROVED
