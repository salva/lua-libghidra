# F13 — Final package documentation must omit Saivage references

Priority: required operator acceptance condition, added 2026-10-16 after audit.
Category: documentation delivery boundary. Transversality: package documentation.

The operator requires the final package documentation to contain no references to Saivage except
an optional acknowledgment that it was used in creating the project. This is not
a newly reproduced bug or permission to erase Git history or deployment state.

The operator explicitly clarified that this applies to documentation, not source
code, build tools or tests. Define the final package documentation set: it must not
contain Saivage paths, card URIs, harness-specific instructions, audit plans or
process history. User instructions must define ordinary caller-owned paths.
Development/operator records may remain separately outside the package docs; no
live deployment changes or deletion of historical evidence are authorized.

The design must cover documentation manifests, links and installed documentation
content checks, with only a narrowly designated creation-credit exception. F04,
F05 and F06 supply observed examples. Newly generated design and audit documents
are development records, not final package user documentation. F08 remains an
independent test-usability issue; it is not expanded by this docs-only condition.
