# Native local coverage accounting

[API](../API.md) is the sole current call/return/limitations authority.
`api/coverage.json` is generated from pinned C++ sources and this operation
classification. It accounts for **70 included / 40 excluded** service operations.
Slice/Core/Full labels below are stable generator categories, not progress or
runtime qualification claims. Lowlevel implements all included operations;
Session availability is defined by the actual facade and API, not these labels.

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


CreateLocalClient is a separate factory, not an IClient service operation.
Excluded inherited NOT_SUPPORTED stubs include project management, transactions,
analysis jobs, memory-block editing, switch/loop/frame queries, tags/mappings,
ParseDeclarations, DeleteTypeEnum, GetPcode, instruction operands, bookmarks and
breakpoints. Project-backed OpenProgram and ListLeafFunctions remain included.

## Source facts versus runtime evidence

The ledger records native type/default/field consumers/producers and recursive
reachability. Generated runtime slots remain **unqualified**. Source reachability
proves conversion availability, not populated output, stable iteration,
persistence, optional Lua positional arguments or semantic correctness.
DecompileTokenRecord is reachable although its native producer does not fill it.
Native-only schemas remain in the generated appendix without Lua support claims.
GetCapabilities preserves coarse upstream labels, not per-operation support.

[api tooling](../../api/README.md) owns regeneration instructions. Tests verify
header/override accounting, expanded fields, reviewed source bodies, actual
converter spellings, rejection sensitivity and no manufactured runtime evidence.
Historical test-consumed JSON remains source-only and is never generation input.

## Effective supported-profile limits

The portability aim is most UNIX/Linux systems and modern Lua; current tooling
is Linux-oriented and requires the Lua 5.4 ABI. The tested host is Ubuntu 24.04
x86-64 with Lua 5.4.6. Host portability is distinct from input architecture.
The qualified input route is x86-64 ELF with explicit architecture hints
and the locked BFD/Sleigh target profile. Raw/reconstructed FileBytes loading is
not supported by that profile. Do not generalize to all architectures or loaders.
Only function/symbol/memory-block iterators are exposed. Structural CFG/xref and
signature families remain pages-only. Signature candidate filtering prevents
empty-page exhaustion inference. Defined strings always return empty success on
a loaded program: this is envelope fidelity, not string discovery.

ReadBytes rejects above INT32_MAX before dispatch/allocation. Native address use
can crash; exact UInt64 is not mapping validation. Native close is logical access
closure retaining engines. `read_only`, `project_name` and decompilation deadlines
are ignored upstream; Session rejects misleading extra options. DeleteSymbol name,
CreateType/AddTypeMember size and CreateTypeEnum width/is_signed are ignored.
Only struct creation is supported. True-local char retyping is unqualified; do not
promote parameter-only int signature evidence into true-local support.

Save/reopen is category-specific, not rollback or patch persistence. Among newer
categories only a struct shell survived the exercised reload; true-local rename
reset and enum/member/alias/signature/data/byte/performance persistence is not
promised. GetRevision representation does not establish a populated durable
producer. Complete/nonfallback semantic Lua tests and detached lifetime checks
are separate runtime evidence, not generated green slots. Dependency-internal OOM
recovery is not guaranteed. See [API limits](../API.md) for actionable details.
