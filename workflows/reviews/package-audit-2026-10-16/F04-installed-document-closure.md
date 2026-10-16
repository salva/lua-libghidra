# F04 — Installed documentation has broken local links

Severity: medium. Category: packaging/navigation. Transversality: docs/install/tests.

A retained installed prefix had 15 missing local Markdown-link occurrences.
The full docs/api directory copy omits referenced workflow/test/script targets;
current freshness tests do not check destinations. Evidence:
[installation policy](../../../../cmake/Binding.cmake#L143),
[document tests](../../../../tests/installed_documents.lua#L11).

Define a deliberate installed user-document set, keep notices/provenance available,
and check local-link closure plus freshness for both installation mechanisms.
Coordinate with F06; do not install all automation merely to preserve old links.
See [packaging report](03-PACKAGING.md).
