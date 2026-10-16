# Task examples

[Install](INSTALL.md), then read the [tutorial and safety limits](TUTORIAL.md)
before invoking either task. Both scripts use your binary and caller-verified
virtual address, explicit language/compiler hints, one close-scoped owner and no
mutation or saved state. The [API](API.md) owns exact grammar/limits and
[FIELDS](../api/FIELDS.md) owns result types. These are the two public scripts;
download or execute the linked sources rather than reconstructing copied blocks.

## Decompile a known function

[decompile.lua](../examples/decompile.lua)

```text
lua5.4 decompile.lua BINARY ADDRESS LANGUAGE_ID COMPILER_SPEC_ID [GHIDRA_ROOT]
```

ADDRESS is exact UInt64 decimal or `0x` hexadecimal text. Stdout starts with
canonical `address=` and `result=<complete|incomplete|fallback|unavailable|error>`,
then `completed=`/`is_fallback=` when a record exists and available pseudocode.
Completed false is incomplete; otherwise fallback true is fallback; completed
true/nonfallback/no error message is complete; remaining records are error.
A nonempty engine error_message always prevents exit 0 and is retained on stderr.
NOT_FOUND is unavailable; other native failures are error. Pseudocode formatting
is data, not a stable golden-output format.

## Inspect a known function

[inspect_function.lua](../examples/inspect_function.lua)

```text
lua5.4 inspect_function.lua BINARY ADDRESS LANGUAGE_ID COMPILER_SPEC_ID MAPPED_START MAPPED_END BYTE_COUNT INSTRUCTION_END INSTRUCTION_COUNT [GHIDRA_ROOT]
```

All bounds are inclusive exact UInt64 text. Confirm the actual mapped extent
before use, including complete instruction bytes. Require
MAPPED_START ≤ ADDRESS ≤ MAPPED_END, checked ADDRESS + BYTE_COUNT − 1 ≤ MAPPED_END,
and ADDRESS ≤ INSTRUCTION_END ≤ MAPPED_END. INSTRUCTION_END must be nonzero
(zero is a native maximum sentinel, not a bounded end). BYTE_COUNT is 1..64;
INSTRUCTION_COUNT is 1..8 with offset zero. Both reads start at ADDRESS; byte
count does **not** bound the independent instruction page. No scanning or
mapping detection is performed, and validation cannot prevent native crashes
on incorrectly confirmed inputs.

After lazy discovery by decompilation, stdout reports canonical `address=`,
`result=`, flags, available quoted `function_name=`, exact
`function_entry_address=`, `function_start_address=`, `function_end_address=`,
`bytes_hex=` (two lowercase digits per byte), and ordered
`instruction_address=` lines. Text metadata is Lua quoted-string escaped.
The engine may generate a name rather than retain the symbol-table name.
Complete requires complete nonfallback decompilation without error text, present
function metadata, exact requested byte length and a nonempty successful page
within requested bounds. A short page need not fill the instruction count and
is not exhaustive. Missing optional metadata or an empty page is unavailable,
not “no code”; available observations remain visible. Native failures are error.

## Shared invocation and error contract

Every required argument and any supplied optional argument must be nonempty;
malformed integers, extra/missing arguments, count/bounds/overflow violations are
rejected before opening. Exit 2 means invocation/validation error; 1 means
native failure or unavailable/incomplete observations; 0 means complete required
observations only. Stderr retains code/operation/backend/message for structured
errors and engine error text. Ordinary Lua exceptions remain ordinary Lua errors.
Close scopes release the owner before os.exit, including raised Lua-error paths;
native crashes are outside that guarantee.

Omit GHIDRA_ROOT for embedded specs (writable HOME on cold cache), or supply an
external root containing `Ghidra/Processors`. Installed copies are in
`share/libghidra/examples` under the actual package data prefix, with byte-identical
manual copies in `share/doc/lua-libghidra/examples`. LuaRocks data prefix and
module deployment roots differ; see [installation](INSTALL.md). Preserve the
selected host ABI, helper DSO/$ORIGIN, notices and [distribution limits](NOTICES.md).
