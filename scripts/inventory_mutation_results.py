"""Reviewed mutation result fields: request echoes are not canonical readback."""
import hashlib
import re
from inventory_semantics import LOCAL, body


def review_mutation_results(u, operations, types):
    source=(u/LOCAL).read_text()
    # Exact assignment expressions are reviewed per operation; the success/error
    # branch ordering is checked separately, not inferred from response defaults.
    contracts={
        'RenameFunction': {'renamed':'ok','name':'new_name'},
        'RenameSymbol': {'renamed':'ok','name':'new_name'},
        'RenameDataItem': {'updated':'ok','name':'new_name'},
        'RenameType': {'updated':'ok','name':'new_name'},
        'RenameFunctionParameter': {'updated':'ok','name':'new_name'},
        'SetFunctionParameterType': {'updated':'ok','data_type':'new_type'},
        'SetFunctionSignature': {'updated':'ok','prototype':'prototype'},
        'ApplyDataType': {'updated':'ok','data_type':'data_type'},
        'RenameFunctionLocal': {'updated':'true','local_id':'local_id','name':'new_name'},
        'SetFunctionLocalType': {'updated':'true','local_id':'local_id','data_type':'new_type'},
        'DeleteSymbol': {'deleted':'ok','deleted_count':'ok ? 1 : 0'},
        'WriteBytes': {'bytes_written':'static_cast<std::uint32_t>(data.size())'},
        'PatchBytesBatch': {'patch_count':'static_cast<std::uint32_t>(patches.size())','bytes_written':'total_bytes'},
    }
    acknowledged_updates=['CreateType','CreateTypeAlias','CreateTypeEnum','AddTypeMember',
        'AddTypeEnumMember','RenameTypeMember','SetTypeMemberType',
        'RenameTypeEnumMember','SetTypeEnumMemberValue','SetTypeAliasTarget']
    acknowledged_deletes=['DeleteType','DeleteTypeAlias','DeleteTypeMember',
        'DeleteTypeEnumMember','DeleteComment','DeleteDataItem']
    side_maps=['SetComment','SetTypeMemberComment','SetTypeEnumMemberComment']
    for name in acknowledged_updates: contracts[name]={'updated':'ok'}
    for name in acknowledged_deletes: contracts[name]={'deleted':'ok'}
    for name in side_maps: contracts[name]={'updated':'true'}
    for op in operations:
        name=op['name']
        if name not in contracts:continue
        assignments=contracts[name]
        start,text=body(source,' '+name+'(')
        actual={m[1]:m[2].strip() for m in re.finditer(r'\bresp\.(\w+)\s*=\s*([^;]+);',text)}
        assert actual==assignments,(name,actual)
        declared={f['name']:f for f in types[op['response']['native_type']]['fields']}
        defaults={'function_name'} if name=='SetFunctionSignature' else set()
        assert set(assignments)|defaults==set(declared),name
        returned='return StatusOr<'+op['response']['native_type']+'>::FromValue'
        assert returned in text
        if 'ok' in assignments.values():
            assert 'if (!ok)' in text
            assert text.index('if (!ok)')<text.index(returned)
            branch=text[text.index('if (!ok)'):text.index(returned)]
            assert '::FromError(' in branch
        if name in ['RenameFunctionLocal','SetFunctionLocalType']:
            assert text.index('switch (')<text.index('revision_++')<text.index('resp.updated = true')
            assert '::FromError(' in text[:text.index('revision_++')]
        if name in side_maps:
            assert 'if (!ok)' not in text and 'return true;' in text
            assert text.index('revision_++')<text.index('resp.updated = true')
            assert 'ordinal >= ' not in text
        for field in op['response']['fields']:
            key=field['name']
            expression=assignments.get(key)
            if key in defaults:
                field['semantics']='never assigned by '+name+'; retain model initializer '+declared[key]['native_default']+'; not looked up from program or parsed from supplied prototype'
            elif name in side_maps:
                field['semantics']='literal true after side-map setter dispatch with unconditional true lambda and ignored aggregate status; empty text stored, no existence/kind/address/ordinal validation; native revision increments even if replacing same value; acknowledgement is not proof of existing member edit or native project comment persistence'
            elif key in ['updated','renamed','deleted']:
                field['semantics']='successful response only: true after mutation status accepted; failed native status returns StatusOr error, NOT successful false response; flag is native acknowledgement, not independent readback/rollback/atomicity proof'
            elif key=='deleted_count':
                field['semantics']='successful DeleteSymbol returns exactly 1; constructed zero belongs only to discarded error response on failure; address-only deletion, ignored name_filter is not a matching guard'
            elif key=='local_id':
                field['semantics']='echo of supplied local_id unchanged; not canonical resolved ID and not independently looked up after edit (native resolver may accept tolerant aliases/name)'
            elif name=='WriteBytes':
                field['semantics']='input data.size cast uint32; not observed bytes persisted or verified readback; empty input yields zero with revision increment; exact count requires input<=UINT32_MAX'
            elif name=='PatchBytesBatch' and key=='patch_count':
                field['semantics']='input patches.size cast uint32 after input-order dispatch; not independently confirmed successful patch count; empty vector yields zero; exact count requires vector length<=UINT32_MAX'
            elif name=='PatchBytesBatch':
                field['semantics']='uint32 sum of each input patch.data.size cast uint32; modulo on overflow, not observed persisted bytes; exact fidelity requires each and cumulative length<=UINT32_MAX; failures may leave partial writes'
            else:
                field['semantics']='echo of request '+expression+' unchanged on native success; not canonicalized type/name/prototype or post-edit readback; empty input preserved if native operation accepts it'
            field['producer_review']={'path':LOCAL,'line':source.count('\n',0,start)+1,'method':name}
        op['mutation_result_review']={'path':LOCAL,'body_sha256':hashlib.sha256(text.encode()).hexdigest(),
            'assignments':assignments,'qualification':'source response/extraction branches only; runtime positive/negative and atomicity unqualified'}
    return operations
