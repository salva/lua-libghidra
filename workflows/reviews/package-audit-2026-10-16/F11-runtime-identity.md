# F11 — Compiler and runtime package identities are conflated

Severity: low. Category: provenance wording. Transversality: notices.

The runtime table says GCC 13 while the lock records GCC 14 libstdc++/libgcc
packages. GCC 13 is the compiler identity, not that runtime package version.
Evidence: [table](../../../NOTICES.md#L33),
[runtime lock](../../../../native-system.lock.json#L60).

Use precise locked runtime identities or defer to the lock; keep compiler identity
separate. Metadata correction, not a demonstrated binary or licensing defect.
See [dependency report](06-DEPENDENCIES-NOTICES.md).
