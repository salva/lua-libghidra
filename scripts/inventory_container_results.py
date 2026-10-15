"""Explicit response-container population, independent of nested record producers."""
import hashlib
from inventory_semantics import LOCAL, body
from inventory_page_wrappers import SIMPLE

OPTIONALS={
 'GetFunction':('function','getFunction(address)'),
 'GetSymbol':('symbol','getSymbol(address)'),
 'GetInstruction':('instruction','getInstruction(address)'),
 'GetType':('type','getType(name)'),
 'GetFunctionSignature':('signature','getFunctionSignature(address)'),
}
SPECIAL={
 'GetComments':('comments','resp.comments.push_back(std::move(rec))'),
 'ListDataItems':('data_items','resp.data_items.push_back(std::move(rec))'),
 'ListBasicBlocks':('blocks','resp.blocks = paginate(all_blocks, limit, offset)'),
 'ListCFGEdges':('edges','resp.edges = paginate(all_edges, limit, offset)'),
 'ListXrefs':('xrefs','resp.xrefs = paginate(all_xrefs, limit, offset)'),
 'ListDecompilations':('decompilations','resp.decompilations = std::move(records)'),
 'ListFunctionSignatures':('signatures','resp.signatures = std::move(sigs)'),
 'ListLeafFunctions':('functions','resp.functions = paginate(matched, limit, offset)'),
}


def review_container_results(u, operations):
    source=(u/LOCAL).read_text()
    for op in operations:
        name=op['name']
        if name not in OPTIONALS and name not in SIMPLE and name not in SPECIAL and name!='GetDecompilation':continue
        start,text=body(source,' '+name+'(')
        assert 'if (!ensure_loaded())' in text
        if name in OPTIONALS:
            field,call=OPTIONALS[name]
            expression='resp.'+field+' = pool_->primaryAdapter().'+call
            assert expression in text
            semantics='adapter optional copied directly: absent remains absent (Lua nil field), present becomes record table including false/zero/empty nested fields; absent native success can include caught adapter failure, not native NOT_FOUND; facade uses synthetic NOT_FOUND third-result policy, not error substitution in lowlevel'
            if name=='GetFunctionSignature':
                assert text.index('decompileAt(address)')<text.index(expression)
                semantics+='; preceding decompileAt result ignored before optional signature extraction'
        elif name=='GetDecompilation':
            field='decompilation'
            assert 'resp.decompilation = DecompilationRecord{}' in text
            assert 'resp.decompilation = std::move(rec)' in text
            assert 'resp.decompilation->completed = false' in text
            semantics='optional is ALWAYS present on loaded success: failed decompile constructs completed=false/error record, success moves record; never treat completed=false as absence or nil,error; nested branch-specific defaults/population separately reconciled'
        else:
            if name in SIMPLE:
                call,field=SIMPLE[name]
                assert 'resp.'+field+' = paginate(all, limit, offset)' in text
            else:
                field,expression=SPECIAL[name]
                assert expression in text
            assert 'page_wrapper_review' in op and 'state_transitions' in op
            semantics='dense Lua array of returned native records, preserving native sequence and duplicates (no keying by address/id, sorting, dedup or truthiness filtering); empty vector -> empty table, not absence; population/filter/cursor pipeline: '+op['state_transitions']+'; nested field producer/default review remains separate; no stable identity or runtime iterator qualification implied'
        fields=[f for f in op['response']['fields'] if f['path']==field]
        assert len(fields)==1,(name,field)
        fields[0]['semantics']=semantics
        op['container_result_review']={'path':LOCAL,'line':source.count('\n',0,start)+1,'field':field,'body_sha256':hashlib.sha256(text.encode()).hexdigest(),'qualification':'source-only, runtime evidence unqualified'}
