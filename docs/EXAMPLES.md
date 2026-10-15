# Proposed Lua usage

These are acceptance examples, not runnable bindings today. M2 executes the
first example using a generated `fixture_manifest` Lua table from M0's authored
fixture (paths, explicit architecture/compiler, known function address and a
known absent address). That table is test data, not another SDK API. M3 executes
the mutation extension on a disposable copy. See [SPEC](SPEC.md) for signatures.

## First slice: open metadata, reads, pages, iteration and aliases

```lua
local ghidra = require("libghidra")
local lowlevel = require("libghidra.lowlevel")
local fixture = require("fixture_manifest")
local check = ghidra.check -- also exported by lowlevel
local address = check(ghidra.u64(fixture.function_address))
local alias, metadata
do
  local session <close>, opened = check(ghidra.open{
    client = {ghidra_root = fixture.spec_root, pool_size = 1},
    program = {
      program_path = fixture.binary_path,
      language_id = fixture.language_id, -- e.g. x86:LE:64:default
      compiler_spec_id = fixture.compiler_spec_id, -- e.g. gcc
    },
  })
  metadata = opened -- detached response from this open; no repeat call
  print(opened.program_name, opened.has_entry_point, opened.entry_point:hex())
  -- has_entry_point controls meaning; zero alone does not mean absent.
  alias = session:native() -- same owner, not a second local_client

  local fn, err, response = session:get_function(address)
  assert(fn ~= nil, err and err.message)
  assert(fn == response["function"])
  local missing, missing_err, missing_response = session:get_function(
    check(ghidra.u64(fixture.absent_function_address)))
  assert(missing == nil and missing_err.code == "NOT_FOUND")
  assert(missing_response["function"] == nil) -- native unsupported is different

  local bytes, bytes_err, bytes_response = session:read_bytes(address, 16)
  check(bytes, bytes_err)
  assert(bytes == bytes_response.data) -- binary string, including any NULs
  print(#bytes, bytes:byte(1))
  local page = check(session:list_functions{limit = 2, offset = 0})
  for _, record in ipairs(page.functions) do print(record.name) end
  local instructions = check(session:list_instructions{
    range_start = address, range_end = 0, limit = 2,
  }) -- zero end means UINT64_MAX; decoding starts exactly at address
  -- Stops at the first decode gap; empty does not imply no code elsewhere.
  local ok, iteration_err = pcall(function()
    for record in session:iter_functions{page_size = 2} do
      print(record.entry_address:hex(), record.name)
    end
  end)
  if not ok then error(iteration_err) end -- structured error retained

  local dec, _, envelope = session:get_decompilation(address)
  assert(dec ~= nil and envelope.decompilation == dec)
  -- Qualification checks completed/nonfallback semantics; presence isn't enough.
  check(alias:close_program{policy = "discard"}) -- logical close, engines retained
  local no_function, no_program = session:get_function(address)
  assert(no_function == nil and no_program.code == "NO_PROGRAM")
  check(alias:get_status()) -- owner still live; not CLOSED
  local reopened = check(alias:open_program{
    program_path = fixture.binary_path,
    language_id = fixture.language_id,
    compiler_spec_id = fixture.compiler_spec_id,
  })
  check(session:get_function(address)) -- same Session now sees reopened context
  -- opened/metadata still describe the earlier open, not reopened.
  check(session:close_program{policy = "discard"})
end -- __close resets shared owner
local status, closed = alias:get_status()
assert(status == nil and closed.code == "CLOSED")
print(metadata.program_name) -- detached metadata survives closure
```

Low-level-only construction uses
`local client <close> = lowlevel.check(lowlevel.local_client{ghidra_root=...})`,
then `client:open_program{program_path=..., language_id=..., compiler_spec_id=...}`.
It receives the complete open response directly. Do not construct that client
while the example Session is live: initial scope permits one native owner.

## M3 extension: native mutation outcome and iterator invalidation

Inside an open Session scope on a disposable fixture, with `address` constructed
as above (`rename_function(address, name)` is a core low-level method):

```lua
local iterator = session:iter_functions{page_size = 2}
local first = iterator()
assert(first ~= nil)
local response = ghidra.check(session:native():rename_function(
  address, "fixture_renamed"))
assert(response.renamed == true) -- check(response) alone doesn't test this flag
local ok, err = pcall(iterator)
assert(not ok and err.code == "ITERATOR_INVALIDATED") -- even if page buffered
```

The outcome is preserved; failed dispatched mutations also invalidate iterators.
Native batches are not replaced by repeated convenience calls. The original open
metadata describes its initial open even after mutations or native close/reopen.
