# Decompile your own function

This tutorial uses the supplied `decompile.lua` script to print pseudocode for
one function in your binary. You choose the function; the script opens the binary,
requests decompilation, reports the result and releases the native client.

First [install the module](INSTALL.md) and keep the Lua executable and module
search paths from that installation. The supported starting point is a Linux
x86-64 ELF binary with a known function entry address.

## Before calling the engine

Find a **known mapped virtual function entry**: the address where a function
begins in the loaded program, not its position in the binary file. For an
unstripped ELF, `nm -n --defined-only BINARY` can help identify a function.
Confirm that its address belongs to a loaded region of your input.

Add `0x` to the hexadecimal address printed by `nm`. Without that prefix,
all-digit text is read as decimal. The binding preserves addresses exactly as
unsigned 64-bit values, but a valid number is not necessarily a valid address.

**Do not guess or scan for an address.** An extreme or unmapped address can cause
a native process crash, which Lua error handling cannot recover from. Run
untrusted inputs in an appropriately isolated process. Calls are synchronous;
the engine ignores protection and deadline fields, so they cannot contain a
crash or cancel a call. Recovery from an out-of-memory failure inside a dependency
is not guaranteed.

## Run the task

Locate [decompile.lua](../examples/decompile.lua). In a checkout it is under
`examples/`; in an installation it is under `share/libghidra/examples` within
the package data prefix. For CMake, this is your install prefix, including any
`--prefix` override. For LuaRocks, use `CMAKE_INSTALL_PREFIX` from the rock build's
cache and confirm it against the install record. LuaRocks normally puts package
data under `lib/luarocks/rocks-5.4/lua-libghidra/scm-1` in its tree, separately
from the deployed Lua modules.

Replace the paths and address below with your own values. `LANGUAGE_ID` selects
the processor specification; `COMPILER_SPEC_ID` selects its compiler conventions.
The values shown are for the supported x86-64 GCC input. The script does not
choose an address for you. Keep the installed helper shared library next to
`_native.so` so its `$ORIGIN` lookup continues to work.

```sh
GOOD_LUA=/usr/bin/lua5.4
EXAMPLE=/absolute/package-prefix/share/libghidra/examples/decompile.lua
BINARY=/absolute/path/to/supported.elf
ADDRESS=0xYOUR_VERIFIED_FUNCTION_ENTRY
LANGUAGE_ID=x86:LE:64:default
COMPILER_SPEC_ID=gcc
"$GOOD_LUA" "$EXAMPLE" "$BINARY" "$ADDRESS" "$LANGUAGE_ID" "$COMPILER_SPEC_ID"
```

With no final `GHIDRA_ROOT` argument, the script uses embedded processor
specifications. The first extraction needs writable HOME; later runs can reuse
the cache. To use external specifications, append an absolute root containing
`Ghidra/Processors`. Only the specification files are needed: neither Java nor
the Ghidra application runs.

## Interpret the result

Read `result=` before interpreting the pseudocode. The first output line,
`address=`, shows your address in a consistent hexadecimal form. The result line
then tells you whether decompilation completed:

| Result | Meaning |
| --- | --- |
| `complete` | The engine completed decompilation without fallback output or an error message. |
| `incomplete` | The engine returned a record with `completed=false`. |
| `fallback` | The engine returned fallback output rather than a complete decompilation. |
| `unavailable` | No decompilation record was available (`NOT_FOUND`). |
| `error` | Opening or decompilation failed, or the returned record did not meet the success conditions. |

When a record is available, `completed=` and `is_fallback=` follow, along with
any pseudocode. Text can still be present for an incomplete or fallback result;
its presence alone does not mean success. Engine error messages go to stderr.
Structured errors also include `code`, `operation`, `backend` and `message`, so
you can see which call failed and why.

The script exits with **0** only for a complete result, **1** for an unsuccessful
result or runtime error, and **2** for invalid arguments rejected before opening
the binary. See [the example reference](EXAMPLES.md) for the exact classification
rules. In your own Lua code, remember that `check` tests whether a value exists;
it does not check `completed` or `is_fallback`.

The script uses a Lua 5.4 close scope to release the native client on both normal
return and a raised Lua error. Allocation errors remain ordinary Lua errors.
Cleanup cannot be guaranteed after a native crash. Only one binding-owned client
may be live per process, even across Lua states. Session and lowlevel aliases
share that owner; closing a program does not release it. Do not mix independently
managed engines in the same process.

The engine discovers functions as it decompiles them rather than analyzing the
whole binary when it opens. For a next step, try
[inspecting the same function](EXAMPLES.md#inspect-a-known-function). That script
decompiles first, then reads metadata, bytes and a bounded page of instructions.
You must independently confirm that the complete bytes of every requested
instruction are mapped. A short page does not enumerate all instructions, and an
empty page means unavailable, not “no code”.

## Data and persistence limits

Both example scripts only read; they do not edit or save your program. Returned
records are detached snapshots: changing a Lua table does not change the native
program. The [API reference](API.md) explains methods and return values, and the
[field reference](../api/FIELDS.md) describes the contents of each record.

As you move beyond these examples, keep these limits in mind:

- Byte reads have a size limit. Only functions, symbols and memory blocks have
  iterators; other collections must be read as pages.
- String discovery is an empty stub, not proof that a binary contains no strings.
  Batch decompilation can return a mixture of successful and unsuccessful results.
- Saving preserves only certain categories of edits. There is no autosave,
  transaction or rollback when you close or discard a program.
- General raw/FileBytes project loading is not supported by the tested profile.
  The working external-ELF project route has no FileBytes and does not establish
  support for other projects. True-local retyping has not been validated on this
  profile.

Read the [complete limits](API.md#ownership-persistence-and-effective-limits)
before editing, and the [notices](NOTICES.md) before distributing linked artifacts.
