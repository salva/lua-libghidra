"""Special result paths: constant-empty schema, bytes and coarse capabilities."""
import hashlib
import re
from inventory_semantics import LOCAL, body


def review_special_results(u, operations, types):
    source=(u/LOCAL).read_text()
    for op in operations:
        name=op['name']
        if name not in ['ReadBytes','ListDefinedStrings','GetCapabilities','ListDataItems']:continue
        start,text=body(source,' '+name+'(')
        if name=='ReadBytes':
            assert 'resp.data = std::move(data)' in text
            assert 'readBytes(address, length)' in text
            for field in op['response']['fields']:
                assert field['name']=='data'
                field['semantics']='moved adapter byte vector to binary Lua string, preserve NUL and exact length; zero length or caught loader/allocation failure gives empty success, not nil/error; requested length must be bounded 0..INT32_MAX before native allocation/dispatch; no partial bytes after caught failure'
        elif name=='ListDefinedStrings':
            assert 'ListDefinedStringsResponse resp;' in text
            assert not re.search(r'\bresp\.|primaryAdapter\(|paginate\(',text)
            fields={f['name']:f for f in types['DefinedStringRecord']['fields']}
            for field in op['response']['fields']:
                if field['name']=='strings':
                    field['semantics']='always empty vector on loaded success; ignores ranges/page fields, no string discovery/database/scanner; facade returns empty dense array, no discovery iterator'
                else:
                    assert field['model']=='DefinedStringRecord'
                    field['semantics']='unreachable nested schema: strings vector never populated; model initializer '+fields[field['name']]['native_default']+' is not an observed string field; no encoding/length/address inference from constant-empty success'
        elif name=='ListDataItems':
            assert 'rec.value_repr' not in text
            assert 'resp.data_items.push_back(std::move(rec))' in text
            for field in op['response']['fields']:
                if field['name']=='value_repr':
                    assert next(f for f in types['DataItemRecord']['fields'] if f['name']=='value_repr')['native_default']=='empty'
                    field['semantics']='never assigned in wrapper; empty string initializer, not decoded memory/data rendering'
        else:
            # Aggregate initialization must not be confused with default-only fields.
            entries=re.findall(r'\{"(\w+)",\s*"(\w+)",\s*(.*?)\}',text,re.S)
            assert [e[0] for e in entries]==['health','session','decompiler','functions','symbols','types','signatures','memory','listing','xrefs']
            assert [e[1] for e in entries]==['supported']*9+['partial']
            assert 'pool_->size() > 1' in text
            assert 'std::to_string(pool_->size())' in text and ': "supported"' in text
            assert set(f['name'] for f in types['Capability']['fields'])=={'id','status','note'}
            semantics={
                'id':'literal subsystem ID in fixed health/session/decompiler/functions/symbols/types/signatures/memory/listing/xrefs vector order, no pagination or discovered operation IDs',
                'status':'literal supported for nine subsystem rows and partial for xrefs; coarse native claim, not per-operation support or fixture/runtime qualification (strings remain constant-empty)',
                'note':'literal subsystem note (health/session empty) except decompiler note supported at size<=1, parallel (N engines) at size>1; pool_size=1 binding policy still required; text is not machine-authoritative completeness/ordering proof',
            }
            for field in op['response']['fields']:field['semantics']=semantics[field['name']]
            op['capability_entries']=[{'id':e[0],'status':e[1],'note_expression':' '.join(e[2].split())} for e in entries]
        op['special_result_review']={'path':LOCAL,'line':source.count('\n',0,start)+1,'body_sha256':hashlib.sha256(text.encode()).hexdigest(),'qualification':'source-only, positive/negative runtime slots unqualified'}
    return operations
