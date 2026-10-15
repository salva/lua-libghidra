"""Reviewed LocalClient page state/ordering branches, separate from adapter order."""
import hashlib
from inventory_semantics import body, LOCAL

# Explicit reviewed set: source additions cannot silently inherit page approval.
SIMPLE = {
    'ListFunctions': ('listFunctions(range_start, range_end)', 'functions'),
    'ListSymbols': ('listSymbols(range_start, range_end)', 'symbols'),
    'ListMemoryBlocks': ('listMemoryBlocks()', 'blocks'),
    'ListTypes': ('listTypes(query)', 'types'),
    'ListTypeEnums': ('listTypeEnums(query)', 'enums'),
    'ListTypeAliases': ('listTypeAliases(query)', 'aliases'),
    'ListTypeUnions': ('listTypeUnions(query)', 'unions'),
    'ListTypeMembers': ('listTypeMembers(name)', 'members'),
    'ListTypeEnumMembers': ('listTypeEnumMembers(name)', 'members'),
    'ListInstructions': ('listInstructions(range_start, range_end,', 'instructions'),
}
SPECIAL = {'GetComments', 'ListDataItems', 'ListBasicBlocks', 'ListCFGEdges',
           'ListXrefs', 'ListDecompilations', 'ListFunctionSignatures', 'ListLeafFunctions'}


def review_page_wrappers(u, operations):
    source=(u/LOCAL).read_text()
    for op in operations:
        name=op['name']
        if name not in SIMPLE and name not in SPECIAL: continue
        start,text=body(source,' '+name+'(')
        assert 'if (!ensure_loaded())' in text
        assert 'revision_++' not in text and 'catch (' not in text
        op['page_wrapper_review']={'path':LOCAL,'line':source.count('\n',0,start)+1,
                                   'body_sha256':hashlib.sha256(text.encode()).hexdigest(),
                                   'error_policy':'NO_PROGRAM guard; no wrapper catch; exceptions are not rewritten as empty page here; adapter catch behavior is separately inventoried',
                                   'native_revision':'unchanged; native analysis side effects can still occur',
                                   'qualification':'source branch accounting only; runtime fixtures unqualified'}
        op['program_state']='loaded program and valid primary adapter required; otherwise NO_PROGRAM'
        if name in SIMPLE:
            call,field=SIMPLE[name]
            assert call in text and 'resp.'+field+' = paginate(all, limit, offset)' in text
            op['state_transitions']='loaded required; primary adapter enumeration then paginate into '+field+'; no post-page removal or native revision change; native empty enumeration is successful empty page'
            if name in ['ListTypeMembers','ListTypeEnumMembers']:
                assert 'name = name.substr(1)' in text
                op['state_transitions']+='; normalize exactly one leading slash before member lookup'
            if name=='ListInstructions':
                assert 'limit + offset' in text
                op['state_transitions']+='; request at most limit+offset decoded instructions before slicing; checked signed sum must fit INT_MAX'
        elif name in ['GetComments','ListDataItems']:
            method='getComments' if name=='GetComments' else 'listDataItems'
            assert text.index('auto all = paginate(') < text.index('for (const ')
            assert method+'(range_start, range_end)' in text
            op['state_transitions']='loaded required; enumerate then paginate native adapter records BEFORE one-to-one response conversion; conversion preserves candidate count; no native revision change'
            semantics={
                'GetComments': {'address':'adapter side-map key address; copied exactly after pagination',
                                'kind':'adapter native int key cast to CommentKind after pagination; response preserves numeric unknowns',
                                'text':'adapter side-map text copied unchanged, including empty string'},
                'ListDataItems': {'address':'mapped non-function adapter symbol address copied exactly',
                                  'name':'adapter symbol name copied unchanged',
                                  'data_type':'adapter datatype name, undefined when absent; copied unchanged',
                                  'size':'adapter datatype size or zero when missing; exact UInt64',
                                  'end_address':'inclusive address+size-1 for positive size, else address; unsigned arithmetic can wrap, no wrapper saturation'},
            }[name]
            if name=='ListDataItems': assert 'd.size > 0 ? d.address + d.size - 1 : d.address' in text
            else: assert 'static_cast<CommentKind>(c.kind)' in text
            for field in op['response']['fields']:
                if field['name'] in semantics: field['semantics']=semantics[field['name']]
        elif name in ['ListBasicBlocks','ListCFGEdges','ListXrefs']:
            collection={'ListBasicBlocks':'all_blocks','ListCFGEdges':'all_edges','ListXrefs':'all_xrefs'}[name]
            assert 'pool_->size() <= 1' in text and 'f.get();' in text
            assert 'paginate('+collection+', limit, offset)' in text
            op['state_transitions']='loaded required; select function entries by range, aggregate per-function graph/reference output, then paginate aggregate; serial preserves traversal concatenation; parallel appends under mutex in completion order and propagates future errors; no wrapper revision increment'
            if name=='ListXrefs':
                # Comments mention decompileAt; strip them before inspecting dispatch.
                import re
                code=re.sub(r'//[^\n]*','',text)
                assert '.decompileAt(' not in code
                assert 'listXrefsForFunction(func.entry_address)' in code
                op['state_transitions']+='; xref helper owns decompilation/extraction in same instance, no preceding decompileAt that would clear analysis'
        elif name=='ListDecompilations':
            assert text.index('auto funcs = paginate(') < text.index('decompileMany(addresses, names)')
            op['state_transitions']='loaded required; paginate candidate functions first, collect addresses/names in candidate order, dispatch one native decompileMany batch, move all returned records unchanged; failed candidate records retained, no wrapper revision increment'
        elif name=='ListFunctionSignatures':
            assert text.index('auto funcs = paginate(') < text.index('if (sig) sigs.push_back')
            assert 'if (valid[i]) filtered.push_back' in text
            op['state_transitions']='loaded required; paginate candidate functions first; decompile/extract each, remove absent signatures AFTER pagination; serial traversal and parallel indexed output retain candidate relative order; empty results do not establish exhaustion; no wrapper revision increment'
        else:
            assert text.index('projectLeafEntries(leaves)') < text.index('std::binary_search(') < text.index('paginate(matched, limit, offset)')
            op['state_transitions']='loaded required; unavailable project leaf index -> NOT_SUPPORTED; select functions by range, binary-search leaf entries, then paginate matched functions; no graph fallback and no wrapper revision increment'
    return operations
