# Native local coverage baseline

Inventory at the [SPEC pin](SPEC.md): public interfaces in
`cpp/include/libghidra/`, implementations in `cpp/src/local_client.cpp`.
Names below are native C++ operations; low-level names are snake_case.
All listed local overrides belong to the full target; tier marks first delivery.
No row is runtime-qualified. Each needs a positive real supported case, including
analyzed-project inputs where required, plus negative limitation tests.

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
| listing.hpp | Core | GetComments, ListDefinedStrings |
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
identity/order, supported fixture, success assertions and negative evidence.
Reconcile Python's narrower facade independently; it is neither the full native
inventory nor authority for native architecture detection.
