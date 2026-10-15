"""Reviewed page contracts. Runtime ordering/uniqueness remains unqualified."""
import hashlib
import re

ADAPTER = 'cpp/src/local_arch_adapter.cpp'
LOCAL = 'cpp/src/local_client.cpp'


def body(source, signature):
    start = source.index(signature)
    opening = source.index('{', start)
    depth, end = 1, opening + 1
    while depth:
        depth += (source[end] == '{') - (source[end] == '}')
        end += 1
    return start, source[opening:end]


def review_pages(u, operations):
    """Bind reviewed facts to exact method bodies; independent tests pin facts."""
    pages = {
        'ListTypeEnums': ('listTypeEnums', ['path_name'], 'TypeFactory dependentOrder after TypeEnum selection, not lexical path order', 'TypeEnum dynamic cast and substring name query before paginate; type_id is filtered counter', False),
        'ListTypeEnumMembers': ('listTypeEnumMembers', ['type_path_name', 'ordinal'], 'TypeEnum beginEnum/endEnum traversal; ordinal assigned in traversal order, not Lua array index', 'findByName then TypeEnum cast; absent/wrong kind yields empty; LocalClient strips one leading slash before lookup; no post-page filtering', False),
        'ListTypeMembers': ('listTypeMembers', ['parent_type_path_name', 'ordinal'], 'TypeStruct beginField/endField traversal; ordinal assigned in traversal order', 'findByName then TypeStruct cast; absent/wrong kind yields empty; unions not handled; LocalClient strips one leading slash; no post-page filtering', False),
        'GetComments': ('getComments', ['address', 'kind'], 'std::map<pair<uint64,int>,string> lexicographic address then native kind order', 'binding-local comment map only; inclusive address range before paginate; conversion after paginate preserves count', True),
        'ListDataItems': ('listDataItems', ['address'], 'global symbol MapIterator traversal, no explicit sort or duplicate-address elimination', 'skip FunctionSymbol and dynamic/unmapped entries; inclusive range before pagination; address identity needs duplicate qualification; missing datatype uses undefined and size zero', True),
        'ListFunctions': ('listFunctions', ['entry_address'], 'global symbol MapIterator traversal, no explicit sort; native comment says address order', 'mapped FunctionSymbols only; inclusive entry-address range before pagination; size derived from next collected function gap, final footprint', True),
        'ListSymbols': ('listSymbols', ['address', 'name'], 'global symbol MapIterator traversal; no explicit sort or name tie-break', 'dynamic/unmapped entries removed then inclusive address range before pagination; symbol_id assigned after filtering and restarts each call', True),
        'ListTypes': ('listTypes', ['path_name'], 'TypeFactory dependentOrder, not lexical path order', 'substring query on native name before pagination; type_id is query-dependent counter, not stable identity', False),
        'ListTypeAliases': ('listTypeAliases', ['path_name'], 'TypeFactory dependentOrder, not lexical path order', 'getTypedef nonnull and substring query before pagination; type_id is filtered counter', False),
        'ListTypeUnions': ('listTypeUnions', ['path_name'], 'TypeFactory dependentOrder, not lexical path order', 'TYPE_UNION and substring query before pagination; type_id is filtered counter', False),
        'ListInstructions': ('listInstructions', ['address'], 'strictly advancing decode address until gap, zero length or wrap; no mapped-region enumeration', 'decode from exact range_start with inclusive range_end and scan cap limit+offset, then paginate; no filtering after pagination', True),
        'ListMemoryBlocks': ('listMemoryBlocks', ['start_address', 'name'], 'zero or one synthetic default code-space record', 'not actual mapped segment enumeration; absent arch/code space gives empty; highest+1 size may wrap uint64 at full-width address space', False),
    }
    for op in operations:
        if op['name'] not in pages: continue
        method, identity, order, filtering, sentinel = pages[op['name']]
        source = (u/ADAPTER).read_text()
        start, text = body(source, 'ArchAdapter::'+method+'(')
        local = (u/LOCAL).read_text()
        _, local_body = body(local, ' '+op['name']+'(')
        page = op['pagination']
        page.update(identity={'fields': identity, 'encoding': 'exact UInt64 hex and length-delimited text compound keys', 'uniqueness': 'not runtime qualified; reject duplicates before enabling iterator'}, order=order, comparator='not approved: source traversal order is not a proven public total-order comparator', cursor_domain='returned record sequence after adapter filtering, before paginate', post_page_filter='none', pre_page_filter=filtering, range_zero_end=sentinel, source_review={'path':ADAPTER,'line':source.count('\n',0,start)+1,'method':method,'body_sha256':hashlib.sha256(text.encode()).hexdigest()}, iterator='disabled pending real serial stability/identity/order qualification')
        if 'catch (...)' in text:
            op['limitations'].append('adapter catches all exceptions and logs; may return partial/empty success instead of propagating exception')
        else:
            op['limitations'].append('adapter has no local catch-all; do not infer partial-success exception behavior from other page families')
        # Do not pretend all source traversal orders can use an address comparator.
        op['semantic_review'] = 'page adapter and LocalClient dispatch reviewed; runtime unqualified; remaining field/facade obligations still open'
        if op['name']=='ListInstructions':
            assert 'limit + offset' in local_body
            page['scan_bound']='checked limit+offset <=INT_MAX before dispatch; adapter limit<=0 fallback is not used by binding'
        if sentinel:
            assert 'normalize_range_end(range_end)' in text
        if op['name'] in ['ListTypes','ListTypeAliases','ListTypeUnions','ListTypeEnums']:
            assert 'dependentOrder' in text
        if op['name'] in ['ListTypeMembers','ListTypeEnumMembers']:
            assert "name = name.substr(1)" in local_body
            assert 'ordinal++' in text
            op['limitations'].append('type_id_or_path is treated as name/path after removing one leading slash; no numeric-ID resolution here')
            overrides = ({
                'type_id': 'not assigned by adapter; model initializer retained (not a lookup identity)',
                'ordinal': 'zero-based uint64 traversal counter; preserve exact UInt64; comments keyed by normalized type name and ordinal',
                'value': 'native enum key cast to signed int64; preserve signed Lua integer',
                'comment': 'empty model default unless side-map has normalized type-name/ordinal key',
            } if op['name']=='ListTypeEnumMembers' else {
                'parent_type_id': 'not assigned by adapter; model initializer retained (not a lookup identity)',
                'ordinal': 'zero-based uint64 field traversal counter; preserve exact UInt64',
                'offset': 'native TypeField offset, signed int64 model; not UInt64',
                'size': 'referenced field datatype getSize; not requested AddTypeMember size',
                'comment': 'empty model default unless normalized type-name/ordinal side-map key exists',
            })
            for field in op['response']['fields']:
                if field['name'] in overrides:
                    field['semantics'] = overrides[field['name']]
        if op['name']=='GetComments':
            header = (u/'cpp/src/local_arch_adapter.hpp').read_text()
            assert 'std::map<std::pair<std::uint64_t, int>, std::string> comments_' in header
            page['comparator'] = 'candidate lexicographic (exact UInt64 address, numeric native CommentKind); runtime order gate unqualified'
            op['limitations'].append('comments are adapter side-map entries, not populated from analyzed native project comment database here')
    return operations


def review_aggregate_pages(u, operations):
    """Pages whose cursor domain is decided by LocalClient, not one adapter call."""
    contracts = {
        'ListLeafFunctions': (['entry_address'], 'matched leaf function records', 'function traversal restricted by binary_search of project leaf-entry index BEFORE paginate', 'function traversal order after leaf filtering', 'none'),
        'ListBasicBlocks': (['function_entry', 'start_address', 'end_address'], 'concatenated extracted blocks', 'inclusive range selects FUNCTION ENTRIES, not returned block addresses; invalid block starts omitted before pagination', 'serial function traversal then structured basic-block collection (raw graph fallback); multi-slot completion order unsupported', 'none'),
        'ListCFGEdges': (['function_entry', 'src_block_start', 'dst_block_start', 'edge_kind'], 'concatenated extracted edges', 'inclusive range selects FUNCTION ENTRIES, not returned edge endpoints; invalid starts/nonbasic destinations omitted before pagination', 'serial function traversal then collected basic blocks and outgoing edge index; multi-slot completion order unsupported', 'none'),
        'ListXrefs': (['from_address', 'to_address', 'ref_type'], 'concatenated extracted references', 'inclusive range selects FUNCTION ENTRIES, not reference source/destination; call refs then constant-address LOAD then STORE refs before pagination', 'serial function traversal then extraction groups, NOT numeric source order; multi-slot completion order unsupported', 'none'),
        'ListDecompilations': (['function_entry_address'], 'candidate function page (one output per candidate)', 'inclusive function-entry range before paginate; decompileMany produces same-size indexed result vector', 'candidate function traversal retained by result index even with multiple slots', 'none: failures retained as completed=false records'),
        'ListFunctionSignatures': (['function_entry_address'], 'candidate functions', 'inclusive function-entry range then paginate BEFORE signature extraction', 'candidate traversal with missing signatures omitted; parallel branch preserves candidate index before filtering', 'missing signatures omitted AFTER candidate pagination; empty output not exhaustion'),
    }
    source = (u/LOCAL).read_text()
    adapter = (u/ADAPTER).read_text()
    for op in operations:
        name = op['name']
        if name not in contracts: continue
        identity, domain, filtering, order, post = contracts[name]
        start, text = body(source, ' '+name+'(')
        page = op['pagination']
        page.update(identity={'fields':identity, 'encoding':'exact UInt64 hex and length-delimited text', 'uniqueness':'unqualified; reject duplicates before iterator enablement'}, cursor_domain=domain, pre_page_filter=filtering, post_page_filter=post, order=order, comparator='not approved: source traversal is not a proven total-order comparator', range_zero_end=True, iterator='disabled pending real identity/order/stability qualification', source_review={'path':LOCAL, 'line':source.count('\n',0,start)+1, 'body_sha256':hashlib.sha256(text.encode()).hexdigest()})
        assert 'listFunctions(range_start, range_end)' in text
        _, functions = body(adapter, 'ArchAdapter::listFunctions(')
        assert 'normalize_range_end(range_end)' in functions
        if name in ['ListDecompilations','ListFunctionSignatures']:
            assert text.index('paginate(') < text.index('for (')
        if name=='ListLeafFunctions':
            assert text.index('binary_search') < text.index('paginate(matched')
            op['limitations'].append('no bare-binary fallback: missing project leaf index returns NOT_SUPPORTED, not guessed leaves')
        if name in ['ListBasicBlocks','ListCFGEdges','ListXrefs']:
            assert 'pool_->size() <= 1' in text
            op['limitations'].append('binding pool_size=1 required: parallel append completion order cannot be repaired by sorting individual pages')
        if name in ['ListBasicBlocks','ListCFGEdges']:
            _, extraction = body(adapter, 'ArchAdapter::decompileAndExtractCFG(')
            op['limitations'].append('CFG extraction may create/name missing function and run analysis despite read dispatch classification; catches/logs exceptions and may return partial results')
            assert 'collectBasicBlocks' in extraction
            if name=='ListCFGEdges':
                op['limitations'].append('edge_kind heuristic: BACK by destination index<=source index, else two-outgoing FALSE/TRUE by edge index, else FALL_THROUGH; preserve native text')
        if name=='ListXrefs':
            _, extraction = body(adapter, 'ArchAdapter::listXrefsForFunction(')
            assert extraction.index('CPUI_LOAD') < extraction.index('CPUI_STORE')
            op['limitations'].append('decompilation-derived subset, not project reference database: calls and constant-address LOAD/STORE only; duplicate identities possible; catch/log may yield partial success')
        if name=='ListFunctionSignatures':
            page['iterator']='pages only by specification; no returned-count cursor or empty-page exhaustion inference'
            assert 'if (sig) sigs.push_back' in text
        if name=='ListDecompilations':
            pool=(u/'cpp/src/decompiler_pool.cpp').read_text()
            _, batch=body(pool, 'DecompilerPool::decompileMany(')
            assert 'results(addresses.size())' in batch and 'results[i].completed = false' in batch
            op['limitations'].append('native batch retained; failed decompilations are present records, not missing optional values; error_message from decompileWithLocals')
        op['semantic_review']='aggregate cursor/filter/ordering branches reviewed; remaining conversion/field and runtime gates open'
    return operations


def review_session_records(u, operations):
    """Explicit state/error branches, kept separate from dispatch generation policy."""
    source = (u/LOCAL).read_text()
    _, close = body(source, 'closeProgramLocked(ShutdownPolicy policy)')
    assert close.index('SAVE_FAILED') < close.index('resetAdapters()') < close.index('program_loaded_ = false')
    assert 'should_save && !opts_.state_path.empty()' in close
    pool = (u/'cpp/src/decompiler_pool.cpp').read_text()
    _, reset = body(pool, 'DecompilerPool::resetAdapters(')
    assert 'slot.adapter.reset()' in reset and 'slot.decomp.reset()' not in reset
    contracts = {
        'SaveProgram': ('loaded program; empty state_path -> NO_STATE_PATH', 'saveState failure -> SAVE_FAILED; success saved=true; does not close or increment native revision'),
        'DiscardProgram': ('owner open; no loaded-program guard', 'discarded=true even unloaded; no rollback, state change or native revision increment'),
        'GetRevision': ('owner open; usable without program', 'modification_number exact UInt64 revision_; no reset/refresh implied'),
        'CloseProgram': ('unloaded -> NO_PROGRAM', 'kSave with nonempty state_path attempts save; failure preserves access/benchmarks; empty state_path skips saving; all nonsave policies close; reset adapters, loaded=false and clear benchmarks; engines retained'),
        'Shutdown': ('owner open; unloaded accepted=true', 'loaded delegates closeProgramLocked; propagates failure code/message unchanged; success accepted=true; does not terminate host or release owner'),
        'AddPerfBenchmark': ('loaded required; empty bench_id -> lowercase invalid_argument', 'erase matching bench_id then append detached record; replacement moves to tail; revision increments on every successful upsert; added=true'),
        'ListPerfBenchmarks': ('loaded required', 'complete vector in insertion/upsert order; no pagination/filter/cursor; identity bench_id; order not lexical'),
        'ClearPerfBenchmarks': ('loaded required', 'removed_count uint32 cast from vector size; cleared=true even empty; clear then native revision increments unconditionally'),
        'DeletePerfBenchmark': ('loaded required; empty bench_id -> lowercase invalid_argument', 'erase matching bench_id; deleted=false if absent; revision increments only when an entry removed'),
    }
    for op in operations:
        if op['name'] not in contracts: continue
        name=op['name']; start,text=body(source, ' '+name+'(')
        state, transitions=contracts[name]
        op['program_state']=state
        op['state_transitions']=transitions
        op['semantic_review']='LocalClient session/performance error, state and revision branches reviewed; downstream persistence and runtime remain unqualified'
        op['session_source_review']={'path':LOCAL,'line':source.count('\n',0,start)+1,'body_sha256':hashlib.sha256(text.encode()).hexdigest()}
        if name in ['CloseProgram','Shutdown']:
            op['native_literal_errors']=sorted(set(op['native_literal_errors']+['NO_PROGRAM','SAVE_FAILED'])) if name=='CloseProgram' else op['native_literal_errors']
            op['limitations'].append('helper save failure occurs before logical close; owner CLOSED is binding release only; native close does not increment revision')
        if 'PerfBenchmark' in name:
            assert 'if (!program_loaded_)' in text
            if name in ['AddPerfBenchmark','DeletePerfBenchmark']:
                assert '"invalid_argument"' in text
            if name=='AddPerfBenchmark':
                assert text.index('perf_benchmarks_.erase') < text.index('perf_benchmarks_.push_back(record)')
            if name=='DeletePerfBenchmark': assert 'if (deleted) revision_++' in text
            if name=='ListPerfBenchmarks':
                op['collection_contract']={'identity':['bench_id'],'order':'vector insertion/upsert order; replacements appended','pagination':'none: whole vector; no iterator cursor contract','qualification':'unqualified'}
            if name=='ClearPerfBenchmarks':
                op['limitations'].append('binding must constrain supported vector count <=UINT32_MAX before relying on removed_count; native cast can truncate larger counts')
        if name=='DiscardProgram': assert 'program_loaded_' not in text and 'revision_++' not in text
    return operations


def review_open_and_creation(u, operations):
    """Separate initialized metadata from detected metadata and ignored widths."""
    source=(u/LOCAL).read_text()
    contracts={
        'OpenProgram': 'project_path nonempty takes precedence; otherwise program_path required; load failure -> LOAD_FAILED; best-effort loadState ignored; success loaded=true and revision increments',
        'CreateType': 'loaded required; only kind exactly struct invokes defineStruct(name,{}); size ignored; native revision increments only on success; failure CREATE_TYPE_FAILED; other kinds NOT_SUPPORTED',
        'AddTypeMember': 'loaded required; normalize one slash, read existing members, rebuild entire struct and append referenced type at maximum existing offset+size; size ignored; failure ADD_MEMBER_FAILED; revision only on success',
        'CreateTypeEnum': 'loaded required; defineEnum(name,empty entries); width/is_signed ignored; CREATE_ENUM_FAILED on failure; revision only on success',
    }
    for op in operations:
        name=op['name']
        if name not in contracts: continue
        start,text=body(source,' '+name+'(')
        op['state_transitions']=contracts[name]
        op['creation_source_review']={'path':LOCAL,'line':source.count('\n',0,start)+1,'body_sha256':hashlib.sha256(text.encode()).hexdigest()}
        if name=='OpenProgram':
            assert text.index('!request.project_path.empty()') < text.index('!request.program_path.empty()')
            assert 'pool_->loadState(opts_.state_path);' in text
            assigned=set(re.findall(r'resp\.(\w+)\s*=',text))
            assert assigned=={'program_name','language_id','compiler_spec'}
            for f in op['response']['fields']:
                f['semantics']=('request/default echo, not authoritative detected architecture' if f['name'] in ['language_id','compiler_spec'] else 'request program_path if nonempty, else project_path' if f['name']=='program_name' else 'not assigned by LocalClient OpenProgram; preserve native model default, not detected metadata')
            op['limitations'].append('image_base/entry_point/has_entry_point/executable_format/hashes are model defaults in this override; complete Lua envelope must not relabel them as detected facts')
            op['limitations'].append('request language+compiler concatenated when both nonempty; otherwise language or client default_arch; project route does not forward architecture/base/format hints')
        if name=='CreateType': assert 'kind == "struct"' in text and 'defineStruct(name, {})' in text
        if name=='AddTypeMember':
            assert 'static_cast<int>(m.offset) + static_cast<int>(m.size)' in text
            op['effective_domain']={'existing_fields':'all offsets and sizes must fit int and each offset+size <=INT_MAX before native struct rebuild; native casts/addition otherwise risk truncation/overflow','request_size':'uint64 validated but ignored; must not promise requested member size is enforced','qualification':'constraint identified; binding implementation and runtime validation unqualified'}
        if name=='CreateTypeEnum': assert 'defineEnum(name, std::vector<ghidra_standalone::EnumValue>{})' in text
    return operations


def review_parameter_and_byte_mutations(u, operations):
    """Local reconstruction/count branches; downstream mutation success still unqualified."""
    source=(u/LOCAL).read_text()
    _, prototype=body(source,'buildPrototypeString(const FunctionSignatureRecord& sig)')
    assert 'sig.return_type + " " + sig.function_name' in prototype
    assert 'sig.has_var_args' in prototype
    assert 'calling_convention' not in prototype
    for op in operations:
        name=op['name']
        if name not in ['RenameFunctionParameter','SetFunctionParameterType','WriteBytes','PatchBytesBatch']: continue
        start,text=body(source,' '+name+'(')
        op['mutation_source_review']={'path':LOCAL,'line':source.count('\n',0,start)+1,'body_sha256':hashlib.sha256(text.encode()).hexdigest()}
        if name in ['RenameFunctionParameter','SetFunctionParameterType']:
            assert text.index('if (!sig)') < text.index('ordinal < 0') < text.index('buildPrototypeString(*sig)') < text.index('setPrototype(address, proto)')
            assert 'if (ok) revision_++' in text
            op['state_transitions']='loaded required; decompile to populate signature, absent -> NOT_FOUND; signed int ordinal negative or >=parameter vector count -> OUT_OF_RANGE; modify copy then rebuild prototype and set on all slots; failure SET_PROTOTYPE_FAILED; native revision increments only when ok'
            op['effective_domain']={'ordinal':'signed int, zero-based; parameter collection size must fit INT_MAX before native static_cast<int>(size)','qualification':'source constraint, no runtime enforcement qualification'}
            op['limitations'].append('prototype reconstruction includes return type/function name/parameter data_type and name/varargs only; does not encode calling convention or all signature metadata; no full-signature fidelity promise')
        else:
            assert 'return true;' in text and 'revision_++;' in text
            op['state_transitions']='loaded required; dispatch overlay writes then native revision increments unconditionally on normal return, including empty input; response reports input counts not readback verification'
            op['limitations'].append('all-slot write lambda returns true regardless of d.writeBytes outcome; wrapper does not test aggregated result; thrown exception can leave partial writes; no batch atomicity or verified-byte-count promise')
            if name=='WriteBytes':
                assert 'static_cast<std::uint32_t>(data.size())' in text
                op['effective_domain']={'data_length':'supported input length <=UINT32_MAX to avoid response bytes_written truncation; downstream storage/allocation constraints remain unqualified','qualification':'count constraint identified, runtime unqualified'}
            else:
                assert 'std::uint32_t total_bytes = 0' in text
                assert 'total_bytes += static_cast<std::uint32_t>(patch.data.size())' in text
                op['effective_domain']={'patch_count':'<=UINT32_MAX for patch_count fidelity','total_data_length':'each patch and checked cumulative bytes <=UINT32_MAX to avoid truncation/modulo wrap; downstream address/storage constraints remain unqualified','qualification':'count constraint identified, runtime unqualified'}
                op['limitations'].append('patch order is input array order; overlapping patches applied sequentially; native uint32 counter wraps on oversized cumulative input')
        op['semantic_review']='LocalClient parameter reconstruction or byte count/error branches reviewed; downstream and runtime gates remain unqualified'
    return operations
