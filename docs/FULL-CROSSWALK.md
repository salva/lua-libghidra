# Full native-local operation and field crosswalk

Original wrapper MIT, Copyright 2026 Salvador Fandiño. Local writer evidence,
not independent approval or distribution clearance. This manual supplement
indexes the pinned source ledger without promoting generated runtime slots.

Every included operation below returns the complete native envelope on lowlevel.
Session direct extraction is governed by SPEC/API; full specialists use native()
on the same owner. Request/response fields (including nested types, ignored
inputs and defaults) are exhaustive in api/coverage.json and api/FIELDS.md;
accepted Lua grammar, effective bounds and model mapping are in SPEC, M3-CORE
and M4-FULL, not the historical proposed surface annotations.

| Native operation | Lowlevel | Tier / Session disposition | Positive and negative evidence |
| --- | --- | --- | --- |
| AddPerfBenchmark | `add_perf_benchmark` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| AddTypeEnumMember | `add_type_enum_member` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| AddTypeMember | `add_type_member` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| ApplyDataType | `apply_data_type` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| ClearPerfBenchmarks | `clear_perf_benchmarks` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| CloseProgram | `close_program` | slice; Session (lookup/bytes/decompilation unwrap; pages/outcomes intact) | installed_owner + m2_slice; SPEC first-slice contract |
| CreateType | `create_type` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| CreateTypeAlias | `create_type_alias` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| CreateTypeEnum | `create_type_enum` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| DeleteComment | `delete_comment` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| DeleteDataItem | `delete_data_item` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| DeletePerfBenchmark | `delete_perf_benchmark` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| DeleteSymbol | `delete_symbol` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| DeleteType | `delete_type` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| DeleteTypeAlias | `delete_type_alias` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| DeleteTypeEnumMember | `delete_type_enum_member` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| DeleteTypeMember | `delete_type_member` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| DiscardProgram | `discard_program` | core; native(); no-op acknowledgment, not rollback | m3_core + m3_iterators; M3-CORE grammar/field map |
| GetCapabilities | `get_capabilities` | slice; Session (lookup/bytes/decompilation unwrap; pages/outcomes intact) | installed_owner + m2_slice; SPEC first-slice contract |
| GetComments | `get_comments` | core; Session pages/outcomes or documented optional lookup extraction | m3_core + m3_iterators; M3-CORE grammar/field map |
| GetDecompilation | `get_decompilation` | slice; Session (lookup/bytes/decompilation unwrap; pages/outcomes intact) | installed_owner + m2_slice; SPEC first-slice contract |
| GetFunction | `get_function` | slice; Session (lookup/bytes/decompilation unwrap; pages/outcomes intact) | installed_owner + m2_slice; SPEC first-slice contract |
| GetFunctionSignature | `get_function_signature` | core; Session pages/outcomes or documented optional lookup extraction | m3_core + m3_iterators; M3-CORE grammar/field map |
| GetInstruction | `get_instruction` | slice; Session (lookup/bytes/decompilation unwrap; pages/outcomes intact) | installed_owner + m2_slice; SPEC first-slice contract |
| GetRevision | `get_revision` | core; Session pages/outcomes or documented optional lookup extraction | m3_core + m3_persistence + m4_persistence; category-specific outcomes |
| GetStatus | `get_status` | slice; Session (lookup/bytes/decompilation unwrap; pages/outcomes intact) | installed_owner + m2_slice; SPEC first-slice contract |
| GetSymbol | `get_symbol` | core; Session pages/outcomes or documented optional lookup extraction | m3_core + m3_iterators; M3-CORE grammar/field map |
| GetType | `get_type` | core; Session pages/outcomes or documented optional lookup extraction | m3_core + m3_iterators; M3-CORE grammar/field map |
| ListBasicBlocks | `list_basic_blocks` | core; Session pages/outcomes or documented optional lookup extraction | m3_core + m3_iterators; M3-CORE grammar/field map |
| ListCFGEdges | `list_cfg_edges` | core; Session pages/outcomes or documented optional lookup extraction | m3_core + m3_iterators; M3-CORE grammar/field map |
| ListDataItems | `list_data_items` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| ListDecompilations | `list_decompilations` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| ListDefinedStrings | `list_defined_strings` | core compatibility; native(); constant-empty compatibility, no discovery | m3_core: known-string fixture empty success/unloaded/validation fidelity only |
| ListFunctionSignatures | `list_function_signatures` | core; Session pages/outcomes or documented optional lookup extraction | m3_core + m3_iterators; M3-CORE grammar/field map |
| ListFunctions | `list_functions` | slice; Session (lookup/bytes/decompilation unwrap; pages/outcomes intact) | installed_owner + m2_slice; SPEC first-slice contract |
| ListInstructions | `list_instructions` | slice; Session (lookup/bytes/decompilation unwrap; pages/outcomes intact) | installed_owner + m2_slice; SPEC first-slice contract |
| ListLeafFunctions | `list_leaf_functions` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| ListMemoryBlocks | `list_memory_blocks` | core; Session pages/outcomes or documented optional lookup extraction | m3_core + m3_iterators; M3-CORE grammar/field map |
| ListPerfBenchmarks | `list_perf_benchmarks` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| ListSymbols | `list_symbols` | core; Session pages/outcomes or documented optional lookup extraction | m3_core + m3_iterators; M3-CORE grammar/field map |
| ListTypeAliases | `list_type_aliases` | core; Session pages/outcomes or documented optional lookup extraction | m3_seeded populated native-seeded Lua + m4_services public writer/readback + m3_core unloaded/validation |
| ListTypeEnumMembers | `list_type_enum_members` | core; Session pages/outcomes or documented optional lookup extraction | m3_seeded populated native-seeded Lua + m4_services public writer/readback + m3_core unloaded/validation |
| ListTypeEnums | `list_type_enums` | core; Session pages/outcomes or documented optional lookup extraction | m3_seeded populated native-seeded Lua + m4_services public writer/readback + m3_core unloaded/validation |
| ListTypeMembers | `list_type_members` | core; Session pages/outcomes or documented optional lookup extraction | m3_seeded populated native-seeded Lua + m4_services public writer/readback + m3_core unloaded/validation |
| ListTypeUnions | `list_type_unions` | core; Session pages/outcomes or documented optional lookup extraction | m3_seeded + M3-CORE: loaded empty fidelity; union creation NOT_SUPPORTED, no populated producer |
| ListTypes | `list_types` | core; Session pages/outcomes or documented optional lookup extraction | m3_core + m3_iterators; M3-CORE grammar/field map |
| ListXrefs | `list_xrefs` | core; Session pages/outcomes or documented optional lookup extraction | m3_core + m3_iterators; M3-CORE grammar/field map |
| OpenProgram | `open_program` | slice; Session (lookup/bytes/decompilation unwrap; pages/outcomes intact) | installed_owner + m2_slice; SPEC first-slice contract |
| PatchBytesBatch | `patch_bytes_batch` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| ReadBytes | `read_bytes` | slice; Session (lookup/bytes/decompilation unwrap; pages/outcomes intact) | installed_owner + m2_slice; SPEC first-slice contract |
| RenameDataItem | `rename_data_item` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| RenameFunction | `rename_function` | core; Session pages/outcomes or documented optional lookup extraction | m3_core + m3_iterators; M3-CORE grammar/field map |
| RenameFunctionLocal | `rename_function_local` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| RenameFunctionParameter | `rename_function_parameter` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| RenameSymbol | `rename_symbol` | core; Session pages/outcomes or documented optional lookup extraction | m3_core + m3_iterators; M3-CORE grammar/field map |
| RenameType | `rename_type` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| RenameTypeEnumMember | `rename_type_enum_member` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| RenameTypeMember | `rename_type_member` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| SaveProgram | `save_program` | core; Session pages/outcomes or documented optional lookup extraction | m3_core + m3_persistence + m4_persistence; category-specific outcomes |
| SetComment | `set_comment` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| SetFunctionLocalType | `set_function_local_type` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| SetFunctionParameterType | `set_function_parameter_type` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| SetFunctionSignature | `set_function_signature` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| SetTypeAliasTarget | `set_type_alias_target` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| SetTypeEnumMemberComment | `set_type_enum_member_comment` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| SetTypeEnumMemberValue | `set_type_enum_member_value` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| SetTypeMemberComment | `set_type_member_comment` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| SetTypeMemberType | `set_type_member_type` | full; native() | m4_services + m4_contract; M4-FULL field/dispatch table |
| Shutdown | `shutdown` | full; native() | m4_full_reproducer + m4_contract; shutdown/status/reopen lifecycle |
| WriteBytes | `write_bytes` | core; Session pages/outcomes or documented optional lookup extraction | m3_core + m3_iterators; M3-CORE grammar/field map |

All 40 excluded interface defaults remain excluded, enumerated with reasons in
api/coverage.json and COVERAGE. CreateLocalClient is the separately qualified
factory (installed_owner/installed_profiles), not an IClient service row.

## Cross-cutting field and behavior evidence

- Exact UInt64, binary NUL, false/zero, optionals, enum fallback and error
  conversion: M1-BOUNDARY/M1-OWNERSHIP audit plus boundary hosts, m2_slice,
  m3_core/seeded and m4_contract. FIELDS includes all 160 models/466 direct
  fields, not a claim every model has a populated native producer. Expanded
  request/response paths and direct consumers are checked by Lua tooling.
- Real ELF and analyzed project positives: m2_slice, m3_core and m4_services;
  completed nonfallback arithmetic/known bytes in installed_profiles. Leaves
  require project reference index; raw ELF NOT_SUPPORTED is asserted separately.
- Populated CFG conditional fixture: m3_branch; seeded subtype/signature fields:
  m3_seeded uses test-only native setup (not a public API producer claim).
  Union creation is unsupported; union success-empty remains fidelity only.
- Native decompilation batch includes completed/incomplete results in one call;
  patch batch preserves sequential overlap/counters without atomicity. See
  M4-FULL for source branch citations and absence of a safe mid-patch status
  failure path. m4_contract/services cover ignored sizes, enum width/sign,
  timeout and DeleteSymbol name, supported kind and unsupported alternatives.
- m3_persistence/m4_persistence assert saved/discarded/accepted outcomes separately
  from observed reload categories. Struct shell/new-category loss, byte overlay
  nonpersistence, no autosave and discard no-op remain limitations, not passes
  for durable restoration. See M3-CORE and M4-FULL for exact profiles.
- Only functions/symbols/memory_blocks have qualified iterators. m3_iterators
  exercises generation-before-buffered-yield, bounded progress/stalls and
  publication/finalizer guard. Types/blocks/CFG/xrefs/signatures remain pages-only;
  signature offsets count candidates before filtering, not returned records.
- M2 extreme-address native crash, raw FileBytes route and producer/category
  limits remain documented. Unknown findings are not automatically upstream;
  no engine repair or factory-specpaths detour is authorized.

See INSTALLED-FULL for package-route evidence, applicability and local artifacts.
Generated source slots remain unqualified; tests cited here qualify their actual
branches and fixtures, not arbitrary inputs or every possible native producer.
