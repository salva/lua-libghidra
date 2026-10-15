# Native local coverage baseline

Inventory at the [SPEC pin](SPEC.md): public interfaces in
`cpp/include/libghidra/`, implementations in `cpp/src/local_client.cpp`.
Names below are native C++ operations; low-level names are snake_case.
All listed local overrides belong to the full target; tier marks first delivery.
No row is runtime-qualified. Each needs a positive real supported case, including
analyzed-project inputs where required, plus negative limitation tests. The
constant-empty compatibility row below has an explicit fidelity-only gate.

| Header / subsystem | Tier | Native operations |
| --- | --- | --- |
| health.hpp | Slice | GetStatus, GetCapabilities |
| local.hpp / session.hpp | Slice | CreateLocalClient, OpenProgram, CloseProgram; binding close |
| functions.hpp | Slice | GetFunction, ListFunctions |
| memory.hpp | Slice | ReadBytes |
| listing.hpp | Slice | GetInstruction, ListInstructions |
| decompiler.hpp | Slice | GetDecompilation |
| session.hpp | Core | SaveProgram, DiscardProgram, GetRevision |
| functions.hpp | Core | RenameFunction, ListBasicBlocks, ListCFGEdges |
| symbols.hpp | Core | GetSymbol, ListSymbols, RenameSymbol |
| xrefs.hpp | Core | ListXrefs |
| memory.hpp | Core | ListMemoryBlocks, WriteBytes |
| types.hpp | Core | GetType, ListTypes, ListTypeAliases, ListTypeUnions, ListTypeEnums, ListTypeEnumMembers, ListTypeMembers, GetFunctionSignature, ListFunctionSignatures |
| listing.hpp | Core | GetComments |
| listing.hpp | Core compatibility | ListDefinedStrings (always-empty loaded-program response; no discovery) |
| decompiler.hpp | Full | ListDecompilations (native batch) |
| functions.hpp | Full | ListLeafFunctions (project reference index required) |
| symbols.hpp | Full | DeleteSymbol |
| types.hpp | Full | CreateType, DeleteType, RenameType, CreateTypeAlias, DeleteTypeAlias, SetTypeAliasTarget, CreateTypeEnum |
| types.hpp | Full | AddTypeEnumMember, DeleteTypeEnumMember, RenameTypeEnumMember, SetTypeEnumMemberValue, SetTypeEnumMemberComment |
| types.hpp | Full | AddTypeMember, DeleteTypeMember, RenameTypeMember, SetTypeMemberType, SetTypeMemberComment |
| types.hpp | Full | SetFunctionSignature, RenameFunctionParameter, SetFunctionParameterType, RenameFunctionLocal, SetFunctionLocalType, ApplyDataType |
| listing.hpp | Full | SetComment, DeleteComment, ListDataItems, RenameDataItem, DeleteDataItem (creation via ApplyDataType) |
| memory.hpp | Full | PatchBytesBatch |
| session.hpp | Full | AddPerfBenchmark, ListPerfBenchmarks, ClearPerfBenchmarks, DeletePerfBenchmark, Shutdown (local) |

CreateLocalClient is the factory, not an IClient method. Shared-interface defaults
in api.hpp are not local support. Excluded at this pin: OpenProject, CloseProject,
ListProjectFiles, ImportProgram; program options/transactions; analysis jobs;
Create/Remove/MoveMemoryBlock and SetMemoryBlockAttributes; switch tables,
dominators/postdominators/loops/frames; function tags/mappings; ParseDeclarations;
DeleteTypeEnum; GetPcode; ListInstructionOperands; bookmarks and breakpoints. HTTP implementations
do not expand scope. Project-backed OpenProgram and ListLeafFunctions remain in
scope despite absent local project-management APIs.

## Pinned operation limitations

GetCapabilities preserves upstream coarse subsystem labels verbatim; it is not
proof of per-operation support (including strings, type kinds or enum deletion).
The explicit inventory and qualification evidence govern binding support claims.

- ReadBytes' public uint32 length has a narrower binding domain, 0..INT32_MAX,
  because loadFill receives signed int4. Reject larger lengths before native
  dispatch/allocation on both surfaces, independent of the output byte string.
- Functions, symbols, instructions, comments and data-item range calls use zero
  range_end as UINT64_MAX sentinel, not a literal zero upper bound. Record this
  per method. ListInstructions starts decoding at range_start and stops at the
  first decode gap; it is not mapped-region enumeration and default zero start
  may return empty despite valid code elsewhere.
- CloseProgram/Shutdown logically close native program access; they retain
  engines/architectures. Session and native view share that state, generation
  and owner lifetime. Reopen on the same owner is distinct from binding close,
  which releases the owner and makes all its aliases CLOSED.

- ListFunctionSignatures is pages-only: limit/offset count candidate functions,
  and absent signatures are filtered after pagination. Empty output does not
  establish exhaustion. No signature iterator is promised.
- ListDefinedStrings ignores all range/page fields and always returns empty on
  a loaded program. Test empty-success envelope fidelity on a real fixture with
  known strings, unloaded error and binding validation. No populated/order gate,
  facade iterator, scanner implementation or string-discovery claim.
- DeleteSymbol ignores name; it is not a deletion guard. CreateType ignores size
  and accepts only struct kind. AddTypeMember ignores size and appends using the
  referenced type. CreateTypeEnum ignores width/is_signed. Preserve these fields
  and caveats in the manifest and test their actual behavior/unsupported kinds.
  Do not silently enforce them through replacement implementations.

## Public-layer mapping

Lowlevel covers every included operation with complete responses. Facade offers
open, native, close, get_function, get_decompilation, read_bytes, page calls and
qualified iterators. Core lookups (symbol, type, signature, instruction) unwrap
optional records with SPEC's third-result convention. Core mutation/save/
close_program conveniences preserve flags; discard and full-tier specialist
operations are native() escape-hatch calls unless explicitly approved later as
conveniences. This is intentional facade coverage, not missing native coverage.

Before each adapter lands, `api/coverage.*` expands this inventory to one row per
operation: exact low/high names, every field's native type/Lua representation,
defaults/ignored keys, response extraction, mutation classification, pagination
range sentinels, effective downstream numeric bounds, program-state requirements,
identity/order, cursor domain and post-pagination filtering, supported fixture,
success assertions and negative evidence. Apply SPEC's compatibility exception
for defined strings rather than demanding unattainable discovery evidence.
Reconcile Python's narrower facade independently; it is neither the full native
inventory nor authority for native architecture detection.
