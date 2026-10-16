# Decompile your own function

You will write a small C program, compile it, locate a function in the resulting
binary, and ask Lua to reconstruct that function. Start with the
[installation guide](INSTALL.md); keep its Lua executable and module search paths.
This worked route uses an ordinary non-PIE **x86-64 Linux ELF** input. It is an
exercised input format, not a claim that the host's CPU defines all possible
input architectures or that other UNIX hosts have been validated.

## What the library does

Ghidra supplies a machine-code decompiler. libghidra exposes that engine through
a native API, and lua-libghidra makes the API available in your existing Lua VM.
Neither the Ghidra desktop application nor Java is needed at runtime.

A **Session** owns access to one native client. That client owns the engine; the
**program** is the input currently opened in it. Opening is lazy: it does not
analyze the whole executable. Decompiling a known function discovers information
that later queries can inspect. Returned records are ordinary detached Lua data,
not live views of the program.

## 1. Write and compile a small program

In a new working directory, save this as `lesson.c`:

```c
int lesson_adjust(int value) {
    return value * 3 + 7;
}

int main(void) {
    return lesson_adjust(5) == 22 ? 0 : 1;
}
```

Compile using GCC targeting x86-64 Linux:

```sh
gcc -O0 -fno-pie -no-pie -o lesson.elf lesson.c
BINARY="$(pwd -P)/lesson.elf"
```

`-O0` keeps this lesson easy to recognize; `-fno-pie -no-pie` selects an ordinary
executable rather than a position-independent one. Do not strip it: its symbol
table lets us locate `lesson_adjust` without guessing. Debug information is not
required. The library reads machine code, not `lesson.c`.

## 2. Establish the entry address and mapped bytes

Use the binary tools before calling the native engine:

```sh
readelf -hW "$BINARY"
readelf -sW "$BINARY" | grep ' lesson_adjust$'
nm -n --defined-only "$BINARY" | grep ' lesson_adjust$'
readelf -lW "$BINARY"
objdump -d --disassemble=lesson_adjust "$BINARY"
```

Check these facts together:

1. The ELF header says `ELF64`, little endian, `EXEC` and x86-64. If not, stop
   and select specifications for the actual input; the following IDs are not
   suitable for arbitrary binaries.
2. The symbol is a defined `FUNC`, not `UND` or a data symbol. `nm` should mark
   it `T` (text). The symbol's value is its **virtual entry address**.
3. An executable `LOAD` segment (`R E`) contains the complete function bytes.
   Its virtual interval starts at `VirtAddr`; `FileSiz` bytes are backed by the
   file. For these bytes, file offset = `Offset + (address - VirtAddr)`.
   `MemSiz` may include additional zero-filled memory; do not confuse it with
   bytes actually present in the file.
4. Disassembly begins at the same symbol value. Check its complete instructions
   and final byte against that segment, not only its first address.

**Illustrative output only — your addresses and instruction lengths can differ:**

```text
0000000000401106 T lesson_adjust
LOAD  0x001000 0x0000000000401000 ... 0x000149 0x000149 R E ...
0000000000401106 <lesson_adjust>:
  401106: f3 0f 1e fa           endbr64
  40110a: 55                    push %rbp
  ...
```

Here the entry would be in the file-backed executable segment, at file offset
`0x1106`, **not** at file offset `0x401106`. Never copy these illustrative numbers
into a call. Once your own output agrees, derive your actual entry:

```sh
ADDRESS="0x$(nm -n --defined-only "$BINARY" | awk '$2 == "T" && $3 == "lesson_adjust" {print $1}')"
printf '%s\n' "$ADDRESS"
```

Prefix hexadecimal text with `0x`: otherwise all-digit text is parsed as decimal.
For stripped inputs this symbol procedure may be unavailable. For PIE or rebased
inputs, a process's runtime address is not automatically the loader's address.
Do not guess a relocation rule or substitute a file offset; establish the actual
loader mapping before adapting this lesson.

## 3. Choose the processor and compiler conventions

For this input, use `x86:LE:64:default` and `gcc`:

- `x86` selects the processor family, `LE` little endian, `64` the bit width,
  and `default` the language variant.
- `gcc` selects calling conventions and data organization. It is a compiler
  specification ID, not an instruction to launch GCC during decompilation.

In the matching specification tree, language definitions live under
`Ghidra/Processors/*/data/languages/*.ldefs`. In `x86.ldefs`, the language with
ID `x86:LE:64:default` contains a compiler with ID `gcc` referring to
`x86-64-gcc.cspec`. Use IDs from the specs paired with your installed engine;
the binding has no language-enumeration API. Embedded specs supply these by
default. An external `client.ghidra_root` points to a root containing
`Ghidra/Processors`; it does not launch the Ghidra application.

For an ordinary ELF, pass `program_path` and leave `format`, `base_address` and
`default_arch` at their defaults. The engine detects the loader from the file;
`format` is not a general loader override (its `raw` value affects raw-loader PE
preparation). `base_address` rebases raw loading, not structured ELF VMAs.
`default_arch` is used when `language_id` is empty; explicit
language/compiler IDs avoid that ambiguity here. `project_path` selects loading
an analyzed project instead of an ordinary binary, and has different input
limitations. It is **not** the `state_path` used for saving binding edits.
The open response echoes requested/default IDs; it is not confirmation that the
engine detected the correct processor. That is why the header/spec checks matter.

## 4. Call the library from Lua

Immediately before this first native call: use only the mapped function you
verified. Exact UInt64 parsing does not validate mapping. Unmapped/extreme
addresses can crash the process, outside Lua error handling. Run native work in
a separate process and isolate untrusted inputs appropriately. Calls are
synchronous; the engine's protection/deadline fields do not contain crashes or
cancel a call. Dependency-internal out-of-memory recovery is not guaranteed.

Save this complete small program as `lesson.lua`:

```lua
local gh = require('libghidra')
local check = gh.check
local address = check(gh.u64(assert(arg[2], 'verified entry required')))
local session <close> = check(gh.open{
    program = {
        program_path = assert(arg[1], 'binary path required'),
        language_id = 'x86:LE:64:default',
        compiler_spec_id = 'gcc',
    },
})

local result, err = session:get_decompilation(address)
if not result then
    io.stderr:write(err.code, ': ', err.message, '\n')
    error('decompilation unavailable or failed')
end
print('entry=' .. address:hex())
print('completed=' .. tostring(result.completed))
print('is_fallback=' .. tostring(result.is_fallback))
if result.error_message and result.error_message ~= '' then
    io.stderr:write(result.error_message, '\n')
end
if result.pseudocode then print(result.pseudocode) end
assert(result.completed and not result.is_fallback
       and (not result.error_message or result.error_message == ''),
       'output is not a complete successful decompilation')
```

Run in its own process, using the installed module paths:

```sh
lua5.4 lesson.lua "$BINARY" "$ADDRESS"
```

`require` loads the binding. `open` creates the owner and opens the input.
`<close>` releases the owner when the scope ends, including on a raised Lua error.
Only one owner may be live per process, even across Lua states. Use
`session:native()` for additional methods on the same owner rather than creating
a second one. Closing the owner closes all its aliases; merely closing a program
allows the existing owner to be reused. Cleanup cannot recover from a native crash.

## 5. Interpret reconstructed output

Expect an exact hexadecimal entry, `completed=true`, `is_fallback=false` and
C-like pseudocode. An **illustrative** body might be:

```c
int FUN_00401106(int param_1) {
    return param_1 * 3 + 7;
}
```

The expression should describe the calculation you authored. Generated function
and parameter names, casts, formatting and algebraic form may differ. This is
**reconstruction**, not recovery of the original source, original names or a
proof of correctness. Optimizations and missing type information can change the
result substantially for larger programs. The engine may spell a four-byte
integer `int4` rather than `int`; the output's types reflect its inferred model.

A record's presence is not success: it may contain incomplete or fallback text.
`check` only raises when its first argument is nil; it does not examine completion
flags. That is why this program handles absence explicitly and checks all three
success conditions after showing the available output.

## Run the supplied task and continue

The downloadable [decompile.lua](../examples/decompile.lua) adds CLI validation
and consistent result/exit reporting around the same task. Run this command from
the checkout root, or use the script's absolute path if you are still in the
tutorial working directory. If you installed with a custom Lua executable, use
that executable in place of `lua5.4`:

```sh
lua5.4 examples/decompile.lua "$BINARY" "$ADDRESS" x86:LE:64:default gcc
```

In an installation, use `share/libghidra/examples/decompile.lua` under the package
data prefix; see [installed paths](INSTALL.md#installed-paths-and-use).
Append an external specification root if needed. Embedded first use needs writable
`$HOME/.ghidracpp/cache/sleigh`.

The script reports `complete`, `incomplete`, `fallback`, `unavailable` or `error`;
it exits 0 only for complete nonfallback output without an engine error, 1 for an
unsuccessful result, and 2 for invalid CLI arguments. The
[example reference](EXAMPLES.md) gives the full contract and the next tasks:
read bytes/instructions, traverse discovered functions, then rename, explicitly
save and reopen. Consult [API](API.md), [result fields](../api/FIELDS.md) and
[notices](NOTICES.md) as you extend the program or distribute linked artifacts.
