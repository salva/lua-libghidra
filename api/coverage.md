# M0 operation/field inventory — structural baseline, semantic review open

`coverage.json` is generated from the actual pinned public headers, LocalClient
overrides and Python AST, not the COVERAGE summary alone. It is **not yet a
completed M0 inventory**, an adapter specification ready for implementation, or
runtime qualification. `unresolved` and per-operation pagination identity/order
slots intentionally expose remaining work. A passing structural check does not
close those gates.

## Reproduce

From the project root, with the locked native input extracted at the default
`.cache/native-inputs/libghidra-d51ca813ae1b6b59519551a9be8c0b1ad74d862d`:

```sh
python3 scripts/inventory-api.py
python3 scripts/inventory-api.py --check
python3 -m unittest discover -s tests -p test_inventory_api.py -v
```

`--source PATH` accepts another extracted source root. No dependency code is
executed, no downloads or native writes occur. Source hashes and declaration/
implementation line references are recorded for independent inspection. This
bounded parser rejects unrecognized local model declarations rather than dropping
fields. It reconciles all service declarations to shared defaults, every local
override to a declaration and every included override to the normative tier table.
HTTP/headless factory option types are excluded from local model extraction;
Python transport/headless/helper operations are separately marked excluded.
StatusOr is described in `error_envelope`, not misrepresented as a model table.

## Current accounting

- 110 native service operations: 70 local overrides, 40 inherited defaults
  excluded from local support. Factory and owner lifecycle are recorded separately.
- 160 local/shared model types, 466 direct fields, with recursively expanded
  request/response field paths; native defaults, optionality and Lua representation.
- 412 Python operation/model rows including the 27 direct LocalClient operations,
  constructor, model annotations and excluded HTTP/async/headless/helper methods.
- Exact source hashes include downstream adapters and decompiler pool; those hashes
  establish provenance, **not** completed branch-by-branch semantic review.

`declaration.arguments` is the native signature. `request.binding_default` is a
proposed binding convention where specified; nested defaults remain native model
defaults. Unspecified arguments are required rather than inventing defaults.
Native integral width is not proof of an effective downstream domain. Only the
documented ReadBytes and compound paging bounds are presently resolved.

## Remaining semantic work (blocks exhaustive acceptance)

Resolve every included operation against the owning downstream adapter, including
identity fields and comparator, actual global order, cursor sequence, filtering,
range normalization and errors propagated by helpers. Replace generic facade
convenience descriptions with exact per-method signatures/extraction and resolve
native enum spellings. Independently reconcile Python bodies and native pybind
conversion/extraction, not only AST signatures. Inspect owner factory/destructor
branches and prove excluded default bodies and HTTP overrides do not expand local
support. Review nested fields for ignored/conditional semantics, not only types.
Add independent source-mutation regression tests: field/operation removal/addition,
ignored-field and cursor drift must be detected rather than merely regenerated.

All positive/negative and Python oracle slots remain **unqualified**. Inventory is
not qualification: native readiness evidence in `docs/NATIVE-READINESS.md` belongs
to its pinned separately authorized engine profile and does not qualify every API
row. No M1 implementation is included. MIT wrapper choice does not resolve the
separate upstream license applicability gate.

Retain defined-string constant-empty fidelity only (no scanner or iterator),
signatures pages-only (candidate offsets; empty output is not exhaustion), ignored
mutation arguments, range-end zero sentinels, signed-int4 ReadBytes bound, logical
program closure versus binding owner release, and mutation/lifecycle generation
invalidation across both public views. Structural tests pin these exceptions.

## Reviewed page paths (second repair attempt)

`inventory_semantics.py` records reviewed contracts for ListFunctions,
ListSymbols, ListTypes, ListTypeAliases, ListTypeUnions, ListInstructions and
ListMemoryBlocks. These now have exact candidate identity field sets, traversal
order, pre/post-page filtering, cursor domain, and source-method/body-hash
citations. Runtime uniqueness and comparator/stability remain unqualified:
source traversal order is not an approved total-order comparator.

Important observed distinctions:

- Type pages use `TypeFactory::dependentOrder`, **not** lexical path order.
  IDs are filtered counters and cannot be used as durable identity.
- Symbol IDs likewise restart after range filtering; use address/name candidates,
  subject to uniqueness tests, rather than assuming IDs survive query changes.
- Memory blocks are zero or one synthetic default-code-space record, not real
  mapped segment enumeration. Full-width highest+1 can wrap the native size.
- Instruction offset counts decoded records after scanning from the original
  start, with `limit+offset` scan bound; no post-page filter. Decoder stops on gap,
  zero length or address wrap.
- These adapters catch/log exceptions and return accumulated records; not every
  backend failure is surfaced as a Status error. Partial/empty success must not
  be confused with complete enumeration.

Python method rows now include body AST hashes, called conversion functions and
return expressions. These support independent conversion review but do not
replace it. Source-mutation tests add a nested model field and alter the
instruction scan bound in disposable copies under the card work root: the former
changes extracted accounting; the latter fails the reviewed contract assertion.
The deterministic baseline comparison still requires review before regeneration
can be accepted. Seven page reviews are progress, not exhaustive completion.

## Enum/member/comment/data review (third repair attempt)

The reviewed-contract layer now covers twelve page paths. Added ListTypeEnums,
ListTypeEnumMembers, ListTypeMembers, GetComments and ListDataItems. Member pages
resolve normalized names, **not** numeric IDs: LocalClient removes one leading
slash, then the adapter uses findByName and a TypeEnum/TypeStruct cast. Missing or
wrong-kind types produce empty success. ListTypeMembers does not enumerate union
members. Ordinals are traversal counters and remain exact UInt64; side-map member
comments are keyed by normalized type name and ordinal. Parent/type ID fields are
not assigned by these adapters; preserve model defaults, not invented identities.
The manifest now annotates these nested field semantics, signed offsets, enum
value casts, member size and optional side-map comments individually.

GetComments traverses an adapter-local std::map keyed by address/kind and filters
before pagination. It does not load analyzed-project comments here. Unlike the
other reviewed adapters, it has no local catch-all; the contract layer now checks
actual catch presence rather than imposing partial-success behavior on every
page. ListDataItems traverses nonfunction mapped symbols; address uniqueness is
not established (no duplicate elimination). Unknown datatype produces undefined
and size zero. These source facts are not positive runtime fixture evidence.

Independent negative drift probes now also change one-leading-slash normalization
and the comment container type; both must fail reviewed assertions. The source
provenance set includes the owning adapter header. Seven tests pass, but remaining
families, exact facade/extraction and Python/pybind semantics still block exhaustive
acceptance. No unresolved slot was relabeled runtime-qualified.

## Aggregate page review (fourth repair attempt)

Eighteen page paths now have reviewed cursor/order contracts. Added leaves,
blocks, edges, xrefs, batch decompilations and signatures. For CFG and xrefs,
range bounds select **function entries**, not returned block/reference addresses.
Serial output is concatenated by function, then graph traversal or call/LOAD/STORE
groups; numeric source-address sorting is not the actual native order. Parallel
CFG/xref append order is completion-dependent, reinforcing pool_size=1. CFG
extraction can create/name a function and run analysis even under read dispatch;
this is recorded as a native side effect, not disguised as binding mutation.

Batch decompilation allocates one result per candidate and writes by index:
completed=false failures are retained. Signature pages instead remove missing
signatures after candidate pagination; no iterator or returned-count cursor is
valid. Leaf filtering occurs before pagination and requires project leaf index;
there is no bare-binary graph fallback. CFG edge kind is a native heuristic
(BACK by block index, then FALSE/TRUE for two outputs, else FALL_THROUGH), not a
new graph-analysis promise. Xrefs are a decompilation-derived subset with possible
duplicate candidate keys and logged partial failures, not all project references.

A new independent source probe removes the signature presence guard and must
fail the reviewed contract instead of accepting regeneration. This progress does
not resolve exact facade signatures, Python/pybind conversions, all nested field
semantics, remaining native mutation/lifecycle helpers, or runtime evidence gates.

## Session/performance branch review (fifth repair attempt)

Nine more operations now have explicit state-transition contracts: save, discard,
revision, close, shutdown and four performance-store operations. Native revision
and binding dispatch generation are separate: discard and close do not increment
native revision, but dispatched binding lifecycle/mutation still invalidates
iterators as specified. Shutdown while unloaded succeeds; CloseProgram while
unloaded errors. Failed save during close precedes adapter reset and preserves
logical access. An empty state_path skips saving in native close, unlike explicit
SaveProgram's NO_STATE_PATH. The facade's stricter save-close policy remains a
binding concern, not a claimed native error.

resetAdapters destroys adapter objects but retains slot-owned decompiler engines.
This is not engine unload or owner release. Discard is true even without a program
and never rolls back. Performance records require a loaded program; empty bench_id
uses lowercase invalid_argument. Upsert removes matches then appends (replacement
moves to tail); delete increments revision only on actual removal; clear increments
even when empty and casts removed count to uint32. ListPerfBenchmarks is a complete
unpaged vector with bench_id identity and insertion/upsert order, not a generic
paged enumeration. Runtime persistence, large-count bounds and real fixtures are
still unqualified.

Independent probes now detect adding engine reset to resetAdapters and changing
conditional delete revision increments. A failed initial generator assertion
incorrectly prohibited all reset calls; source review corrected it to prohibit
engine reset while requiring adapter reset. That failed check was resolved, not
counted as a passing run. Nine tests now pass. Remaining exhaustive conversion,
mutation, field and facade review gates are still explicit.

## Python/nanobind extraction reconciliation (sixth repair attempt)

`inventory_python.py` independently enumerates nanobind exports, separates its
factory, and reconciles the exact 27 public LocalClient methods to native calls.
Each included Python operation now has native response extraction, return
expressions, defaults and source/body provenance. Direct converter assignments
are compared to every native model field and omissions are explicit:

- Python open exports only program_name/language_id/compiler_spec/image_base;
  entry_point, has_entry_point, executable_format, md5 and sha256 are omitted.
  Dataclass defaults are not observed native metadata. Lua must retain all fields.
- Python XrefRecord conversion omits from/to function address/name metadata.
- Close/save/discard become scalar bools; revision a scalar then rebuilt wrapper;
  read_bytes bytes then wrapper; optional lookups use None. get_type is a bare
  TypeRecord/None rather than GetTypeResponse. Lua lowlevel remains full-envelope.
- Python page defaults use limit=0; Lua requires positive bounded pages, default
  100. Python is not a source for Lua defaults or validation domains.
- Python open can mutate request architecture hints using format detection.
  Equivalent-oracle fixtures require identical explicit architecture/compiler.
- Nested decompilation local/token enum conversion uses Python IntEnum and may
  reject unknown values, unlike Lua's numeric unknown-response preservation.
- nanobind unwrap throws ValueError with native code/message; Python catches and
  maps ErrorCode. That mapping is not proof of unknown native-code fidelity.

The parser initially counted module create_local_client as a client method; its
set reconciliation failed. It now explicitly separates and validates the factory
rather than silently dropping the mismatch. A new independent negative drift
probe changes SaveProgram's extracted outcome field; generation must fail.
Ten tests pass. This is source accounting, not Python-oracle execution or full
nested conversion equivalence. Remaining mutation/open/health branches, exact
Lua facade signatures and conditional field/effective-domain review still block
exhaustive acceptance. All positive/negative runtime slots remain unqualified.

## Explicit surface disposition (seventh repair increment)

`inventory_surfaces.py` adds a structured surface_contract per operation. Included
lowlevel calls preserve complete detached responses. Facade lookups explicitly
name function/decompilation/instruction/symbol/type/signature/data extraction and
the third-result/optional-absence convention; mutations/pages preserve envelopes.
Discard and full specialist operations remain native() escape hatches (defined
strings compatibility included), not automatically promoted list conveniences.
Signatures remain pages-only. No iterator is enabled by these inventory rows.

First-slice call grammar, read_bytes size/native-length alias, ignored timeout,
open's rejected facade keys and save-close's pre-dispatch NO_STATE_PATH policy are
now structured. Other positional signatures are inventory proposals and still
require exact facade grammar review before implementation. Native DeleteSymbol
calls the ignored argument name_filter, not name: field-level ignored accounting
now uses that exact declaration key while preserving the documented semantic
name caveat. Nested OpenProgram ignored fields are individually marked. Eleven
focused tests pass; this is not completed exhaustive semantic acceptance.
