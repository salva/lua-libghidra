# Lua binding design

Status: proposed, 2026-10-15. Implements [SPEC.md](SPEC.md). Technology selection
is a reasoned recommendation, not a completed build benchmark.

## 1. Decision: C++20 + sol2 + a small Lua facade

Use **sol2 (the sol3 API)** for explicit native module registration and owning
userdata, CMake/Ninja for building, and LuaRocks for source installation. Wrap
libghidra's C++ IClient and factory APIs directly. Keep Lua conversions explicit;
do not expose STL containers, StatusOr, inheritance trees or native model objects.

| Approach | Fit and tradeoff | Decision |
| --- | --- | --- |
| sol2 | Native C++ ownership, tables, userdata, multiple returns and existing Lua-state integration; template compile cost and error-boundary care required | Preferred for this C++20 SDK |
| Direct Lua C API | Maximum control and minimal dependency; manual stack/lifetime/error bookkeeping across a broad record API | Narrow escape hatch; fallback if spike fails |
| SWIG Lua | Generates broad C++ wrappers; custom typemaps still needed for tables, uint64, StatusOr and ownership; generated class surface is not the desired API | Not the default |
| LuaBridge3 | Plausible lighter C++ registration alternative; still needs the same explicit record/result adapters | Reconsider only for a measured sol2 blocker |
| LuaJIT FFI | Good for stable C ABIs; upstream exposes a C++ API and target is standard Lua | Would require a new C shim and exclude primary runtime |
| Pure Lua HTTP/protobuf | Lightweight remote-only possibility | Duplicates transport and cannot deliver local native backend |
| Python bridge / nanobind | Existing Python implementation can be a reference | nanobind targets Python, not Lua; extra runtime is unnecessary |

Use a pinned stable sol2 release after a compiler/Lua 5.4 smoke spike; do not use
a floating branch. Enable argument/type safety in all supported builds. Do not
choose a library based on its self-published performance rankings. The spike must
demonstrate multi-result errors, exact integers, nested table conversion,
idempotent destruction and ordinary C-built Lua error handling before expansion.

## 2. Layers and proposed layout

```text
lua/libghidra/init.lua      public facade, check(), lazy iterators
lua/libghidra/types.lua     LuaLS annotations (no runtime class hierarchy)
src/module.cpp             luaopen_libghidra__native, registration
src/client.*               owning ClientHandle and dispatch boundaries
src/uint64.*               exact value userdata and checked conversions
src/convert/               request validators and response-to-table converters
src/bindings/              service-group adapters
tests/lua/                 public contract and lifecycle tests
tests/native/              native adapter/fault-injection tests
tests/integration/         offline and real-host scenarios
tests/fixtures/            authored source + reproducible binary manifests
examples/                  small executable Lua examples
api/coverage.*             reviewed operation/field coverage manifest
cmake/                     dependency and packaging integration
```

`require("libghidra")` loads the facade, which loads `libghidra._native`.
The native module attaches to the caller's state via a state view; it never owns
or closes that state. Registration returns one module table without global writes.
Keep all Lua references state-local and destroy them before the host closes Lua.

`ClientHandle` owns one `unique_ptr<IClient>` and closed/backend metadata. It
does not expose raw pointers. Responses are copied into Lua values; requests are
converted to owning native structures before dispatch. Release native temporary
storage after conversion. No client-owned views escape into Lua.

## 3. Call pipeline and errors

1. Validate receiver and options, unknown keys, required fields and numeric ranges.
2. Build the appropriate native request without coercing strings to booleans or
   floats to integers. Keep missing optional fields distinct from explicit defaults.
3. Invoke one public upstream operation, catching native exceptions.
4. Convert StatusOr failure to `nil, Error`; require a present value on success,
   otherwise return `INTERNAL`. Preserve backend status evidence.
5. Convert results with explicit field converters; no protobuf round-trip or JSON
   intermediate representation.

Do not bind naked upstream methods and rely on sol2 defaults to establish this
contract. Return tuples/variadic results deliberately. `check()` and iterator
error raising happen in Lua after native calls return.

Lua built as C may use longjmp for errors, including allocation errors. RAII and
sol2 are not a blanket solution. The spike must audit allocating Lua API calls
and protected-call placement: do not allow a Lua longjmp to skip live C++ objects
requiring destruction. Use a protected marshalling trampoline with native result
ownership held outside the jumped frames, or Lua-owned finalizable storage;
keep raw error-raising trampolines free of nontrivial local destructors. Inject
allocator failures at conversion points. Avoid calling Lua callbacks during SDK
execution. If safe integration cannot be demonstrated, use a small direct C API
boundary with the same protected ownership scheme rather than changing public API.

## 4. Conversion and coverage strategy

Central converters own UInt64, bytes, enums, optionals, arrays and error objects.
Use small per-record/per-request converters over public headers. Every service
adapter must list supported input keys, defaults, output fields and error cases.
Use the coverage manifest to check registration and documentation drift.

Start with handwritten adapters. If repetitive conversion dominates, introduce a
small declarative field manifest and deterministic generator with checked output;
do not introduce a full C++ parser or automatically bind all headers. Protobuf is
the wire contract, not necessarily the complete C++/Python convenience API.

Canonical uint64 storage is `std::uint64_t`. Parsing checks digits, prefixes,
trailing bytes and overflow before multiplication/addition. `to_integer()` checks
`LUA_MAXINTEGER`; signed values are never reinterpreted as unsigned. UInt64 value
comparisons accept UInt64 operands; explicit construction avoids surprising mixed
string/number equality. Arithmetic helpers reject negative offsets and overflow.

Core method names preserve Python discoverability. Document each intentional
shape difference, e.g. `close_program{policy="save"}` rather than a Python enum
class and `get_decompilation(address, {timeout_ms=...})` rather than keyword args.
The registry must resolve C++/Python coverage differences explicitly rather than
claiming that one language's feature list proves the other backend supports it.

## 5. Backends and lifecycle

HTTP factory options map to public HttpClientOptions: base URL, auth token,
client identity, connect/read/write timeout milliseconds, and retry settings.
Default to upstream zero retries; do not add transparent mutation retries.
Construction need not establish connectivity: `get_status()` verifies reachability.
Do not log credentials. Unsupported TLS/auth configurations must fail clearly,
not fall back to an insecure transport.

Local factory options mirror native options: `ghidra_root`, `state_path`,
`default_arch`, `pool_size`. Verify native open/detection semantics rather than
porting Python's format-detection implementation. A bare binary does not imply
full function discovery: upstream documents loader-symbol-only enumeration and
address-driven decompilation. Some methods require analyzed project data or a
live host. Report `NOT_SUPPORTED` faithfully and expose capabilities.

`close()` destroys the client once; GC and `__close` call the same nonthrowing
release path. Explicit program/project close methods return operation errors and
accept documented policies. Tests establish any state_path autosave effects.
Remote ownership stays with the operator; client finalization never issues an
implicit remote shutdown request. No background tasks are created initially.

Out-of-band HTTP cancellation and headless launch are deferred. A blocking Lua
call cannot be interrupted by another coroutine on the same state; exposing an
apparently asynchronous cancel method would misrepresent this limitation.

## 6. Pagination

Page calls preserve response envelopes. Iterators specify which record field to
read and fetch only when the current page is exhausted. Advance offsets by
actual records returned, not requested page size. Use upstream total/continuation
metadata where available; absent reliable metadata, continue until an empty page
rather than treating a server-capped short page as completion. Detect repeated
non-progress pages and offset overflow and raise a structured pagination error.
Pin these rules per operation; do not assume all response models share metadata.
Holding an iterator keeps its handle alive but does not prevent explicit close;
the next fetch on a closed client fails. No global page cache.

## 7. Build and distribution

Use CMake >=3.26 and C++20, matching the inspected upstream. Pin libghidra, sol2,
and the compatible Ghidra source/spec revision in a dependency lock document.
Prefer an explicitly supplied SDK/source directory; offer a reproducible pinned
fetch path and a documented offline build path. Verify actual exported CMake
target names during the spike rather than guessing package configuration names.

Upstream source targets are `libghidra_client` and `libghidra_local`. Local builds
require `GHIDRA_SOURCE_DIR`; runtime specs may be embedded. Set PIC for every
static dependency linked into the Lua shared module: upstream currently enables
global PIC for Python builds, which does not automatically cover this binding.
Compile against exactly the selected Lua ABI and never bundle a second Lua VM.
Account for protobuf/Abseil and HTTP dependencies and C++ ABI compatibility.

LuaRocks uses a CMake-backed source rockspec and installs facade, module, type
annotations, docs and notices in normal Lua locations. Test staged installation
and dynamic-library discovery from a fresh working directory. Package metadata
reports binding version, upstream commit, Lua ABI and enabled backends. An
HTTP-only package must not advertise offline functionality. Avoid relying on
Python wheel binaries as a C++ SDK.

## 8. Verification and sources

Use CTest to orchestrate plain Lua assertion tests, native tests and integration
tiers; no large test framework is required initially. Add LuaLS annotations and
StyLua formatting. Native sanitizers and injected errors cover ownership; real
fixtures and a real host cover behavior. Python is an optional development oracle,
never a dependency of the installed module. Record dependency/compiler versions,
fixture hashes and host versions with comparisons.

Inspected upstream sources at the pinned commit:

- [Python API and examples](https://github.com/0xeb/libghidra/tree/d51ca813ae1b6b59519551a9be8c0b1ad74d862d/python)
- [C++ public interface](https://github.com/0xeb/libghidra/tree/d51ca813ae1b6b59519551a9be8c0b1ad74d862d/cpp/include/libghidra)
- [C++ behavior/build docs](https://github.com/0xeb/libghidra/tree/d51ca813ae1b6b59519551a9be8c0b1ad74d862d/cpp)
- [License](https://github.com/0xeb/libghidra/blob/d51ca813ae1b6b59519551a9be8c0b1ad74d862d/LICENSE)
- [sol2 capabilities](https://sol2.readthedocs.io/en/latest/features.html)
- [SWIG Lua documentation](https://www.swig.org/Doc4.3/Lua.html)
- [Lua 5.4 manual](https://www.lua.org/manual/5.4/manual.html)

No binding build or integration experiment has been performed during this design.
