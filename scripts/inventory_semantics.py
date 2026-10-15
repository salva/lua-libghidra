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
