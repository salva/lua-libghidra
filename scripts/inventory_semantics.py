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
        op['limitations'].append('adapter catches all exceptions and logs; may return partial/empty success instead of propagating exception')
        # Do not pretend all source traversal orders can use an address comparator.
        op['semantic_review'] = 'page adapter and LocalClient dispatch reviewed; runtime unqualified; remaining field/facade obligations still open'
        if op['name']=='ListInstructions':
            assert 'limit + offset' in local_body
            page['scan_bound']='checked limit+offset <=INT_MAX before dispatch; adapter limit<=0 fallback is not used by binding'
        if sentinel:
            assert 'normalize_range_end(range_end)' in text
        if op['name'] in ['ListTypes','ListTypeAliases','ListTypeUnions']:
            assert 'dependentOrder' in text
    return operations
