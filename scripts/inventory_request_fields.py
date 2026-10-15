"""Reviewed nested request consumption and explicit remaining request ledger."""
import re
from inventory_semantics import LOCAL, ADAPTER, body, _code_mask


def review_request_fields(u, operations):
    source=(u/LOCAL).read_text()
    open_semantics={
        'project_path':'nonempty selects loadProject BEFORE binary branch; program_path forwarded too; empty selects binary route if program_path nonempty, else INVALID_ARGUMENT',
        'program_path':'project program selector when project_path nonempty; otherwise nonempty binary filename required; not expanded/canonicalized by wrapper; also response program_name preference',
        'project_name':'ignored native request field: never read; facade rejects presence rather than silently dropping it',
        'read_only':'ignored native request field: never read; false is not absence; facade rejects presence rather than promising read-only behavior',
        'language_id':'binary only: empty selects opts.default_arch (compiler_spec_id then not appended); nonempty plus nonempty compiler_spec_id joins with colon, otherwise used unchanged; project route ignores architecture hints; response echo is not detected metadata',
        'compiler_spec_id':'binary only appended to nonempty language_id using colon when nonempty; ignored for architecture if language_id empty and on project route; response echoes field regardless',
        'format':'binary only forwarded unchanged to loadBinary; project route ignores; empty native string preserved, not an independently detected format',
        'base_address':'binary only exact uint64 forwarded to loadBinary; project route ignores; zero preserved, no zero-end range sentinel semantics',
    }
    expected={'OpenProgram':set(open_semantics),'AddPerfBenchmark':{'bench_id','query_family','dataset_profile','cold_ms_p50','cold_ms_p95','warm_ms_p50','warm_ms_p95','throughput_qps','regression_pct','status'},'PatchBytesBatch':{'address','data'}}
    _,paginate=body(source,'Container paginate(const Container& all, int limit, int offset)')
    assert 'int n = static_cast<int>(all.size())' in paginate
    assert 'int start = std::min(offset, n)' in paginate
    assert 'int end = (limit > 0) ? std::min(start + limit, n) : n' in paginate
    assert 'Container(all.begin() + start, all.begin() + end)' in paginate
    adapter=(u/ADAPTER).read_text()
    _,normalize=body(adapter,'std::uint64_t normalize_range_end(')
    assert 'return range_end == 0 ? kAllRangeEnd : range_end;' in normalize
    assert 'constexpr std::uint64_t kAllRangeEnd = UINT64_MAX;' in adapter
    range_consumers={
        'ListFunctions':'listFunctions','ListSymbols':'listSymbols',
        'GetComments':'getComments','ListDataItems':'listDataItems',
        'ListInstructions':'listInstructions',
        **{n:'listFunctions' for n in ['ListLeafFunctions','ListDecompilations','ListFunctionSignatures','ListXrefs','ListCFGEdges','ListBasicBlocks']},
    }
    for consumer in set(range_consumers.values()):
        _,producer=body(adapter,'ArchAdapter::'+consumer+'(')
        assert 'range_end = normalize_range_end(range_end)' in producer
        if consumer=='listInstructions':
            assert 'if (range_start > range_end) return result;' in producer
            assert 'cur <= range_end' in producer and 'cur = range_start' in producer
        else:
            address='fns[i].addr' if consumer=='listFunctions' else 'addr'
            assert address+' < range_start || '+address+' > range_end' in producer
    ledger=[]
    reviewed=[]
    for op in operations:
        if not op['implementation']:continue
        name=op['name']
        _,text=body(source,' '+name+'(')
        code=_code_mask(text)
        for arg in op['request']:
            nested=arg['nested_fields']
            if not nested and name in {'CloseProgram','Shutdown'} and arg['name']=='policy':
                assert arg['native_type']=='ShutdownPolicy' and 'closeProgramLocked(policy)' in code
                _,helper=body(source,'StatusOr<CloseProgramResponse> closeProgramLocked(ShutdownPolicy policy)')
                assert 'policy == ShutdownPolicy::kSave' in helper
                assert 'should_save && !opts_.state_path.empty()' in helper
                assert 'pool_->saveState(opts_.state_path)' in helper and 'pool_->resetAdapters();' in helper
                assert helper.index('pool_->saveState(opts_.state_path)')<helper.index('pool_->resetAdapters();')
                sem='required explicit Lua policy, no implicit save; facade close_program accepts save/discard only. Native enum kUnspecified=0, kSave=1, kDiscard=2, kNone=3: ONLY kSave requests save, other native values take non-save branch (not an approved Lua unknown-enum input policy); empty state_path skips native save, facade save-close rejects pre-dispatch; SAVE_FAILED precedes unload/reset, retains logical access; successful close resets adapters/benchmarks, not engines/owner, no autosave or revision increment'
                if name=='Shutdown':
                    assert 'if (program_loaded_)' in code
                    sem+='; local Shutdown already unloaded succeeds accepted=true without policy processing; loaded uses same non-locking close helper and propagates its status, NOT remote host termination'
                else:
                    sem+='; CloseProgram unloaded returns NO_PROGRAM before policy branch'
                arg['semantics']=sem+'; dispatched lifecycle invalidates binding generation even on error, validation-only rejection does not; aliases NO_PROGRAM after logical close, owner still usable for status/reopen; runtime fixture/alias/save-failure evidence unqualified'
                arg['direct_argument_review']={'consumer':LOCAL,'helper':'closeProgramLocked','qualification':'source only; runtime unqualified'}
                reviewed.append({'operation':name,'path':arg['name']})
                continue
            if not nested and name in {'SetComment','DeleteComment'} and arg['name'] in {'kind','text'}:
                consumer='setComment' if name=='SetComment' else 'deleteComment'
                _,producer=body(adapter,'ArchAdapter::'+consumer+'(')
                assert 'static_cast<int>(kind)' in code
                if name=='SetComment':
                    assert 'a.setComment(address, static_cast<int>(kind), text)' in code
                    assert 'comments_[{address, kind}] = text;' in producer
                else:
                    assert 'a.deleteComment(address, static_cast<int>(kind))' in code
                    assert 'comments_.erase({address, kind}) > 0' in producer
                if arg['name']=='kind':
                    assert arg['native_type']=='CommentKind'
                    sem='required Lua enum representation; native CommentKind unspecified=0/eol=1/pre=2/post=3/plate=4/repeatable=5, cast to signed int map key without native membership validation; unknown-numeric preservation in responses does not approve accepting arbitrary enum inputs; no implicit eol default'
                else:
                    assert arg['native_type']=='const std::string&'
                    sem='required Lua string copied unchanged to adapter-local address/kind map; empty string is stored replacement, NOT deletion/absence; no text content validation, not native project comment metadata'
                sem+=('; setter no address/kind/existence check, ignored aggregate status and unconditional true/revision even same value' if name=='SetComment' else '; deletion erases exact address/kind key, absent returns NOT_FOUND not deleted=false success; revision only on deletion')
                arg['semantics']=sem+'; side-map persistence/NUL/non-ASCII roundtrip unqualified; dispatched mutation invalidates generation even failed call, validation-only rejection does not; runtime positive/negative evidence unqualified'
                arg['direct_argument_review']={'consumer':ADAPTER,'helper':consumer,'qualification':'source only; runtime unqualified'}
                reviewed.append({'operation':name,'path':arg['name']})
                continue
            if not nested and name=='DeletePerfBenchmark' and arg['name']=='bench_id':
                assert arg['native_type']=='const std::string&'
                assert 'bench_id.empty()' in code and 'r.bench_id == bench_id' in code
                assert '"invalid_argument"' in text and 'if (deleted) revision_++;' in code
                arg['semantics']='required Lua string; loaded guard first, empty gives lowercase invalid_argument; exact case-sensitive byte-string equality removes all matching in-memory benchmark IDs, no normalization/substring matching; absent nonempty ID returns successful deleted=false without revision increment; binding dispatched mutation generation still invalidates, validation-only rejection does not; native store lifetime is loaded program, not persistent measurement DB; NUL/non-ASCII and positive/negative runtime evidence unqualified'
                arg['direct_argument_review']={'consumer':LOCAL,'helper':name,'qualification':'source only; runtime unqualified'}
                reviewed.append({'operation':name,'path':arg['name']})
                continue
            text_payloads={
                'RenameFunction':{'new_name':('d.nameFunction(address, new_name)','literal function name passed unchanged to nameFunction; no wrapper empty/identifier/duplicate validation')},
                'RenameSymbol':{'new_name':('d.nameFunction(address, new_name)','literal function name; missing symbol first NOT_FOUND, non-function NOT_SUPPORTED, only function branch calls nameFunction; no wrapper name validation')},
                'RenameDataItem':{'new_name':('a.renameDataItem(address, new_name)','literal new data symbol name; adapter rejects empty, missing entry/symbol and function symbols, sets namelock on successful rename; caught failures conflate into RENAME_FAILED')},
                'ApplyDataType':{'data_type':('d.nameGlobal(address, name, data_type)','literal type string forwarded to nameGlobal, not numeric type ID/path normalization; existing nonempty symbol name reused else DAT_ minimum-eight lowercase hex generated; wrapper does not parse/validate type')},
                'SetFunctionSignature':{'prototype':('d.setPrototype(address, prototype)','complete prototype syntax forwarded unchanged to setPrototype, no wrapper parsing/escaping/validation; not an opaque type/name edit; parser/declarator fidelity unqualified')},
                'RenameFunctionLocal':{
                    'local_id':('applyLocalRenameAllSlots(address, local_id, new_name)','opaque local ID forwarded unchanged to local resolver, not parsed as Lua ordinal/name; missing local NOT_FOUND; resolution aliases and stability across generation unqualified'),
                    'new_name':('applyLocalRenameAllSlots(address, local_id, new_name)','literal name forwarded unchanged to local rename; no wrapper empty/name validation; name-locked downstream intent, not runtime persistence proof')},
                'SetFunctionLocalType':{
                    'local_id':('applyLocalRetypeAllSlots(address, local_id, new_type)','opaque local ID forwarded unchanged to local resolver, not ordinal/name conversion; missing local NOT_FOUND; generation stability and aliases unqualified'),
                    'data_type':('applyLocalRetypeAllSlots(address, local_id, new_type)','service data_type binds positionally to LocalClient new_type; type syntax unchanged, no slash stripping or wrapper parsing; INVALID_TYPE distinguished from NOT_FOUND and DECOMPILE_FAILED')},
            }
            if not nested and arg['name'] in text_payloads.get(name,{}):
                token,sem=text_payloads[name][arg['name']]
                assert token in code and arg['native_type']=='const std::string&'
                assert 'revision_++;' in code
                if name=='RenameSymbol':
                    assert 'if (sym->type == "function")' in text and '"NOT_SUPPORTED"' in text and '"NOT_FOUND"' in text
                if name=='ApplyDataType':
                    assert 'if (sym && !sym->name.empty())' in code and 'name = sym->name;' in code
                    assert '"DAT_%08llx"' in text
                if name=='RenameDataItem':
                    _,producer=body(adapter,'ArchAdapter::renameDataItem(')
                    assert 'new_name.empty()' in producer and 'global->renameSymbol(sym, new_name)' in producer
                    assert 'dynamic_cast<FunctionSymbol*>(sym) != nullptr' in producer and 'Varnode::namelock' in producer
                if name in {'RenameFunctionLocal','SetFunctionLocalType'}:
                    assert '"NOT_FOUND"' in text and '"DECOMPILE_FAILED"' in text
                    if name=='SetFunctionLocalType': assert '"INVALID_TYPE"' in text
                    else: sem+='; rename maps nominal invalid-type status into DECOMPILE_FAILED, not INVALID_TYPE'
                arg['semantics']='required Lua string (no native default/initializer grants absence); '+sem+'; native revision after successful mutation only, response strings are input echoes not canonical readback; binding generation invalidates before dispatch including failed/partial mutation, not validation-only rejection; NUL/non-ASCII/parser/identifier/rollback behavior and runtime positive/negative evidence unqualified'
                arg['direct_argument_review']={'consumer':LOCAL,'helper':name,'qualification':'source only; runtime unqualified'}
                reviewed.append({'operation':name,'path':arg['name']})
                continue
            creation_fields={
                'CreateType':{'name','kind'}, 'CreateTypeEnum':{'name'},
                'AddTypeMember':{'parent_type_id_or_path','member_name','member_type'},
                'AddTypeEnumMember':{'type_id_or_path','name','value'},
            }
            if not nested and arg['name'] in creation_fields.get(name,set()):
                key=arg['name']
                if name=='CreateType':
                    assert 'if (kind == "struct")' in text and 'd.defineStruct(name, {})' in code
                    assert '"NOT_SUPPORTED"' in text and 'if (ok) revision_++;' in code
                    sem=('required string, EXACT case-sensitive kind struct only; other strings including empty yield NOT_SUPPORTED after loaded guard, no native mutation/revision; not a general datatype creation selector' if key=='kind' else 'required string forwarded literally as defineStruct name with EMPTY field vector; wrapper performs no empty/name/duplicate validation or leading-slash removal; size ignored, not structure layout')
                elif name=='CreateTypeEnum':
                    assert 'd.defineEnum(name, std::vector<ghidra_standalone::EnumValue>{})' in code
                    sem='required string forwarded literally as defineEnum name with EMPTY entries; no wrapper empty/name/duplicate validation or slash stripping; width/is_signed ignored, not evidence of requested enum representation'
                elif name=='AddTypeMember':
                    assert 'std::string name = parent;' in code and "name = name.substr(1)" in code
                    assert 'listTypeMembers(name)' in code and 'fields.push_back({member_name, member_type, off})' in code
                    assert 'int end = static_cast<int>(m.offset) + static_cast<int>(m.size)' in code
                    assert 'd.defineStruct(name, fields)' in code
                    if key=='parent_type_id_or_path':
                        sem='service parent_type_id_or_path binds positionally to LocalClient parent; required string, strip exactly ONE leading slash then listTypeMembers by literal type name, no numeric ID/hierarchy; missing/wrong-kind empty member vector is NOT explicitly rejected before defineStruct, not proof existing parent required'
                    else:
                        sem='required string '+key+' copied verbatim into appended FieldDef, no wrapper validation/escaping/slash normalization; whole structure reconstructed, not opaque in-place field insertion'
                    sem+='; append offset max(0, existing offset+size), no alignment/padding calculation; all existing offsets/sizes and signed sums must fit INT_MAX independently of ignored requested size'
                else:
                    assert 'std::string type_name = type_id_or_path;' in code and 'type_name = type_name.substr(1)' in code
                    assert 'listTypeEnumMembers(type_name)' in code and 'entries.push_back({name, static_cast<uint64_t>(value)})' in code
                    assert 'd.defineEnum(type_name, entries)' in code
                    if key=='type_id_or_path':
                        sem='required string; strip exactly ONE leading slash then literal enum name lookup, not numeric ID/hierarchy; absent/wrong-kind empty list NOT explicitly rejected before defineEnum; do not promise existing enum required'
                    elif key=='value':
                        assert arg['native_type']=='std::int64_t'
                        sem='required checked signed int64 Lua representation, zero/negative preserved; static_cast<uint64_t> converts modulo 2^64 into EnumValue; out-of-range signed response roundtrip unqualified, not rejection or saturation'
                    else:
                        sem='required string name copied literally into appended EnumValue without wrapper empty/name/duplicate validation or slash stripping'
                    sem+='; rebuild entire enum including prior entries, native traversal/reordering and side-map comment ordinal stability unqualified'
                arg['semantics']=sem+'; loaded guard first; dispatched mutation invalidates binding generation even on native failure, validation-only rejection does not; native revision only on successful define; failed define returns operation-specific error, not successful false; downstream identifier/parser/layout effects and runtime positive/negative qualification remain unqualified'
                arg['direct_argument_review']={'consumer':LOCAL,'helper':name,'qualification':'source only; no runtime qualification'}
                reviewed.append({'operation':name,'path':key})
                continue
            type_alias_ops={'CreateTypeAlias':'createTypeAlias','DeleteTypeAlias':'deleteTypeAlias','SetTypeAliasTarget':'setTypeAliasTarget','DeleteType':'deleteType','RenameType':'renameType'}
            if not nested and name in type_alias_ops:
                consumer=type_alias_ops[name]
                _,producer=body(adapter,'ArchAdapter::'+consumer+'(')
                assert arg['native_type']=='const std::string&'
                if name=='CreateTypeAlias':
                    assert 'a.createTypeAlias(alias_name, target_name)' in code
                    assert 'alias_name.empty() || target_name.empty()' in producer
                    assert 'tf->findByName(target_name)' in producer and 'tf->getTypedef(target, alias_name, 0, 0)' in producer
                    assert 'substr(' not in code
                    if arg['name']=='name':
                        sem='service name binds positionally to LocalClient alias_name; required Lua string, nonempty at adapter, forwarded literally as typedef name; NO slash stripping, numeric ID interpretation or hierarchy resolution; duplicate/identifier validity delegated to TypeFactory'
                    else:
                        assert arg['name']=='target_type'
                        sem='service target_type binds positionally to LocalClient target_name; required Lua string, nonempty at adapter, literal findByName target; NO slash stripping or numeric ID resolution; absent target fails CREATE_ALIAS_FAILED rather than native NOT_FOUND'
                else:
                    local_key='alias_name' if 'Alias' in name else 'type_id_or_path'
                    assert 'std::string name = '+local_key in code
                    assert "if (!name.empty() && name[0] == '/') name = name.substr(1);" in text
                    if name=='SetTypeAliasTarget':
                        assert 'a.setTypeAliasTarget(name, new_target_name)' in code
                        assert 'tf->findByName(new_target_name)' in producer
                        assert 'tf->destroyType(dt)' in producer and 'tf->getTypedef(new_target, alias_name, 0, 0)' in producer
                        assert producer.index('tf->destroyType(dt)')<producer.index('tf->getTypedef(new_target, alias_name, 0, 0)')
                    if arg['name']=='type_id_or_path':
                        sem='required Lua string; '+('service type_id_or_path binds positionally to LocalClient alias_name; ' if 'Alias' in name else '')+'remove exactly ONE leading slash, then literal findByName; not numeric ID, recursive slash removal or hierarchical path; empty normalized name fails; '
                        if 'Alias' in name:
                            assert '!dt->getTypedef()' in producer
                            sem+='must resolve typedef, not arbitrary datatype; '
                        if name=='DeleteType':
                            assert 'arch_->types->destroyType(dt)' in producer
                            sem+='DELETE_TYPE_FAILED core-type wording is not explicit adapter core guard; '
                    elif name=='RenameType':
                        assert arg['name']=='new_name'
                        assert 'a.renameType(name, new_name)' in code and 'arch_->types->setName(dt, new_name)' in producer
                        assert 'new_name.empty()' in producer
                        sem='required nonempty Lua string copied literally to TypeFactory setName, NO new-name slash stripping or wrapper identifier/duplicate validation; response name is request echo, not canonical readback; '
                    else:
                        assert name=='SetTypeAliasTarget' and arg['name']=='target_type'
                        assert 'new_target_name.empty()' in producer
                        sem='service target_type binds positionally to LocalClient new_target_name; required nonempty Lua string, target findByName literal, NO target slash stripping; target must exist BEFORE old alias destruction; '
                    if name=='SetTypeAliasTarget':
                        sem+='destroy-then-recreate alias may be lost on caught recreation error, no rollback; '
                arg['semantics']=sem+'; adapter false conflates absent/ineligible/caught errors, surfaced as operation-specific error not successful false; native revision only after success, binding generation invalidates before dispatched mutation including errors; validation-only rejection does not; runtime identifier/NUL/non-ASCII/rollback and positive/negative slots unqualified'
                arg['direct_argument_review']={'consumer':LOCAL+' / '+ADAPTER,'helper':consumer,'qualification':'source only; no runtime qualification'}
                reviewed.append({'operation':name,'path':arg['name']})
                continue
            payloads={
                'RenameTypeMember':('new_name','std::string field_name = (i == ordinal) ? new_name : existing[i].name;','required Lua string copied verbatim into selected FieldDef name; no wrapper identifier/empty/uniqueness validation; whole struct reconstruction preserves other names/types and signed-int-cast offsets, not isolated rename; downstream parser acceptance and declarator fidelity unqualified'),
                'SetTypeMemberType':('member_type','std::string type_str = (i == ordinal) ? member_type : existing[i].member_type;','required Lua string copied verbatim into selected FieldDef type, not normalized path/ID; no wrapper type validation; whole struct rebuilt using existing offsets narrowed to signed int; requested member size not part of this operation; downstream type parsing/layout acceptance unqualified'),
                'RenameTypeEnumMember':('new_name','std::string entry_name = (i == ordinal) ? new_name : existing[i].name;','required Lua string copied unchanged into selected EnumValue name; no wrapper identifier/empty/duplicate validation; all values recast uint64 and entire enum rebuilt; traversal order/ordinal and signed roundtrip stability unqualified'),
                'SetTypeEnumMemberValue':('value','? static_cast<uint64_t>(value)','required exact signed int64 Lua integer (INT64_MIN..INT64_MAX), not unsigned UInt64 reinterpretation; selected value converted to uint64 modulo 2^64 before defineEnum, retained values also recast; negative values not rejected by wrapper; response uint64-to-int64 beyond range implementation-defined, runtime roundtrip unqualified'),
                'RenameFunctionParameter':('new_name','sig->parameters[ordinal].name = new_name;','required Lua string inserted verbatim into selected parameter name then prototype text; no wrapper identifier/empty/uniqueness validation; no escaping/quoting; punctuation may affect parser, not opaque rename; prototype reconstruction loses calling convention/other metadata; success echo is request, not canonical readback'),
                'SetFunctionParameterType':('data_type','sig->parameters[ordinal].data_type = new_type;','service key data_type binds positionally to LocalClient new_type; required Lua string inserted verbatim into selected parameter data_type then prototype text, not normalized path/ID; no wrapper type validation or escaping/quoting; parser/declarator fidelity unqualified; reconstruction loses calling convention/other metadata; success type echo is request, not canonical readback'),
            }
            if not nested and name in payloads and arg['name']==payloads[name][0]:
                _,token,sem=payloads[name]
                assert token in text
                if name=='SetTypeEnumMemberValue':
                    assert arg['native_type']=='std::int64_t'
                    assert 'entries.push_back({existing[i].name, entry_value})' in code
                else:
                    assert arg['native_type']=='const std::string&'
                if name in {'RenameFunctionParameter','SetFunctionParameterType'}:
                    _,proto=body(source,'std::string buildPrototypeString(')
                    assert 'proto += sig.parameters[i].data_type + " " + sig.parameters[i].name;' in proto
                    assert 'buildPrototypeString(*sig)' in code and 'd.setPrototype(address, proto)' in code
                arg['semantics']=sem+'; no native initializer/default grants Lua optionality; dispatched mutation invalidates generation including failed/partial calls, validation-only rejection does not; positive/negative runtime slots unqualified'
                arg['direct_argument_review']={'consumer':LOCAL,'helper':name,'qualification':'source only; runtime unqualified'}
                reviewed.append({'operation':name,'path':arg['name']})
                continue
            if not nested and name in {'SetTypeMemberComment','SetTypeEnumMemberComment'} and arg['name']=='comment':
                consumer='setTypeMemberComment' if name=='SetTypeMemberComment' else 'setTypeEnumMemberComment'
                assert consumer+'(name, ordinal, comment)' in code
                _,producer=body(adapter,'ArchAdapter::'+consumer+'(')
                store='type_member_comments_' if name=='SetTypeMemberComment' else 'type_enum_member_comments_'
                assert store+'[{type_name, ordinal}] = comment;' in producer
                assert arg['native_type']=='const std::string&'
                arg['semantics']='required Lua string copied byte-for-byte to adapter-local normalized-name/ordinal side map; empty text is stored replacement, not delete/absence; no existence/kind/ordinal or content validation; does not write native project member metadata; persistence and NUL/non-ASCII roundtrip unqualified; aggregate mutation status ignored, revision advances even same value; binding dispatched mutation generation advances, validation-only rejection does not; positive/negative runtime slots unqualified'
                arg['direct_argument_review']={'consumer':ADAPTER,'helper':consumer,'qualification':'source only; runtime unqualified'}
                reviewed.append({'operation':name,'path':arg['name']})
                continue
            member_edits={'DeleteTypeMember','RenameTypeMember','SetTypeMemberType','DeleteTypeEnumMember','RenameTypeEnumMember','SetTypeEnumMemberValue','SetTypeMemberComment','SetTypeEnumMemberComment'}
            parameter_edits={'RenameFunctionParameter','SetFunctionParameterType'}
            key=arg['name']
            if not nested and name in member_edits|parameter_edits and (key=='ordinal' or key in {'parent_type_id_or_path','type_id_or_path'}):
                if name in parameter_edits:
                    assert key=='ordinal' and arg['native_type']=='int'
                    assert 'ordinal < 0 || ordinal >= static_cast<int>(sig->parameters.size())' in code
                    assert code.index('getFunctionSignature(address)')<code.index('ordinal < 0')
                    sem='required checked signed Lua integer fitting native int; zero-based formal parameter position, not Lua 1-based array index; negative or >= parameter count returns OUT_OF_RANGE after decompile/signature extraction, absent signature first returns NOT_FOUND; supported count <=INT_MAX due to signed cast; reconstruction loses calling convention/other signature metadata; no durable ordinal identity'
                else:
                    is_enum='Enum' in name
                    comment=name.endswith('Comment')
                    parent='type_id_or_path' if is_enum else 'parent_type_id_or_path'
                    var='type_name' if is_enum and not comment else 'name'
                    assert 'std::string '+var+' = '+parent in code
                    assert "if (!"+var+".empty() && "+var+"[0] == '/') "+var+' = '+var+'.substr(1);' in text
                    if key=='ordinal':
                        assert arg['native_type']=='std::uint64_t'
                        if comment:
                            assert 'ordinal >= existing.size()' not in code
                            consumer='setTypeEnumMemberComment' if is_enum else 'setTypeMemberComment'
                            assert consumer+'(name, ordinal, comment)' in code
                            sem='required exact UInt64 zero-based ordinal side-map key; no existence/kind/range validation or signed narrowing in wrapper; arbitrary ordinal accepted even for missing type; not observed native member identity, comment does not follow renamed/reordered members'
                        else:
                            assert 'ordinal >= existing.size()' in code and '"NOT_FOUND"' in text
                            assert 'i == ordinal' in code
                            sem='required exact UInt64 zero-based current adapter traversal ordinal, not numeric member ID or Lua array index; >= existing.size() returns NOT_FOUND before reconstruction (missing/wrong-kind type gives empty list); whole struct/enum rebuild may change subsequent ordinal identity; no side-map comment remap; retained struct offsets narrow to signed int; enum signed-value casts/ordering roundtrip unqualified'
                    else:
                        assert key==parent and arg['native_type']=='const std::string&'
                        sem='required Lua string; remove exactly one leading slash then use literal normalized name, not hierarchical path or numeric ID; '+('comment writes side map without checking type existence/kind and permits empty name' if comment else 'primary adapter findByName plus '+('TypeEnum' if is_enum else 'TypeStruct')+' selection; missing/wrong-kind becomes empty list then ordinal NOT_FOUND; not union editing')
                arg['semantics']=sem+'; dispatched mutation invalidates binding generation before native execution even when native error follows; validation-only rejection does not; runtime positive/negative boundary and identity slots unqualified'
                arg['direct_argument_review']={'consumer':LOCAL,'helper':name,'qualification':'source only; no runtime qualification'}
                reviewed.append({'operation':name,'path':key})
                continue
            if not nested and name in ['ReadBytes','WriteBytes']:
                key=arg['name']
                if name=='ReadBytes':
                    assert 'readBytes(address, length)' in code
                    _,producer=body(adapter,'ArchAdapter::readBytes(')
                    assert 'result.resize(length)' in producer and 'static_cast<int4>(length)' in producer
                    assert producer.index('result.resize(length)')<producer.index('static_cast<int4>(length)')
                    assert 'length == 0' in producer and 'result.clear()' in producer
                else:
                    assert 'd.writeBytes(address, data)' in code
                    assert 'static_cast<std::uint32_t>(data.size())' in code
                if key=='address':
                    assert arg['native_type']=='std::uint64_t'
                    sem='required exact UInt64 literal starting address; zero is valid numeric input, not all-range sentinel; forwarded unchanged, ReadBytes uses default code address space; mapping/end-of-space/wrap and downstream write limits remain unqualified, no invented success at unmapped addresses'
                elif key=='length':
                    assert arg['native_type']=='std::uint32_t'
                    sem='required checked Lua integer; native uint32 range 0..UINT32_MAX narrowed by signed int4 loadFill to effective 0..INT32_MAX; reject above INT32_MAX BEFORE dispatch AND native request-buffer allocation; zero returns empty success; allocation precedes native cast, so uint32-only validation unsafe; empty also conflates caught loader/allocation errors; facade size alias does not change native length key'
                else:
                    assert key=='data' and arg['native_type']=='const std::vector<std::uint8_t>&'
                    sem='required binary Lua string maps byte-for-byte vector<uint8_t>, preserve NUL and empty; length <=UINT32_MAX for response-count fidelity; native count is input size not verified write; empty input still dispatched and increments revision; aggregate mutation result ignored, partial effects/rollback and downstream storage bounds unqualified'
                arg['semantics']=sem+'; validation-only rejection does not advance dispatch generation; positive/negative runtime boundary slots unqualified'
                arg['direct_argument_review']={'consumer':LOCAL+' / '+ADAPTER,'helper':name,'qualification':'source only; no runtime qualification'}
                reviewed.append({'operation':name,'path':key})
                continue
            if not nested and ((name=='GetType' and arg['name']=='path') or (name in ['ListTypeMembers','ListTypeEnumMembers'] and arg['name']=='type_id_or_path')):
                if name=='GetType':
                    assert 'getType(name)' in code
                    _,producer=body(adapter,'ArchAdapter::getType(')
                    assert 'arch_->types->findByName(name)' in producer and 'name.empty()' in producer
                    assert 'substr(' not in code
                    sem='service declaration key path binds positionally to LocalClient parameter name; required Lua string forwarded literally to findByName, NO leading-slash removal; empty/missing or caught adapter error becomes absent success, facade synthetic NOT_FOUND; slash path is not hierarchy or numeric ID resolution'
                else:
                    assert 'std::string name = type_id_or_path' in code
                    assert "if (!name.empty() && name[0] == '/') name = name.substr(1);" in text
                    consumer='listTypeMembers' if name=='ListTypeMembers' else 'listTypeEnumMembers'
                    assert consumer+'(name)' in code
                    _,producer=body(adapter,'ArchAdapter::'+consumer+'(')
                    assert 'findByName(type_name)' in producer
                    kind='TypeStruct' if name=='ListTypeMembers' else 'TypeEnum'
                    assert 'dynamic_cast<'+kind+'*>' in producer
                    sem='required Lua string; strip exactly ONE leading slash then literal findByName; despite name, not numeric ID resolution; empty/missing/wrong-kind yields empty success, only '+kind+' supported (struct member pages do not cover unions); traversal ordinals not durable identity; caught errors may retain partial output'
                arg['semantics']=sem+'; no transcoding/case-folding or arbitrary size cap inferred; embedded-NUL/non-ASCII and runtime lookup slots unqualified'
                arg['direct_argument_review']={'consumer':LOCAL+' / '+ADAPTER,'helper':name,'qualification':'source only; runtime lookup slots unqualified'}
                reviewed.append({'operation':name,'path':arg['name']})
                continue
            query_consumers={'ListTypes':('listTypes','dt'),'ListTypeAliases':('listTypeAliases','dt'),'ListTypeEnums':('listTypeEnums','te'),'ListTypeUnions':('listTypeUnions','dt')}
            ignored={'DeleteSymbol':{'name_filter'},'GetDecompilation':{'timeout_ms'},'ListDecompilations':{'timeout_ms'},'CreateType':{'size'},'AddTypeMember':{'size'},'CreateTypeEnum':{'width','is_signed'}}
            if not nested and name in query_consumers and arg['name']=='query':
                consumer,var=query_consumers[name]
                assert consumer+'(query)' in code
                _,producer=body(adapter,'ArchAdapter::'+consumer+'(')
                assert '!query.empty() && '+var+'->getName().find(query) == std::string::npos' in producer
                arg['semantics']='native std::string forwarded unchanged; empty query disables filter; nonempty case-sensitive byte substring of datatype name before pagination, not regex/glob/path hierarchy, no case-folding; Lua input default/requiredness outside approved slice grammar remains explicit unresolved surface policy; native empty behavior is not optionality proof; runtime NUL/non-ASCII matching unqualified'
                arg['direct_argument_review']={'consumer':ADAPTER,'helper':consumer,'qualification':'source only; runtime filter slots unqualified'}
                reviewed.append({'operation':name,'path':arg['name']})
                continue
            if not nested and arg['name'] in ignored.get(name,set()):
                assert not re.search(r'(?<![.\w])'+arg['name']+r'\b',code),(name,arg['name'])
                arg['ignored']=True
                arg['semantics']='native argument never read in LocalClient body; preserve ignored-field fidelity, do not implement its advertised effect; typed/narrow input validation and defaults remain surface-specific before dispatch; ignored is not permission to accept arbitrary Lua values; runtime positive/negative slots unqualified'
                if arg['name']=='timeout_ms':
                    arg['semantics']+='; no native timeout forwarded/enforced; facade rejects timeout option, lowlevel retains typed ignored field'
                elif arg['name']=='size':
                    arg['semantics']+='; requested size does not control reconstructed layout; existing member signed-int offsets/sizes/sums still require <=INT_MAX independently'
                elif arg['name']=='name_filter':
                    arg['semantics']+='; deletion is address-only, name is not a guard'
                else:
                    arg['semantics']+='; enum width/signedness not enforced by this wrapper'
                arg['direct_argument_review']={'consumer':LOCAL,'helper':name,'qualification':'source only; runtime ignored-field slots unqualified'}
                reviewed.append({'operation':name,'path':arg['name']})
                continue
            if not nested and name in range_consumers and arg['name'] in ['range_start','range_end']:
                key=arg['name']
                consumer=range_consumers[name]
                assert consumer+'(range_start, range_end' in code
                assert arg['native_type']=='std::uint64_t'
                target=('instruction START addresses in a linear sweep beginning exactly at range_start, not discovered mapped regions; decoder gaps/zero length/wrap terminate' if name=='ListInstructions' else 'function ENTRY addresses, not returned block/xref endpoints or whole function extent' if consumer=='listFunctions' else 'record start addresses, not overlap of whole record extent')
                arg['semantics']=('Lua default 0; exact UInt64 inclusive lower bound; zero is literal start, not absence' if key=='range_start' else 'Lua default UINT64_MAX; exact UInt64 inclusive upper bound; explicit zero normalized to UINT64_MAX at native normalize_range_end; cannot select only address zero with end=0')+'; selects '+target+'; start>end after normalization yields empty native candidates, not wrapper INVALID_ARGUMENT; filter precedes pagination (signature missing records still filtered after candidate page); runtime address-space/storage bounds unqualified'
                arg['direct_argument_review']={'consumer':ADAPTER,'helper':consumer+' / normalize_range_end','qualification':'source only; zero/max/reversed boundary fixture slots unqualified'}
                reviewed.append({'operation':name,'path':key})
                continue
            if not nested and name=='ListDefinedStrings':
                assert arg['name'] in ['range_start','range_end','limit','offset']
                assert not re.search(r'\b'+arg['name']+r'\b',code)
                arg['ignored']=True
                arg['semantics']='native never reads this argument; loaded constant-empty success ignores range and pages, no zero-sentinel/filter/cursor behavior observed; Lua typed/bounded input validation remains separate before dispatch; known-string positive fixture must preserve empty fidelity exception, unloaded/validation negatives remain unqualified; no discovery iterator'
                arg['direct_argument_review']={'consumer':LOCAL,'helper':'ListDefinedStrings','qualification':'source only; fidelity and negative runtime slots unqualified'}
                reviewed.append({'operation':name,'path':arg['name']})
                continue
            if not nested and 'page_wrapper_review' in op and arg['name'] in ['limit','offset']:
                key=arg['name']
                assert re.search(r'\b'+key+r'\b',code)
                assert arg['native_type']=='int'
                if key=='limit':
                    assert arg['binding_default']=='100'
                    sem='Lua default 100; positive bounded page length <=INT_MAX, reject zero/negative before dispatch (native limit<=0 means all remaining, deliberately not inherited); native end=min(start+limit,n) uses signed int arithmetic; offset+limit<=INT_MAX required'
                else:
                    assert arg['binding_default']=='0'
                    sem='Lua default 0; zero-based count of pipeline candidates, not address or stable identity; nonnegative <=INT_MAX; native start=min(offset,n), offset>=n yields empty; negative native offset would form invalid iterator so reject before dispatch; offset+limit<=INT_MAX required'
                arg['semantics']=sem+'; native collection size must remain below INT_MAX before cast; exact filter/page stage is operation page_wrapper_review/state_transitions, signatures filter after candidate page and empty output does not establish exhaustion; validation-only rejection must not advance binding generation'
                arg['direct_argument_review']={'consumer':LOCAL,'helper':'paginate','qualification':'source and binding contract only; runtime boundary slots unqualified'}
                reviewed.append({'operation':name,'path':key})
                continue
            if not nested:
                ledger.append({'operation':name,'path':arg['name'],'reason':'direct argument consumption/default/domain review not yet independently reconciled'})
                continue
            assert name in expected
            assert {f['path'] for f in nested}==expected[name],name
            if name=='OpenProgram':
                assert set(re.findall(r'\brequest\.(\w+)',code))==expected[name]-{'project_name','read_only'}
                assert code.index('loadProject(')<code.index('loadBinary(')
                assert 'if (request.language_id.empty())' in code and 'arch = opts_.default_arch' in code
            elif name=='AddPerfBenchmark':
                assert set(re.findall(r'\brecord\.(\w+)',code))=={'bench_id'}
                assert 'perf_benchmarks_.push_back(record)' in code
            else:
                assert set(re.findall(r'\bpatch\.(\w+)',code))=={'address','data'}
                assert 'd.writeBytes(patch.address, patch.data)' in code
            for f in nested:
                key=f['name']
                if name=='OpenProgram':sem=open_semantics[key]
                elif name=='PatchBytesBatch':
                    sem=('exact UInt64 patch start forwarded unchanged; no sorting/dedup/coalescing; patches dispatched in input order, later overlaps may overwrite earlier bytes; downstream bounds unqualified' if key=='address' else 'binary bytes forwarded unchanged per patch including NUL/empty; native input size cast and total uint32 accumulator require each and summed sizes <=UINT32_MAX for count fidelity; patch count <=UINT32_MAX; no rollback on partial effects')
                else:
                    sem=('nonempty native string required (lowercase invalid_argument on empty); exact bench_id upsert key, erase matches then append so replacement moves to tail' if key=='bench_id' else 'caller-supplied field copied unchanged with complete record; not measured/computed/validated by native, including empty strings or double zero; no adapter finite/sign acceptance policy inferred')
                f['semantics']=(f['semantics']+'; '+sem) if name=='AddPerfBenchmark' else sem
                f['request_field_review']={'consumer':LOCAL,'operation':name,'native_absence':'model initializer '+f['native_default']+'; Lua input default/requiredness must not be inferred from native model alone','qualification':'source only; runtime and binding validation unqualified'}
    return {'direct_argument_review_missing':ledger,'direct_arguments_reviewed':reviewed,'nested_field_review_count':sum(len(a['nested_fields']) for o in operations if o['implementation'] for a in o['request'])}
