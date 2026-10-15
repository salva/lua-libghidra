"""Graph/reference producer population; flags describe branches, not inferred facts."""
import hashlib
import re
from inventory_semantics import ADAPTER, body


def review_graph_fields(u, operations, types):
    source=(u/ADAPTER).read_text()
    _,cfg=body(source,'ArchAdapter::decompileAndExtractCFG(')
    _,xref=body(source,'ArchAdapter::listXrefsForFunction(')
    def assignments(text):
        return set(re.findall(r'\brec\.(\w+)\s*=',text))
    blocks=cfg[cfg.index('BasicBlockRecord rec;'):cfg.index('result.blocks.push_back')]
    edges=cfg[cfg.index('CFGEdgeRecord rec;'):cfg.index('result.edges.push_back')]
    assert 'rec.end_address = stop.isInvalid() ? rec.start_address : stop.getOffset()' in blocks
    assert 'static_cast<std::uint32_t>(bb->sizeIn())' in blocks
    assert 'static_cast<std::uint32_t>(bb->sizeOut())' in blocks
    assert 'dst_bb->getIndex() <= bb->getIndex()' in edges
    assert '(j == 0) ? "FALSE" : "TRUE"' in edges
    assert cfg.index('if (structure.getSize() > 0)') < cfg.index('else if (raw.getSize() > 0)')
    contracts={
        'BasicBlockRecord':('ListBasicBlocks',cfg,blocks,{
            'function_entry':'input candidate function entry; may not equal any returned block start',
            'start_address':'BlockBasic getStart offset; invalid start blocks skipped',
            'end_address':'inclusive getStop offset, NOT stop+1 or measured last-byte extent; invalid stop falls back to start',
            'in_degree':'native sizeIn cast uint32, counts raw block inputs, not number of emitted edge records',
            'out_degree':'native sizeOut cast uint32, counts raw block outputs including destinations later skipped; not emitted-edge count',
        }),
        'CFGEdgeRecord':('ListCFGEdges',cfg,edges,{
            'function_entry':'input candidate function entry',
            'src_block_start':'source BlockBasic getStart offset; invalid source skipped',
            'dst_block_start':'destination start after descending structured wrappers via first child; nonbasic/invalid destinations skipped',
            'edge_kind':'BACK if destination index<=source index; else FALSE/TRUE for two outputs by j==0; otherwise FALL_THROUGH; heuristic priority, not semantic branch proof',
        }),
    }
    for model,(name,text,fragment,semantics) in contracts.items():
        assert assignments(fragment)==set(semantics)
        assert set(semantics)=={f['name'] for f in types[model]['fields']}
        op=next(o for o in operations if o['name']==name)
        op.setdefault('record_field_reviews',[]).append({'path':ADAPTER,'model':model,
            'body_sha256':hashlib.sha256(text.encode()).hexdigest(),'assigned_fields':sorted(semantics),
            'default_only_fields':[],'qualification':'source assignments only; runtime graph completeness unqualified'})
        for field in op['response']['fields']:
            if field['model']==model:
                field['semantics']=semantics[field['name']]
                field['producer_review']={'path':ADAPTER,'method':'decompileAndExtractCFG'}
        op['graph_population_limits']='structured graph preferred, raw only if structure empty; invalid starts/destinations skipped; no dedup; caught exception can preserve partial output; clearAnalysis is explicit, not RAII here, so exceptional cleanup is not guaranteed by this body'
    # Three independent construction branches: defaults differ for call versus data.
    fragments=xref.split('XrefRecord rec;')[1:]
    assert len(fragments)==3
    fragments=[f[:f.index('result.push_back')] for f in fragments]
    branch_sets=[assignments(f) for f in fragments]
    assert branch_sets==[
        {'from_address','to_address','ref_type','is_flow','is_primary','source'},
        {'from_address','to_address','ref_type','is_memory','source'},
        {'from_address','to_address','ref_type','is_memory','source'}]
    assert '(op->code() == CPUI_CALLIND) ? "COMPUTED_CALL"' in fragments[0]
    assert 'rec.is_primary = true' in fragments[0] and 'rec.is_flow = true' in fragments[0]
    for f in fragments[1:]: assert 'rec.is_memory = true' in f
    assert 'rec.ref_type = "DATA"' in fragments[1] and 'rec.ref_type = "WRITE"' in fragments[2]
    semantics={
        'from_address':'pcode operation instruction address offset for call, LOAD and STORE branches',
        'to_address':'call: FuncCallSpecs entry address offset; LOAD/STORE: constant address varnode offset (only constant input 1 emitted), no space-ID resolution or validity check here',
        'ref_type':'call CALLIND -> COMPUTED_CALL else UNCONDITIONAL_CALL; constant LOAD -> DATA; constant STORE -> WRITE',
        'is_primary':'call literal true; LOAD/STORE model false, not detected primary-reference metadata',
        'is_flow':'call literal true; LOAD/STORE model false',
        'is_memory':'call model false; constant LOAD/STORE literal true',
        'source':'literal ANALYSIS on every emitted branch',
    }
    declared={f['name']:f for f in types['XrefRecord']['fields']}
    assert set(semantics)==set.union(*branch_sets)
    op=next(o for o in operations if o['name']=='ListXrefs')
    op.setdefault('record_field_reviews',[]).append({'path':ADAPTER,'model':'XrefRecord',
        'body_sha256':hashlib.sha256(xref.encode()).hexdigest(),
        'branches':dict(zip(['call','constant_LOAD','constant_STORE'],[sorted(s) for s in branch_sets])),
        'default_only_fields':sorted(set(declared)-set(semantics)),
        'qualification':'source branch assignments only; runtime references/completeness unqualified'})
    for field in op['response']['fields']:
        if field['model']!='XrefRecord':continue
        name=field['name']
        field['semantics']=semantics.get(name,'never assigned in any local xref branch; retain initializer '+declared[name]['native_default']+'; not detected reference/function metadata')
        field['producer_review']={'path':ADAPTER,'method':'listXrefsForFunction'}
    op['xref_population_limits']='calls then constant LOAD then constant STORE, not all native references; missing call specs/op or nonconstant address skipped; no dedup; caught errors may yield partial successful vector; helper performs and clears same-instance analysis, no preceding decompileAt; function/address-space metadata remain defaults'
    return operations
