# Task examples

Two scripts are included: one prints a function's pseudocode, and the other
reports its metadata, bytes and instruction addresses. Both read your binary
without modifying or saving it. If this is your first run, follow the
[installation guide](INSTALL.md) and [decompilation tutorial](TUTORIAL.md) first.

The inline tasks below build on the tutorial's `lesson.elf`; the two downloadable
scripts remain useful for command-line work. Each expects an address you have verified
in the loaded binary, plus explicit processor and compiler specifications. Each
opens one native client and releases it before exiting.

## Read bytes and instructions in Lua

Continue inside `lesson.lua`, before its Session goes out of scope. After the
tutorial's external disassembly, choose the first complete instruction only.
On the illustrative build it is a four-byte `endbr64`; your compiler may instead
emit, for example, a one-byte `push`. Set `FIRST_LENGTH` from **your**
disassembly, and verify all those bytes are file-backed in the executable segment.
Pass that length as the third argument to `lesson.lua`:

```sh
# Set FIRST_LENGTH to your observed first-instruction byte length before running.
lua5.4 lesson.lua "$BINARY" "$ADDRESS" "$FIRST_LENGTH"
```

Append this code to the tutorial program:

```lua
local length = assert(math.tointeger(tonumber(arg[3])), 'instruction length required')
assert(length >= 1 and length <= 15, 'x86 instruction length required')
local last = check(address:add(length - 1))
local data, bytes_response = check(session:read_bytes(address, length))
assert(#data == length, 'short byte read')
local hex = {}
for i = 1, #data do hex[i] = string.format('%02x', data:byte(i)) end
print('bytes=' .. table.concat(hex, ' '))

local page = check(session:list_instructions{
    range_start = address, range_end = last, limit = 1, offset = 0,
})
for _, insn in ipairs(page.instructions) do
    print(insn.address:hex(), insn.length, insn.disassembly)
end
```

`data` is a binary string, possibly containing NUL; print its length or hex bytes,
not assumed text. The optional second result from `check` above is the full byte
response. Instruction queries return a full page whose `instructions` array
contains address, length and disassembly records. An empty page is an unavailable
observation, not proof that no code exists.

The end bound is inclusive. `limit=1` counts instructions, not bytes; the byte
read does not constrain decoding. Decode only where a complete instruction and
sufficient mapped bytes are already verified. Assertions after a native read
cannot prevent a crash during that read. For a larger page, independently verify
the complete bytes of every requested instruction first.

## Traverse discovered functions, then edit

After successful decompilation, the entry address joins the function record,
decompilation and signature queries. A function record gives identity and bounds;
the decompilation provides reconstructed text and local observations. Opening
alone does not populate a complete function inventory.

This snippet, also inside the tutorial Session, restricts traversal to the known
entry. Broaden the range only after establishing the other functions you want:

```lua
local pending = {}
for fn in session:iter_functions{
    range_start = address, range_end = address, page_size = 16,
} do
    print(fn.entry_address:hex(), fn.name)
    pending[#pending + 1] = {address = fn.entry_address, name = 'lesson_named'}
end
-- Mutation happens only after traversal has ended.
for _, edit in ipairs(pending) do
    assert(check(session:rename_function(edit.address, edit.name)).renamed)
end
```

The iterator handles paging: a short page alone is not exhaustion. Only functions,
symbols and memory blocks have iterators. Signature pages have a separate
[candidate-filtering rule](API.md#list_function_signatures).

Records and addresses are detached, so collecting them first is safe. Changing
their Lua tables alone does not edit the engine. Native mutations and lifecycle
calls invalidate an active iterator, even through `session:native()` and even
when a dispatched change fails. Replace an invalidated iterator; do not resume it.
Validation failures before dispatch do not invalidate it.

## Rename, save, close and reopen

Run the following as a **separate program**, `save-name.lua`. Supply the same
verified binary and entry, and an absolute state filename in a disposable writable
directory. Start with a filename that does not already exist. The state is separate
from your executable: it is neither a patched binary nor an exported Ghidra project.

```lua
local gh = require('libghidra')
local check = gh.check
local address = check(gh.u64(assert(arg[2])))
local program = {
    program_path = assert(arg[1]),
    language_id = 'x86:LE:64:default', compiler_spec_id = 'gcc',
}
local session <close> = check(gh.open{
    client = {state_path = assert(arg[3])}, program = program,
})
local d = check(session:get_decompilation(address))
assert(d.completed and not d.is_fallback
       and (not d.error_message or d.error_message == ''))
assert(check(session:rename_function(address, 'lesson_saved')).renamed)
print('edited=' .. check(session:get_function(address)).name)
assert(check(session:save_program()).saved)
assert(check(session:close_program{policy = 'discard'}).closed)
-- Logical program closure keeps the owner; reuse it rather than open a second.
check(session:open_program(program))
local restored = check(session:get_function(address))
print('reopened=' .. restored.name)
assert(restored.name == 'lesson_saved')
```

```sh
STATE_DIR=$(mktemp -d "$HOME/lesson-state.XXXXXX")
lua5.4 save-name.lua "$BINARY" "$ADDRESS" "$STATE_DIR/names.xml"
```

The explicit save happens before closing; `policy='discard'` then closes without
another save, not by undoing changes. Expect `edited=lesson_saved` and
`reopened=lesson_saved`. Inspecting the name after
reload demonstrates this particular persisted edit; `saved=true` by itself does
not prove every category survived. The engine reloads configured state best-effort
when opening. Use the same input and state path; this is not a general cross-input
database. At scope exit `close()` releases the owner and permanently closes all
aliases. There is no autosave or rollback; `discard_program` does not undo edits.

Function-name persistence does **not** imply persistence of signatures, locals,
comments, types as a whole or patches. See the
[category-by-category persistence table](API.md#what-survives-saving-and-reloading).
Byte writes are copy-on-write overlays in the engine's view, not modifications to
the source file; save/reopen is not patch export. Read back edits you depend on,
and inspect state after reopening rather than assuming restoration.

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
