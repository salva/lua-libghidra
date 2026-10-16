# Build and validation

Run from a checkout with absolute input/build/work paths. Use the locked local
native revision and selected engine profile, ordinary C-built Lua 5.4/compatible
headers, C++20 and CMake >=3.26. [Installation](../INSTALL.md) documents source
and qualified-SDK CMake/LuaRocks routes. Do not substitute an HTTP-only SDK or
arbitrary static BFD closure. Source builds alone run unchanged upstream
`cpp/embed_specs.py` with Python >=3.10 stdlib zlib/XML; SDK consumption and Lua
runtime do not require Python or upstream Python bindings.

## Source accounting and fields

PINNED_SOURCE names the existing verified libghidra source at
`d51ca813ae1b6b59519551a9be8c0b1ad74d862d`; candidate and work must not exist:

```sh
lua5.4 scripts/inventory-api.lua "$PINNED_SOURCE" "$FRESH_JSON" --coverage
lua5.4 scripts/check-tooling.lua "$PINNED_SOURCE" "$FRESH_WORK"
# Review candidate semantic differences before replacing api/coverage.json.
lua5.4 scripts/render-fields.lua
lua5.4 scripts/render-fields.lua --check
lua5.4 tests/tooling_fields.lua
bash tests/generator-policy.sh
```

[api tooling](../../api/README.md) describes authority boundaries. Preserve 70/40
accounting and unqualified generated runtime slots. Historical ledgers are not
regenerated. Source-only tests cannot establish Lua/native runtime acceptance.

## Native build and fixtures

For an existing qualified configured build:

```sh
cmake --build "$BUILD" -j4
ctest --test-dir "$BUILD" -N
ctest --test-dir "$BUILD" --output-on-failure
sha256sum -c tests/fixtures/SHA256SUMS
```

Select actual registered tests; do not invent names. Read
[fixture instructions](../../tests/fixtures/README.md) before regenerating inputs.
Authored ELF arithmetic and bytes plus analyzed-project reference data provide
semantic oracles. Fixture generation uses Java/Ghidra only as development tools.
Do not probe guessed/extreme addresses or allocate huge buffers for boundary
validation. Source-only fixture tours live under `tests/examples`; the installed
example runner executes these safe lifecycle/envelope/invalidation regressions
against the selected installed modules alongside the two public task scripts.

A native SDK build is distinct from wrapper installation. After verified input
preparation, with fresh SDK_WORK and SDK:

```sh
BUILD_JOBS=4 sh scripts/build-native-sdk.sh "$INPUTS" "$SDK_WORK" "$SDK"
```

The builder prepares PIC Protobuf/Abseil, source dependencies and validates the
SDK consumer. Reuse matching qualified objects/evidence when only docs change.
For binding changes qualify real Lua standalone/shared/static hosts, one-owner
lifetime, exact conversions, failure cleanup and wrapper allocation/longjmp safety.
Attribute dependency-internal OOM limits rather than claim upstream recovery.

## Installed integration

The current driver requires BUILD_TESTING=ON, built shared/static hosts, fixture
hashes, a fresh PREFIX and existing writable WORK_ROOT. Full additionally requires
non-root permissions, namespace/tool support and EXTERNAL_SPECS:

```sh
bash tests/installed-qualification.sh --build "$BUILD" --prefix "$PREFIX" \
  --work-root "$WORK_ROOT" --external-specs "$EXTERNAL_SPECS" --mode full
bash tests/installed-qualification.sh --build "$BUILD" --prefix "$OTHER_FRESH_PREFIX" \
  --work-root "$WORK_ROOT" --mode reduced
```

Full selects closure/services/examples/documents/mutation/persistence/branch/
profiles/absence. Reduced explicitly omits mutation/persistence/branch/profiles/
absence and is **not full qualification**. Both perform pristine source and
installed document checks. The examples group invokes `tests/installed-examples.sh`
with the selected build's Lua executable, resolved deployed module directories
and installed example root. It checks public tasks and source-only safe regressions;
external-spec checks run when the external root is supplied, otherwise they are
explicitly omitted. Do not claim either driver mode passed merely from reading
its source.

Document-only checks use the producing build's exported manifest, never an
inferred sibling manifest. All arguments are absolute; fresh work must not exist:

```sh
lua5.4 tests/installed_documents.lua source "$SOURCE" "$MANIFEST"
lua5.4 tests/installed_documents.lua installed "$DOCUMENT_ROOT" "$SOURCE" "$MANIFEST"
bash tests/installed-documents.sh "$DOCUMENT_ROOT" "$SOURCE" "$MANIFEST" "$FRESH_WORK"
lua5.4 tests/package_documents.lua "$SOURCE" "$OTHER_FRESH_WORK"
```

DOCUMENT_ROOT is the actual share/doc/lua-libghidra subtree. LuaRocks package data
uses the actual versioned package prefix, distinct from deployed module roots.
Source checks validate selected graph/content; installed checks also enforce exact
membership, regular files and source bytes. Mutation probes establish rejection
sensitivity; a manually staged document tree is not a native installation pass.

External specs and embedded specs need distinct runtime checks. External roots
bypass extraction; embedded cold/warm/unwritable HOME cache handling is separate.
Use existing installed profile/absence drivers for their declared scope. Preserve
partial/fallback/error outcomes, category-specific persistence, ABI/host identity
and unavailable-check reporting. A mock, green renderer or native helper alone
does not prove Lua runtime behavior.
