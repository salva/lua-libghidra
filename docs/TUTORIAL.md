# Decompile your own function

First [install](INSTALL.md) the module and select its matching ordinary Lua 5.4
host. [API](API.md) defines exact calls, defaults and limits;
[FIELDS](../api/FIELDS.md) describes detached result records.

## Before calling the engine

Use a supported input and a **known mapped virtual function entry**, never a file
offset or a guessed integer. For an unstripped ELF, `nm -n --defined-only BINARY`
can identify a function. Its unprefixed hexadecimal output must gain `0x` before
passing it to Lua: bare all-digit text is decimal. Confirm the load mapping and,
for inspection, the complete bytes of every requested instruction independently.
Exact UInt64 parsing and bound checks do not detect mappings. Extreme/unmapped
addresses can cause a native process crash that Lua errors and close scopes
cannot recover. Run untrusted inputs in an appropriately isolated process.

Only one binding-owned client may be live per process, across Lua states.
Aliases share that owner; logical program closure is not owner release. Do not
mix independently managed engines. Calls are synchronous; protection/deadline
fields are ignored by this engine profile. They are not crash containment or a
cancellation deadline. There is no dependency-internal OOM recovery guarantee.

## Run the task

Use the [decompile script](../examples/decompile.lua), not a copied Lua block.
For a checkout, EXAMPLE is the absolute path to that file. An installation has
`share/libghidra/examples/decompile.lua` under its **package data prefix**.
For CMake this is the actual install prefix (including a `--prefix` override).
For LuaRocks obtain CMAKE_INSTALL_PREFIX from the actual rock build cache: data
normally resides in `lib/luarocks/rocks-5.4/lua-libghidra/scm-1` under its tree,
not the deployed Lua module root. Confirm the actual install record.

Set BINARY, ADDRESS, LANGUAGE_ID and COMPILER_SPEC_ID to your verified input.
No address is selected by the script. Use the host and search paths from
[installation](INSTALL.md), with the helper DSO next to `_native.so` and $ORIGIN
preserved. Replace the following absolute paths and caller-confirmed values:

```sh
GOOD_LUA=/usr/bin/lua5.4
EXAMPLE=/absolute/package-prefix/share/libghidra/examples/decompile.lua
BINARY=/absolute/path/to/supported.elf
ADDRESS=0xYOUR_VERIFIED_FUNCTION_ENTRY
LANGUAGE_ID=x86:LE:64:default
COMPILER_SPEC_ID=gcc
"$GOOD_LUA" "$EXAMPLE" "$BINARY" "$ADDRESS" "$LANGUAGE_ID" "$COMPILER_SPEC_ID"
```

Omitting the final GHIDRA_ROOT uses embedded specs. Cold extraction needs writable
HOME; a warm cache does not demonstrate cold-cache behavior. To use external
specs append an absolute root containing `Ghidra/Processors`; this is spec data,
not a requirement to start the Ghidra application or Java.

## Interpret the result

Stdout begins with canonical `address=` and `result=`. `complete` means completed,
nonfallback decompilation without an engine error message, not merely returned
text. `incomplete`, `fallback`, `unavailable` (optional NOT_FOUND) and `error` are
distinct non-success outcomes. Flags and available pseudocode follow. Stderr
preserves engine error text and structured code/operation/backend/message.
Exit 0 means complete observations; 1 means unavailable, incomplete or failed;
2 means invocation/validation error before open. Allocation errors are ordinary
Lua errors, not fabricated native envelopes. Normal and raised Lua-error paths
release the owner through a Lua 5.4 close scope before exit; a native crash does
not promise cleanup. `check` tests presence, not completed/nonfallback status.

Decompilation discovers functions lazily; there is no eager analysis pass.
[Bounded inspection](EXAMPLES.md#inspect-a-known-function) decompiles first, then
requests metadata, bytes and an independent instruction page. A short page is
not exhaustive enumeration; an empty page means unavailable, not “no code”.

## Data and persistence limits

Records are detached snapshots, not mutable native handles. ReadBytes is bounded;
only function/symbol/memory-block families have iterators. Other families are
pages-only; string discovery is an empty string stub, not proof of no strings.
Batch decompilation can have partial outcomes. These scripts do not mutate or save.
Saving is category-specific, not general project persistence: no autosave,
transaction or rollback is implied by close/discard. Raw/FileBytes projects are
not qualified by the special external-ELF/no-FileBytes project route. True-local
retyping is unqualified on the exercised profile. Read the
[complete limits](API.md#ownership-persistence-and-effective-limits) before editing.
Local build success grants no distribution permission; see [NOTICES](NOTICES.md).
