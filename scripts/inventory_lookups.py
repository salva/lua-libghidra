"""Reviewed lookup absence/error conflation, not runtime qualification."""
import hashlib
import re
from inventory_semantics import body, LOCAL, ADAPTER


def review_lookups(u, operations, types):
    local=(u/LOCAL).read_text(); adapter=(u/ADAPTER).read_text()
    methods={'GetFunction':'getFunction','GetSymbol':'getSymbol','GetType':'getType','GetInstruction':'getInstruction','GetFunctionSignature':'getFunctionSignature','ReadBytes':'readBytes'}
    for op in operations:
        name=op['name']
        if name not in methods and name not in ['GetDecompilation','RenameFunction','SetFunctionSignature','AddTypeEnumMember','ListDefinedStrings']:continue
        start,text=body(local,' '+name+'(')
        op['lookup_source_review']={'path':LOCAL,'line':local.count('\n',0,start)+1,'body_sha256':hashlib.sha256(text.encode()).hexdigest()}
        op['program_state']='loaded program and valid primary adapter required; otherwise NO_PROGRAM'
        if name in methods:
            method=methods[name]; astart,atext=body(adapter,'ArchAdapter::'+method+'(')
            assert 'catch (...)' in atext
            op['lookup_adapter_review']={'path':ADAPTER,'line':adapter.count('\n',0,astart)+1,'body_sha256':hashlib.sha256(atext.encode()).hexdigest()}
            assigned=sorted(set(re.findall(r'rec\.(\w+)\s*=',atext)))
            model={'GetFunction':'FunctionRecord','GetSymbol':'SymbolRecord','GetType':'TypeRecord','GetInstruction':'InstructionRecord','GetFunctionSignature':'FunctionSignatureRecord'}.get(name)
            if model:
                assert 'return std::nullopt' in atext
                op['state_transitions']='loaded required; adapter absence or caught/logged exception becomes successful absent optional; native does not return NOT_FOUND for absent lookup; facade synthesizes NOT_FOUND with full response'
                op['lookup_record_fields']={'model':model,'assigned':assigned,'default_only':sorted({f['name'] for f in types[model]['fields']}-set(assigned)),'qualification':'source branch accounting; model defaults are not measured metadata'}
            if name=='GetType':
                assert 'findByName(name)' in atext and 'substr' not in text
                op['limitations'].append('get_type forwards literal name unchanged to findByName; unlike member mutation, no slash normalization; generated path_name does not prove that slash path is accepted for lookup; type_id=0')
            elif name=='GetFunction':
                op['limitations'].append('queryFunction then function-symbol fallback; inclusive end=start+size-1 (zero size -> start); native unsigned end arithmetic can wrap; default-only prototype/namespace/thunk/count fields not populated by this lookup')
            elif name=='GetSymbol':
                op['limitations'].append('findAddr in default code space; address echoes request, name/full_name identical, primary=true, type function or label; symbol ID and other unassigned fields remain defaults')
            elif name=='GetInstruction':
                op['limitations'].append('decode exact requested address via printAssembly; len<=0 or exception -> absent; disassembly joins mnemonic and operand with space only when nonempty; instruction bytes and unrelated metadata default unless assigned')
            elif name=='GetFunctionSignature':
                assert 'pool_->primary().decompileAt(address);' in text
                op['limitations'].append('decompileAt invoked before extraction but return not tested; no function or caught extraction error -> absent; read dispatch can populate native analysis without revision increment')
            else:
                assert 'result.resize(length)' in atext and 'static_cast<int4>(length)' in atext
                assert atext.index('result.resize(length)') < atext.index('static_cast<int4>(length)')
                assert 'result.clear()' in atext
                op['state_transitions']='loaded required; zero length -> empty success; loader/allocation exception caught/logged in adapter -> empty data success, not native read error; no partial returned bytes on caught failure'
                op['limitations'].append('requested vector allocated before signed int4 cast; Lua must reject length>INT32_MAX before dispatch/allocation; empty data conflates zero request and caught read failure; do not synthesize native success length')
        elif name=='GetDecompilation':
            assert 'resp.decompilation = DecompilationRecord{}' in text and 'error_message = dl.error' in text
            op['state_transitions']='loaded required; dl.ok false returns present completed=false record with requested address and actual dl.error; dl.ok true returns present completed=true record with pseudocode and locals; both are StatusOr success'
            op['limitations'].append('tokens and other unassigned DecompilationRecord fields remain model defaults in this override; failure is not missing optional or nil,error; ignored timeout cannot promise cancellation')
        elif name=='ListDefinedStrings':
            assert 'resp.strings' not in text
            op['state_transitions']='loaded required; unconditional empty response success, ranges/pages ignored natively; binding still validates supplied options before dispatch; compatibility fidelity exception, no discovery iterator'
        else:
            assert 'if (ok) revision_++' in text
            op['state_transitions']='loaded required; all-slot mutation; false -> '+{'RenameFunction':'RENAME_FAILED','SetFunctionSignature':'SET_PROTOTYPE_FAILED','AddTypeEnumMember':'ADD_ENUM_MEMBER_FAILED'}[name]+'; native revision only on success; error does not imply rollback'
            if name=='AddTypeEnumMember':
                assert 'entries.push_back({name, static_cast<uint64_t>(value)})' in text
                op['limitations'].append('normalize one slash, enumerate then append signed-int64 value cast uint64 and redefine entire enum; missing/wrong-kind lookup may enumerate empty before defineEnum attempt, not early NOT_FOUND; no comment ordinal remapping')
        op['semantic_review']='lookup/wrapper branch review; runtime positive/negative fixture slots remain unqualified'
    return operations


def semantic_audit(operations):
    """Expose exact remaining review work rather than treating hashes as coverage."""
    included=[o for o in operations if o['implementation']]
    # Page review source contracts are separate from per-operation wrapper review.
    wrapper=[o['name'] for o in included if 'state_transitions' not in o]
    missing_fields=[]
    for op in included:
        for field in op['response']['fields']:
            if not field.get('semantics') or field['semantics']=='native field preserved; no truthiness substitution':
                missing_fields.append({'operation':op['name'],'path':field.get('path',field['name']),'native_type':field.get('native_type',field.get('type'))})
    return {'included_operations':len(included),'wrapper_transition_review_missing':wrapper,
            'response_field_semantics_unreviewed':missing_fields,
            'scope':'Explicit accounting audit only; empty wrapper list would not establish full nested/default/domain review or runtime qualification',
            'remaining_gates':['Audit every generic field semantic against owning adapter/default source','Finalize non-first-slice facade call grammar rather than positional proposals','Qualify runtime fixtures separately; preserve all unqualified slots']}
