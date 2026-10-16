# F10 — Lua leaf-function positive checks only nonempty output

Severity: medium. Category: missing semantic regression oracle. Transversality: local tests.

The real-project Lua test accepts any nonempty leaf list. A native authored probe
already knows two exact leaf addresses and excludes the caller, but does not test
Lua conversion/paging. Evidence: [Lua assertion](../../../../tests/m4_services.lua#L15),
[authored expectation](../../../../tests/project_probe.cpp#L19).

Reuse existing fixture expectations through public Lua, verify both identities,
caller exclusion, range and limit-one offsets including exhaustion. No new
analyzed fixture or backend is needed. Static test gap, not a demonstrated leaf
implementation defect. See [test-quality report](05-TEST-QUALITY.md).
