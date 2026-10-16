# F12 — Bundled zlib lacks an exact direct notice reference

Severity: low. Category: notice-reference completeness. Transversality: notices/install.

The current table combines engine-bundled zlib and system zlib, linking only the
system notice inventory. The bundled 1.3.1 header has distinct exact notice bytes
already identified in historical source accounting. Evidence:
[table](../../../NOTICES.md#L30),
[existing source identity](../../../M0-LICENSE-SOURCES.tsv#L11).

Distinguish components and link/retain the already identified exact pinned notice;
verify bytes and installation policy. Do not claim legal clearance or a complete
corresponding-source bundle. See [dependency report](06-DEPENDENCIES-NOTICES.md).
