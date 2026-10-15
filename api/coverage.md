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

## Open metadata and creation-width review (eighth repair increment)

OpenProgram assigns only program_name, language_id and compiler_spec. Other
response fields, including image_base, entry/format/hash metadata, retain model
defaults: full-envelope preservation must not turn them into detection claims.
Project path takes precedence and does not forward binary architecture/base/format
hints; binary loading combines explicit language/compiler or uses default_arch.
State load is best-effort; success sets loaded and increments revision. Failed
reopen's downstream resource effects remain unqualified rather than invented.

CreateType supports exactly struct and ignores size; CreateTypeEnum ignores
width/is_signed. AddTypeMember reconstructs existing fields and appends at maximum
native offset+size using signed int casts/addition. This adds an effective existing
layout domain: offsets/sizes and checked sums must fit INT_MAX; a public uint64
request does not establish safety of downstream layout arithmetic. Requested size
remains ignored and is not a replacement implementation opportunity. Source
assertions and twelve focused tests cover these recorded contracts, not runtime
binding enforcement. Remaining mutation/helper/conditional-field review still
prevents exhaustive acceptance.

## Parameter reconstruction and byte-count review (ninth increment)

RenameFunctionParameter/SetFunctionParameterType decompile, extract a signature,
reject absent signature and signed out-of-range ordinals, then rebuild a prototype
for all slots. The reconstruction contains return type/function name/parameter
names/types and varargs, **not calling convention or all signature metadata**.
A successful mutation is not a full-signature preservation guarantee. Parameter
collection count must fit INT_MAX before its native signed-size comparison.

WriteBytes/PatchBytesBatch report input counts, not verified readback; their write
lambdas return true and the wrapper does not check the aggregate result. Normal
empty input still increments revision. Exceptions may leave partial writes.
Batch patches run in input order with no atomicity; uint32 count casts/cumulative
addition require patch count, individual lengths and total <=UINT32_MAX for count
fidelity. Downstream storage/address constraints are explicitly still unqualified.
New independent drift probes remove signed ordinal checking and replace cumulative
count addition; both must fail reviewed assertions. Thirteen tests pass. Remaining
mutation/helper review still prevents exhaustive inventory acceptance.

## Member reconstruction and side-map comments (tenth increment)

Six struct/enum delete/rename/retype/value operations now record normalized-name,
ordinal validation, reconstruction, error and revision branches. Struct rebuilds
retain explicit offsets (deletion does not compact gaps); existing offsets must
fit signed int before FieldDef casts. Enum rebuilds cast signed model values to
uint64 EnumValue and can change traversal ordinals. Neither override remaps
ordinal-keyed side-map comments during reconstruction. Bit-pattern/width and
post-edit layout behavior still require real runtime fixtures.

SetTypeMemberComment and SetTypeEnumMemberComment accept arbitrary normalized
names and ordinals without checking existence/kind/range. They store even empty
text, increment revision and return updated=true on normal return. This is not a
validated successful edit to an existing native member. New independent probes
invert deletion selection and shift a comment-map ordinal; both must fail source
contract assertions. Fourteen tests pass; remaining operations and final
field/grammar/effective-domain audits are still open.

## Local/data/health branch review (eleventh increment)

Seven additional operations distinguish native status-switch errors from generic
booleans. Local rename maps not-found/decompile failure and nominally unreachable
invalid-type to the documented codes; local retype separately preserves
INVALID_TYPE. local_id stays opaque, not an ordinal or user name. ApplyDataType
reuses a symbol name or generates DAT_ plus minimum-eight-digit lowercase hex,
then delegates nameGlobal; no layout or persistence readback is implied. Data
rename/delete reject ineligible/function symbols and increment revision only on
success. Downstream helper behavior remains explicitly unqualified.

Health ok means a pool exists, not a loaded program or complete operation support.
Its literal service_version is not the dependency pin version. Capabilities remain
coarse ordered native text, despite string/full-CRUD overstatements. A new drift
probe substitutes program_loaded for pool existence and must fail the reviewed
contract. Fifteen tests pass. Exhaustive field/helper/final-grammar review remains
open; runtime qualification has not been claimed.

## Alias/symbol/comment error branches (twelfth increment)

Alias retarget checks the new target, destroys the existing typedef, then
recreates it. A caught recreation failure can therefore lose the old alias;
operation error is not rollback. Alias creation passes names unchanged, while
alias deletion/retarget normalize one leading slash on the alias only. Adapter
false conflates absence, ineligible kind and caught exceptions. DeleteType's
core-type error wording is not an explicit core-type guard in its adapter.

RenameSymbol supports functions only (NOT_FOUND absent, NOT_SUPPORTED otherwise,
RENAME_FAILED failed function rename). DeleteSymbol ignores its name and returns
count one only on success; absent is NOT_FOUND, not successful deleted=false.
SetComment stores even empty text in the address/kind side map without address
mapping validation. DeleteComment absent is NOT_FOUND. All preserve native
revision/error branches separately from binding dispatched-mutation generation.
New independent probes invert the rename kind test and erase outcome predicate;
both fail reviewed assertions. Sixteen tests pass; remaining lookup/helper,
conditional-field, numerical-domain and final surface grammar audit remains open.

## Lookup failure fidelity and actionable semantic audit (thirteenth increment)

`inventory_lookups.py` reviews six lookup/read adapter branches plus decompilation,
constant-empty strings and remaining simple function/enum wrappers. Optional
lookups conflate true absence and caught/logged adapter failure into successful
absent optionals. Lua lowlevel must retain that fidelity; facade NOT_FOUND is
synthetic, not a native code for these absent lookups. GetType forwards literal
name unchanged to findByName (no member-style slash normalization). Function,
symbol, instruction and signature record assigned/default-only fields are now
explicitly enumerated by lookup, not inferred from populated model declarations.

GetDecompilation failure is a **present** completed=false record using dl.error,
not a missing optional or nil,error; this wrapper assigns no tokens. ReadBytes
zero request and caught loader/allocation error both yield empty success; resize
precedes signed int4 cast, reinforcing rejection above INT32_MAX before dispatch.
Function/signature analysis side effects remain distinct from revision/generation.
AddTypeEnumMember rebuilds an enumerated enum with signed-to-uint64 append, not
an early missing-parent error. These are source contracts, not runtime fixtures.

New semantic_audit explicitly lists the 18 page wrappers still lacking a separate
state-transition review and 327 response field paths retaining generic
preservation-only semantics. Existing reviewed page source/order contracts are
not erased, but neither generic field text nor a source hash is counted as full
semantic accounting. This is a concrete machine-readable remaining-work ledger,
not a claim that all required semantics are resolved. New independent drift
probes change lookup normalization and decompile failure reason; both are rejected.
Seventeen focused tests pass. Remaining field/helper/domain/final-grammar review
still prevents exhaustive acceptance; runtime evidence slots stay unqualified.

## Page wrapper state/error/conversion review (fourteenth increment)

`inventory_page_wrappers.py` explicitly reviews the 18 previously listed wrapper
transition gaps. It separates wrapper NO_PROGRAM/uncaught-exception policy from
adapter caught-error behavior, and native revision from analysis side effects.
Simple pages enumerate then slice; member pages normalize one slash; instructions
scan limit+offset. Aggregate graph/xref pages slice after concatenation, unlike
candidate-first batch decompilation and signature pages. Signature removal stays
after candidate pagination and cannot supply an exhaustion signal. Leaf index
failure precedes matching/pagination and has no graph fallback. Xrefs must not
pre-decompile before their same-instance analysis/extraction helper.

Comment/data response conversion is one-to-one after pagination. Exact nested
field semantics now include numeric comment kind cast, empty text preservation,
data undefined/zero defaults and inclusive data end arithmetic with unsigned wrap.
The wrapper-transition gap list is now empty, but generic response-field paths
remain in the audit; this does **not** close nested/default/domain/helper or final
facade-grammar requirements. New independent probes alter inclusive data end and
introduce a preceding xref decompile; both must fail. Eighteen tests pass; runtime
positive/negative evidence and iterators remain unqualified.

## Producer-specific function/symbol/instruction/memory fields (fifteenth increment)

`inventory_record_fields.py` compares every declared field against the exact
assigned-field set of six reviewed producers, then annotates eight operation
paths. Default-only fields are explicit, not assumed populated because another
operation returns the same model. Function lookup size is Funcdata size or symbol
footprint; function pages use successor gap (not true body extent). Symbol page
IDs restart after range filtering, while lookup symbol_id remains model zero.
Instruction disassembly joins body conditionally, not with an unconditional space.
Memory blocks are synthetic default-code-space records: write/volatile/comment
remain model defaults; highest+1 can wrap to zero. These assignments/defaults are
not runtime metadata qualification.

Independent probes alter memory size arithmetic and symbol page-ID assignment;
both fail reviewed assertions. Nineteen focused tests pass. The remaining generic
response paths are still listed in semantic_audit; request/default/domain/helper
and final non-first-slice grammar audits remain open. No iterator or runtime
positive/negative qualification is claimed.

## Type-family producer fields (sixteenth increment)

Five more producer/operation contracts account for all TypeRecord, TypeAliasRecord,
TypeEnumRecord and TypeUnionRecord fields. Type lookup ID is literal zero; list
IDs are filtered counters restarting per request. Synthetic slash path_name does
not establish hierarchical path lookup. Category/archive/universal-ID/undefined
metadata remain model defaults. Type length preserves signed native getSize;
enum width and union size convert signed getSize to uint64 (negative values would
convert modulo 2^64), not validated measured layout. Enum is_signed stays false by
initializer, not detected signedness. Alias declaration is constructed without a
semicolon or general declarator-fidelity promise. These default/assignment facts
are source accounting, not runtime qualification.

Independent probes replace type page IDs and alias declaration composition; both
must fail reviewed assertions. Twenty tests pass. Remaining generic field paths,
request/helper/domain review and final grammar remain explicit acceptance gaps.

## Signature and nested parameter producer fields (seventeenth increment)

Signature lookup and signature pages now account every FunctionSignatureRecord
and nested ParameterRecord field against the same extraction producer. The field
reconciler includes vector push_back as population, not just scalar assignments.
Return type falls back to void; parameter datatype falls back to undefined;
formal_data_type copies data_type rather than independent formal extraction.
Auto-parameter/forced-indirect flags remain false initializers, not measured facts.
Ordinal remains zero-based and distinct from dense Lua array position. Calling
convention is a separate getModelName field and is absent from the constructed
prototype, whose declarator fidelity is limited. Requested address is echoed as
function_entry_address after queryFunction succeeds.

Independent probes alter formal-type copying and missing-return fallback; both
must fail reviewed assertions. Twenty-one focused tests pass. Signature paging
still filters missing signatures after candidate pagination, remains pages-only,
and has no runtime qualification. Other model families, request/default/helper/
domain review and final grammar remain open.

## Decompilation branch population and unreachable token schema (eighteenth increment)

`inventory_decompilation_fields.py` separately reconciles successful and failed
single/batch record population, including nested locals and token schema. Failure
returns a present completed=false record and actual dl.error, not optional absence
or stale pool error. Partial adapter pseudocode/locals are discarded on failure.
Single function_name remains empty; batch supplies candidate name even on failure.
Prototype/is_fallback remain initializers. Tokens are never appended on either
branch: nested token initializers are unreachable schema, not observed tokens.

Locals enumerate mapped then dynamic scope entries before RAII analysis cleanup,
dedup by Symbol* and canonical ID, and skip hidden returns. Empty names fall back
to ID; absent datatype is empty (not undefined); nonparameter ordinal is -1. Local
IDs/storage retain native opaque formatting and cast limits, not a cross-generation
identity promise. Persisted local renames are reapplied before print/collection.
Analysis may create a function despite no wrapper revision increment. Missing
architecture, failed perform, empty output and caught exception diagnostics are
recorded explicitly. Native identity boundary behavior stays runtime-unqualified.

Independent probes alter empty-name fallback and batch diagnostic extraction;
both fail reviewed assertions. Twenty-two focused tests pass. Generic response
paths decrease from 187 to 143; graph/xref/performance/direct fields and request/
default/helper/domain/final grammar acceptance remain open. Runtime evidence is
unqualified; no adapters, discovery iterator or M1 implementation added.

## Graph/reference branch field fidelity (nineteenth increment)

`inventory_graph_fields.py` accounts all BasicBlockRecord/CFGEdgeRecord fields and
three XrefRecord construction branches. Block end is getStop (inclusive, no +1),
invalid stop falls back to start; degrees count native inputs/outputs, not emitted
edges after destination filtering. Structured graph traversal is preferred; raw
fallback only runs if structure is empty. Edge labels are priority heuristics
(index back-edge, then output-position boolean, then fall-through).

Call xrefs set primary/flow true and memory stays false; constant LOAD/STORE set
memory true while primary/flow stay false. Source is literal ANALYSIS. Operand
index stays zero, symbol ID -1, external false and all enclosing-function metadata
remain initializers. Constant destination offsets do not resolve address spaces.
This is a decompilation-derived subset, no dedup or completeness promise. Caught
exceptions can return partial vectors. CFG cleanup is explicit, unlike RAII
local extraction; exceptional cleanup is not guaranteed by that body.

Independent probes alter inclusive block end and primary-reference flag; both
must fail reviewed assertions. Twenty-three focused tests pass. Generic response
paths remain audited; performance/direct fields and request/default/helper/domain/
final grammar review remain open. Runtime qualification remains unqualified.

## Performance fields are caller data, not measurements (twentieth increment)

`inventory_performance_fields.py` accounts all ten nested request/list record
fields and five direct response fields. Native add stores the supplied record
verbatim after bench_id upsert; it computes no timing, percentile, throughput,
regression or status. Empty labels/status and unvalidated numeric signs/nonfinite
values are native behavior, not promises about a Lua adapter accepting them.
Native double maps to Lua number, not an unresolved table/enum; lua_Number
precision/binary64 roundtrip remains runtime-unqualified. Zero defaults are not
measured zero latency. Add true includes replacements; clear true includes empty
store; removed_count is pre-clear uint32-cast size; delete false is absent success.
The list remains complete insertion/upsert-order data, not a page or benchmark run.

Independent probes replace record storage and listing copy. The first initially
exposed a ValueError in an older review's unchecked substring index; that primitive
now asserts token presence before ordering, yielding the intended fail-closed
AssertionError. Fresh generation/check and all twenty-four tests pass after this
repair. Generic response paths decrease from 120 to 105; remaining direct/member
fields and request/helper/domain/final grammar review remain open. Runtime slots
remain unqualified; no M1 or native behavior changes.

## Mutation result acknowledgement versus readback (twenty-first increment)

`inventory_mutation_results.py` reconciles direct field assignments for thirteen
mutation operations with success/error return ordering. Native false status is an
error, not a successful false acknowledgement for these paths. Names/types/prototype
and local_id are unchanged request echoes, not canonical post-edit readback; local
resolution can accept aliases even though the response echoes the supplied ID.
SetFunctionSignature.function_name remains empty initializer, not parsed metadata.
DeleteSymbol successful count is exactly one, not a filtered-name match count.
Byte counters are input counts/casts/sums, not observed persisted bytes, and retain
overflow/partial-write limitations. No atomicity or rollback is inferred.

An initial all-response-fields-assigned assertion failed on the unassigned signature
function_name; the producer review now explicitly accounts that default-only field
rather than deleting it from schema or inventing a value. Independent probes alter
local ID echo and delete count; both must fail reviewed assertions. Twenty-five
focused tests pass. Remaining direct/member fields and request/helper/domain/final
grammar audits remain open; runtime evidence unqualified, no M1 implementation.

## Status/session fields are not detected project metadata (twenty-second increment)

`inventory_status_fields.py` explicitly reconciles every response field of revision,
health and save/discard/close/shutdown producers. Revision assigns only the native
counter: program/file identity, path, version and timestamp remain initializers.
Health assigns pool-existence, literal service identity/version/mode and revision;
empty warnings is default-only, not a diagnostic health scan. Native counters are
not binding dispatch generation. Save false is discarded with SAVE_FAILED, not a
successful false response. Discard true is no-op acknowledgement, not undo. Close
true follows adapter reset and logical unload, not engine/owner release. Shutdown
true includes already-unloaded state; helper save errors precede acknowledgement.

Exact producer assignments/default sets and helper save/reset/acknowledgement order
are checked. Initial short helper-name extraction matched an earlier call rather
than definition; the review now names the full helper definition signature. No
upstream behavior was changed. Independent counter-source and shutdown-flag drift
probes are rejected; twenty-six tests pass. Remaining direct/member field and
request/helper/domain/final grammar work remains open; runtime slots unqualified.

## Member producer accounting (twenty-third increment)

Both member producers now reconcile exact assigned/default-only field sets rather
than relying on selected path annotations. Parent/type IDs remain zero defaults;
paths are synthetic slash names; ordinals restart before pagination. Struct offset
is copied into signed int64; signed getSize converts into uint64 size (modulo if
negative). Enum values cast uint64 into int64: out-of-range conversion is
implementation-defined in the native C++ profile, boundary roundtrip unqualified.
Comments come from normalized request-name/current-ordinal side maps, not native
metadata or durable ordinal identity. Reconstruction does not remap comments.

The existing offset regression initially failed because new prose omitted the
signed-int64 model detail; declaration inspection restored that precision and
also prevented misdescribing unsigned member size as signed storage. Two new
independent producer-expression probes reject altered size/value extraction.
Twenty-seven focused tests pass; exhaustive request/helper/domain and remaining
response/grammar work remains open. Runtime evidence remains unqualified.

## Complete type/delete/comment acknowledgement accounting (twenty-fourth increment)

The owning mutation-result reconciler now covers 32 operations, adding nineteen
reviewed type/member/alias/create/delete/comment producers. Exact assignment sets
and error-before-success ordering are checked. For status-driven edits/deletes,
false belongs to an error response, not successful false. Side-map comment setters
are separate: literal true follows unconditional-true dispatch, not type/member
existence validation or native project persistence. Empty strings and same-value
replacement are not suppressed; native revision still increments. Earlier
reconstruction, ignored-field and destructive-retarget limitations remain in force;
acknowledgement does not imply atomicity, rollback or canonical readback.

Fresh generation/check and twenty-eight tests pass, including independent altered
delete/update flag probes. Direct/container response accounting, request/helper/
domain audit and final grammar remain open. Runtime evidence stays unqualified.

## Special results: schema is not observed data (twenty-fifth increment)

Source-bound result review now accounts bytes, coarse capabilities, constant-empty
strings and default-only data value_repr. Capability aggregate initializers have
fixed subsystem IDs/order, nine supported rows and partial xrefs; notes are literal
except pool-size-dependent decompiler text. They are not per-op/runtime evidence.
ReadBytes transfers binary bytes unchanged, including NUL; empty success conflates
zero length and caught failure, with binding pre-dispatch INT32_MAX bound retained.
Defined-string nested fields are unreachable schema, not observed encoding/length/
address defaults. Loaded constant-empty success remains fidelity exception; no
scanner or iterator introduced. DataItem.value_repr remains empty initializer,
not decoded rendering. Independent bytes-extraction and capability-status drift
probes are rejected; twenty-nine tests pass. Container response, request/helper/
domain and final grammar accounting remain open; runtime slots unqualified.

## Container population audit (twenty-sixth increment)

Twenty-four response containers are source-reconciled separately from their nested
record producers. Five lookup optionals copy adapter absence/presence; signature
lookup first invokes decompileAt without checking its result. Single decompilation
is different: loaded success always has a record, including completed=false failure.
Vectors become dense arrays preserving native sequence/duplicates; never key by
address, sort, deduplicate or drop false-valued records. Each vector references its
reviewed wrapper population/filter/cursor pipeline, including candidate-first
signatures and retained batch failures. Empty vector is empty table, not absence.

The preservation-only response-field ledger is now empty (24 -> 0), not a claim of
complete inventory acceptance: request/default/helper/domain audit and final
non-first-slice grammar remain open. Runtime/iterator evidence stays unqualified.
Thirty tests pass, including independent optional-extraction drift rejection.
An older regression requiring nonempty gaps failed when the ledger closed; updated
to require empty response gaps while still requiring explicit unresolved obligations.

## Definition extraction audit (twenty-seventh increment)

All reviewed-contract body consumers now share a fail-closed bounded extractor:
call/declaration occurrences terminated before a block cannot borrow a later
function or conditional body; duplicate candidate definitions and unbalanced
bodies are rejected. Comment, escaped quoted literal and C++ raw-string contents
are masked at identical offsets before brace balancing. Source slices and hashes
still use original bytes. Explicit nanobind lambda prefixes remain supported.
This is not a general C++ parser: constructors/complex declarators and preprocessor
branch evaluation are outside this bounded extractor's qualification. All current
consumer signatures (LocalClient methods, qualified adapters/pool helpers, explicit
helper definitions, converters and lambda prefixes) pass unchanged source artifact
comparison. New synthetic tests reject call-only, duplicate and unbalanced inputs
and verify comments/literals do not truncate a definition. Thirty-one inventory
tests pass. No runtime evidence is inferred; request/domain and grammar audit
remain open despite zero preservation-only response gaps.

## Nested request consumption audit (twenty-eighth increment)

All twenty nested request paths across OpenProgram, AddPerfBenchmark and
PatchBytesBatch now have explicit source-bound consumption/default annotations.
Open routing checks project precedence, binary architecture default/join behavior,
and two never-read fields (facade rejects project_name/read_only). Binary-only
base/format/hints are not project settings. Native model initializers do not prove
Lua input optionality. Performance preserves prior measured-versus-caller field
semantics; batch bytes retain input order/overlap and count-fidelity constraints.
The request_audit explicitly enumerates direct argument review gaps rather than
silently approving them based on type/default presence. This is source inventory,
not runtime/binding-validation qualification. Factory fields remain a separate
review obligation. Thirty-two tests pass including ignored-field consumption drift.

## Direct page argument domains (twenty-ninth increment)

Thirty-six limit/offset paths across eighteen page wrappers now have independent
consumption/default/domain review. The shared paginate helper casts collection
size to int, clamps start with min(offset,n), uses signed start+limit, and maps
native nonpositive limits to all remaining. Lua deliberately rejects nonpositive
page sizes and negative offsets before dispatch, defaults limit=100/offset=0,
and requires each and their sum <=INT_MAX plus supported collections below
INT_MAX. Offset is a zero-based pipeline candidate count, not stable identity;
offset>=n yields empty. Signature post-page filtering still prevents empty
output/count from proving exhaustion. Validation-only rejection does not advance
binding generation. New helper-clamp drift probe is rejected. Thirty-three tests
pass; direct request/factory/final grammar accounting remains incomplete and all
runtime boundary/iterator evidence stays unqualified.

## Range consumption and ignored string pages (thirtieth increment)

Twenty-two range paths now independently reconcile exact UInt64 inclusive bounds,
zero-end normalization at the shared helper, and actual consumer filters. Zero
start is literal; zero end means UINT64_MAX, so end=0 cannot select only address
zero. Reversed normalized ranges yield empty candidates rather than a wrapper
error. Function-based graph/xref/batch/signature pages filter entries, not output
endpoints/extents; data/symbol/comment pages filter record starts. Instruction
sweep begins exactly at the requested start and stops at gaps, not discovery.
Four ListDefinedStrings arguments are explicitly never read: loaded constant-empty
success is the fidelity exception, not a real filter/page/zero-sentinel pipeline;
no discovery iterator. Validation remains separate. All runtime boundary slots
stay unqualified. Direct request ledger: 62 reviewed, 94 remaining; factory and
non-first-slice grammar review still open. Thirty-four focused tests pass,
including independent normalization-sentinel drift rejection.

## Query and ignored direct arguments (thirty-first increment)

Four datatype query paths now source-reconcile empty-filter bypass and exact
case-sensitive byte-substring matching before pages; no regex/glob/path hierarchy
or approved non-slice optionality is inferred. Seven ignored direct fields now
have consumption review: DeleteSymbol name_filter, two decompile timeout_ms
fields, CreateType/AddTypeMember size and CreateTypeEnum width/is_signed.
Ignored does not waive typed/narrow Lua validation or promise advertised effects.
Deletion remains address-only; facade timeout rejection, reconstruction bounds
and enum limitations remain intact. Consumption matching distinguishes m.size
from bare size argument, with a bounded lexical check (not general C++ name
resolution). Independent query and ignored-name consumption probes reject drift.
Direct ledger: 73 reviewed, 83 remaining; runtime slots remain unqualified.

## Byte and type-lookup direct requests (thirty-second increment)

Seven more direct paths reconcile actual dispatch/consumer behavior. ReadBytes
length must be 0..INT32_MAX before dispatch and buffer allocation despite uint32
signature; address zero is literal, default code space is used, loader errors
conflate with empty success. WriteBytes binary/NUL/empty input and UINT32_MAX
count-fidelity cap are explicit, not verified-write or rollback claims. GetType's
service key path is positional LocalClient name, literal findByName without slash
normalization; member lists strip exactly one slash and require struct/enum,
not numeric IDs or unions. Runtime lookup/storage/boundary slots remain
unqualified. Direct ledger: 80 reviewed, 76 remaining. Drift probe removes signed
read cast and fails closed; earlier ordering assertion now checks token presence
before index rather than leaking ValueError. Thirty-six tests pass.

## Factory option consumption (thirty-third increment)

All four LocalClientOptions fields now reconcile exact opts_ reads and native
constructor/pool consumers. Empty ghidra_root selects default Decompiler per
slot; resource availability stays unqualified. Native pool_size clamps <=0 to
one before size_t conversion and accepts >1, unlike mandatory Lua exactly-one
validation. default_arch is binary empty-language fallback, not detected metadata.
state_path empty disables load/close-save but explicit save errors; nonempty
best-effort load ignores return. Factory returns unique_ptr, not StatusOr;
construction exceptions can escape and default destruction is not autosave.
Single-owner reservation/recovery, serialized destruction and resource-path
positive/negative slots remain unqualified. Exact option set and pool clamp drift
are checked; thirty-seven focused tests pass. Direct request ledger remains
80 reviewed/76 remaining; final grammar and remaining argument review open.

## Member keys and ordinal domains (thirty-fourth increment)

Eighteen direct paths now reconcile normalized struct/enum parent keys and
zero-based UInt64 traversal ordinals across six reconstruction and two comment
operations, plus two signed-int parameter ordinals. Struct/enum edits reject
out-of-range with NOT_FOUND; comment setters accept arbitrary ordinal/name
side-map keys without existence/kind checks. Parameter ordinals are signed int,
negative or >= count gives OUT_OF_RANGE after signature extraction (missing
signature first NOT_FOUND), with count <=INT_MAX. No Lua 1-based conversion,
durable identity, side-map remapping or runtime roundtrip is inferred. Dispatch
generation versus validation-only rejection remains explicit. Direct ledger is
98 reviewed/58 remaining; 38 tests include source-drift checks. Final grammar
and remaining argument reviews are still open; runtime slots unqualified.

## Mutation payload fields (thirty-fifth increment)

Eight more direct paths reconcile selected member/enum names/types/values,
parameter names/types, and two member comment payloads. Strings are forwarded
without wrapper identifier/type validation or escaping: parameter payloads become
prototype syntax, not opaque edits or canonical readback. Enum value is signed
int64 before modulo-2^64 uint64 reconstruction; runtime signed roundtrip remains
unqualified. Comment empty text is stored replacement, not deletion. Whole-type
reconstruction, side-map provenance, metadata loss and dispatch generation
limitations remain. Ledger: 106 reviewed/50 remaining. Thirty-nine tests include
independent selected enum-value drift rejection; runtime qualification and final
non-first-slice grammar remain open.

## Type/alias request identities (thirty-sixth increment)

Eight direct paths reconcile creation versus normalized lookup: alias creation
forwards both strings literally, delete/retarget normalize only the alias by one
slash, and target lookup remains literal. Service name/target_type/type_id_or_path
keys bind positionally to different LocalClient parameter names. RenameType
normalizes old name only, delegates new-name validation to TypeFactory. DeleteType
core-type error wording is not an explicit adapter guard. Retarget resolves the
new target before destroying old typedef, then recreation may fail without
rollback. Native revision, binding dispatch generation and validation-only failure
remain distinct. Ledger: 114 reviewed/42 remaining; 40 tests include independent
new-target-consumption drift rejection. No runtime qualification or M1 changes.

## Creation/addition request accounting (thirty-seventh increment)

Nine more direct fields distinguish exact struct kind, literal empty-collection
creation names, one-slash parent normalization and verbatim appended payloads.
Add member wrappers do not explicitly reject absent/wrong-kind parents after
empty lookup: do not invent an existing-parent guard. Structure append uses
max(0, existing offset+size), not an alignment algorithm; signed reconstruction
bounds remain independent of ignored requested size. Enum signed values convert
modulo 2^64, not saturation; reconstruction can change traversal ordinals without
comment remapping. All downstream parser/layout/identifier and runtime evidence
remains unqualified. Ledger: 123 reviewed/33 remaining. Independent append-offset
substitution probe and 41 tests retain the original absence reproducer.
