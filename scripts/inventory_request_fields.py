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
