# F03 — Selected host/header ABI lacks deliberate mismatch rejection

Severity: medium. Category: boundary validation. Transversality: build/native entry.

LuaRocks's selected interpreter is disconnected from ambient pkg-config header
selection, and module initialization does not call Lua's standard ABI check.
Static risk: ordinary qualified hosts are not shown broken, but incompatible
numeric configurations can load without deliberate early rejection. Evidence:
[discovery](../../../../cmake/Binding.cmake#L3),
[entry](../../../../src/boundary.cpp#L185),
[driver](../../../../scripts/luarocks-build.lua#L22).

Choose explicit compatible host/header selection or a clearly enforced single
profile; reject mismatch before publication without linking another Lua VM.
Do not broaden supported platforms. See [packaging report](03-PACKAGING.md).
