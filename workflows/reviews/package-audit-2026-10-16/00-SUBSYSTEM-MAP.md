# Package subsystem map

Audit baseline `4903eb7`; paths below are repository-relative. This is audit
orientation, not a replacement for maintained user or developer documentation.

| Layer | Main paths | Responsibility / boundary |
| --- | --- | --- |
| Idiomatic Lua | `lua/libghidra/init.lua`, `iterator.lua` | Session facade, record extraction, lazy iteration, generation validity and user errors. |
| Faithful Lua surface | `lua/libghidra/lowlevel.lua` | Exposes complete native envelopes and shared exact-value/check helpers. |
| Native value boundary | `src/boundary.cpp`, `boundary.hpp` | UInt64, Lua type/range checking, protected conversion, module initialization and errors. |
| Native ownership/dispatch | `src/owner.cpp`, `process_guard.*` | One native owner shared by views, closure/GC, native serialization, method parsing/dispatch and exceptions. |
| Record conversion | `src/slice_convert.hpp`, `core_convert.hpp`, `full_convert.hpp` | Detached model/request/response mapping for included native-local operations. |
| Build integration | `CMakeLists.txt`, `cmake/Binding.cmake`, `lua-libghidra-scm-1.rockspec` | Pinned source or installed SDK, whole-archive/PIC, native DSO/guard, host Lua ABI, tests and installed documents. |
| Source/SDK preparation | `scripts/native_prepare.lua`, `prepare-native.lua`, `build-native-sdk.sh`, `luarocks-build.lua`, locks | Offline/pinned inputs, authorized engine profile, build prerequisites and source/SDK installation. |
| Inventory/tooling | `scripts/inventory*.lua`, `tool_json*.lua`, `check-tooling.lua`, `api/` | Source API/field accounting, rendering, independent historical runtime evidence and corruption/consumer tests. |
| Runtime/boundary tests | `tests/boundary*`, `ownership*`, `reentry_host.cpp`, `read_order_host.cpp`, `m2*`, `m3*`, `m4*` | Lua/native positives, failures, ownership/GC, process concurrency, field semantics, iteration and persistence. |
| Installed qualification | `tests/installed-*`, `installed_*.lua`, `package-foundation.sh`, `wrapper-sanitize.sh` | CMake/LuaRocks source/SDK route validation, existing VM hosts, external/embedded specs and runtime absence. |
| Inputs/examples | `tests/fixtures/`, `examples/` | Authored ELF and analyzed project provenance, executable first-slice and mutation examples. |
| User/reference material | `README.md`, `docs/API.md`, `EXAMPLES.md`, `NOTICES.md`, `api/FIELDS.md` | Current entry points; audit whether beginners can install/use package and find limits without reading history. |
| Contracts/developer material | `docs/SPEC.md`, `DESIGN.md`, `COVERAGE.md` | Requirements, architecture and operation dispositions; check current accuracy versus historic proposals. |
| Qualification/history | `docs/M*`, `INSTALLED-*`, `PACKAGE-*`, `FULL-CROSSWALK.md`, `PLAN.md`, `docs/evidence/`, `docs/reviews/`, `api/history/` | Mixed current evidence and chronological development material; classify and propose clear audience separation. |
| Automation/operator material | `workflows/`, `.github/skills/`, ignored `.saivage/` | Host-side operational guidance and saved autonomous state; not package runtime or ordinary user onboarding. |

Native dependency boundary: exact `0xeb/libghidra` and separately locked approved
Ghidra engine profile, plus system BFD/compression/C++ closure. Upstream defects
are documented limitations, not new repair requirements. Python exception covers
only the unchanged upstream SOURCE spec generator; no Python bindings or installed
Python runtime requirement. Original wrapper LICENSE and upstream terms remain
separate; review technical shipping accuracy without legal-clearance claims.
