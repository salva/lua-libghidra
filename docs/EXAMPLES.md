# Task examples

Two scripts are included: one prints a function's pseudocode, and the other
reports its metadata, bytes and instruction addresses. Both read your binary
without modifying or saving it. If this is your first run, follow the
[installation guide](INSTALL.md) and [decompilation tutorial](TUTORIAL.md) first.

Use the linked scripts directly. Each expects a function address you have verified
in the loaded binary, plus explicit processor and compiler specifications. Each
opens one native client and releases it before exiting.

## Decompile a known function

[decompile.lua](../examples/decompile.lua)

```text
lua5.4 decompile.lua BINARY ADDRESS LANGUAGE_ID COMPILER_SPEC_ID [GHIDRA_ROOT]
```

`BINARY` is the file to open. `ADDRESS` is the function's virtual entry address,
written as an unsigned 64-bit decimal number or hexadecimal text beginning with
`0x`. It is not a file offset. `LANGUAGE_ID` and `COMPILER_SPEC_ID` select the
processor and compiler conventions; the tutorial shows the supported x86-64 GCC
values. `GHIDRA_ROOT` is optional, as described below.

The script prints `address=` in canonical hexadecimal form, then
`result=<complete|incomplete|fallback|unavailable|error>`. When it receives a
decompilation record, it also prints `completed=`, `is_fallback=` and any
available pseudocode. Do not rely on a particular pseudocode layout.

The result follows these rules, in order:

1. A missing record is `unavailable` for `NOT_FOUND`, or `error` for other failures.
2. A record with `completed=false` is `incomplete`.
3. Otherwise, a record with `is_fallback=true` is `fallback`.
4. A record is `complete` only when `completed=true`, `is_fallback=false` and
   `error_message` is empty or absent. All remaining records are `error`.

A nonempty engine `error_message` is always printed to stderr and prevents exit 0.

## Inspect a known function

[inspect_function.lua](../examples/inspect_function.lua)

```text
lua5.4 inspect_function.lua BINARY ADDRESS LANGUAGE_ID COMPILER_SPEC_ID MAPPED_START MAPPED_END BYTE_COUNT INSTRUCTION_END INSTRUCTION_COUNT [GHIDRA_ROOT]
```

This script first decompiles the function to make its metadata available, then
reads its function record, bytes and one instruction page. The first four
arguments and optional `GHIDRA_ROOT` have the same meaning as for decompilation.
The additional arguments bound the reads:

| Argument | What to supply |
| --- | --- |
| `MAPPED_START`, `MAPPED_END` | First and last addresses of a region you have confirmed is mapped. |
| `BYTE_COUNT` | Number of bytes to read from `ADDRESS`, from 1 to 64. |
| `INSTRUCTION_END` | Last allowed byte address for instruction inspection. It must be nonzero. |
| `INSTRUCTION_COUNT` | Maximum number of instructions to request, from 1 to 8. The page offset is zero. |

All address bounds are inclusive and use exact UInt64 text. The script checks
`MAPPED_START ≤ ADDRESS ≤ MAPPED_END`,
`ADDRESS + BYTE_COUNT − 1 ≤ MAPPED_END` without overflow, and
`ADDRESS ≤ INSTRUCTION_END ≤ MAPPED_END`. It rejects a zero `INSTRUCTION_END`
because the native API interprets zero as the maximum address, not a bounded end.

Both reads start at `ADDRESS`, but **BYTE_COUNT does not bound the instruction
page**. Confirm that the complete bytes of every requested instruction are
mapped, not just its starting address. The script does not scan for code or
detect mappings. Its numeric checks cannot prevent native crashes if the supplied
mapping information is wrong.

The output begins with `address=`, `result=` and the available decompilation
flags. It then prints the observations it could obtain:

- `function_name=` is quoted and escaped as a Lua string, so control characters
  are visible. The engine may generate a name instead of retaining the symbol
  table's name.
- `function_entry_address=`, `function_start_address=` and
  `function_end_address=` are the exact addresses from the function record.
- `bytes_hex=` contains two lowercase hexadecimal digits per byte.
- Each `instruction_address=` line identifies an instruction in the returned
  page, in address order.

`complete` means decompilation completed without fallback or error text, function
metadata was present, the byte read returned the requested length, and the
instruction page was nonempty and within bounds. A short page can still meet
these conditions; it need not contain `INSTRUCTION_COUNT` entries and does not
claim to list every instruction. Missing optional metadata or an empty page is
`unavailable`, not “no code”. Native failures are `error`. Available observations
are printed even when another part of the task fails.

## Shared invocation and error contract

All supplied arguments must be nonempty. Both scripts reject malformed integers,
extra or missing arguments, and invalid counts, bounds or arithmetic overflow
before opening the binary.

| Exit status | Meaning |
| --- | --- |
| 0 | All required observations are complete. |
| 1 | A native or Lua error occurred, or a result was unavailable, incomplete or fallback. |
| 2 | The arguments were invalid. |

Errors go to stderr. Structured errors include `code`, `operation`, `backend`
and `message`; engine error text is also retained. Ordinary Lua exceptions remain
Lua errors. Close scopes release the owner before `os.exit`, including when Lua
raises an error, but cannot guarantee cleanup after a native crash.

Omit `GHIDRA_ROOT` to use embedded processor specifications; their first extraction
needs writable HOME. To use external specifications, supply a root containing
`Ghidra/Processors`.

Installed scripts live in `share/libghidra/examples` under the package data
prefix. Identical manual copies are in `share/doc/lua-libghidra/examples`.
LuaRocks stores package data separately from deployed modules; see
[installation](INSTALL.md) for paths, the matching Lua host and the helper shared
library's `$ORIGIN` layout. For your own scripts, consult the [API](API.md) for
method arguments and limits and [FIELDS](../api/FIELDS.md) for result contents.
Retain the [notices and distribution requirements](NOTICES.md) when sharing artifacts.
