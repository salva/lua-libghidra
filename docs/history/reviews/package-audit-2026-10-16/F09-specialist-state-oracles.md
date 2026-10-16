# F09 — Specialist mutation and persistence oracles are too weak

Severity: medium. Category: false-positive tests/evidence. Transversality: tests/docs.

Several specialist edits check acknowledgements without changed-state readback;
some loss-on-reload assertions lack a visible pre-save state. An int-to-int
parameter change cannot distinguish a no-op. Some crosswalk citations overstate
their test's coverage. No production mutation failure was observed. Evidence:
[services](../../../../tests/m4_services.lua#L29),
[persistence](../../../../tests/m4_persistence.lua#L20),
[crosswalk](../../../FULL-CROSSWALK.md#L40).

Use bounded create/read/edit/read/delete sequences and before/after reload
comparisons for observable supported categories; truthfully narrow claims where
upstream edits are ignored or unobservable. Preserve partial-effect truth, avoid
engine repairs and do not treat acknowledgements as state guarantees.
See [test-quality report](05-TEST-QUALITY.md).
