"""Normative Lua surface disposition, not implemented adapters."""

def surfaces(operations):
    lookups={'GetFunction':'function','GetDecompilation':'decompilation','GetInstruction':'instruction','GetSymbol':'symbol','GetType':'type','GetFunctionSignature':'signature','ReadBytes':'data'}
    grammar={'GetFunction':'get_function(address)','GetInstruction':'get_instruction(address)','GetSymbol':'get_symbol(address)','GetType':'get_type(path)','GetFunctionSignature':'get_function_signature(address)','ReadBytes':'read_bytes(address, size)','GetDecompilation':'get_decompilation(address, options={})','CloseProgram':'close_program{policy="save"|"discard"}','OpenProgram':'open_program(program_options)'}
    # SPEC §2 first-slice table is the only approved positional/options grammar.
    # COVERAGE public-layer mapping approves dispositions, not additional syntax.
    approved={
        'GetStatus':'get_status()', 'GetCapabilities':'get_capabilities()',
        'OpenProgram':'open_program(program_options)',
        'CloseProgram':'close_program{policy="save"|"discard"}',
        'GetFunction':'get_function(address)', 'GetInstruction':'get_instruction(address)',
        'ReadBytes':'read_bytes(address, size)',
        'GetDecompilation':'get_decompilation(address, options={})',
        'ListFunctions':'list_functions(options={})',
        'ListInstructions':'list_instructions(options={})',
    }
    for op in operations:
        if not op['implementation']:
            op['surface_contract']={'lowlevel':None,'facade':None,'disposition':'excluded: inherited NOT_SUPPORTED; no Lua adapter promised'}
            continue
        name=op['name']; keys=[r['name'] for r in op['request']]
        low=grammar.get(name,op['lowlevel']+'('+(', '.join(keys))+')')
        if op['pagination']: low=op['lowlevel']+'(options={})'
        if name in approved: low=approved[name]
        facade_kind='native escape hatch'
        if name=='OpenProgram': facade_kind='module open{client={}, program=...}; returns session,nil,historical_open_response'
        elif name in lookups: facade_kind='direct extraction'
        elif op['tier']=='slice' or (op['tier']=='core' and name!='DiscardProgram'): facade_kind='complete response convenience/page'
        # Full specialist pages do not become conveniences merely by being lists.
        if name=='ListFunctionSignatures': facade_kind='complete response page; no iterator'
        if name=='ListDefinedStrings': facade_kind='native escape hatch compatibility page; no discovery iterator'
        field=lookups.get(name)
        op['surface_contract']={
            'lowlevel':{'name':op['lowlevel'],'call':low,'return':'complete detached native response or nil,error','native_request_keys':keys},
            'facade':{'name':op['lowlevel'] if not facade_kind.startswith('native escape') else None,'disposition':facade_kind,'extraction':field if facade_kind=='direct extraction' else None,'return':'value,nil,response; optional absent -> nil,NOT_FOUND,response; native error -> nil,error' if facade_kind=='direct extraction' else 'complete response/error via convenience or native() as disposed'},
            'implementation_status':'planned M0 contract only; not runtime-qualified',
            'iterator':'not enabled; source identity/order alone is not runtime qualification',
        }
        # Keep proposed presentation separate from approved public syntax. A
        # complete field inventory is not permission to implement a new grammar.
        status='approved first-slice' if name in approved else 'proposed; not approved for adapter implementation'
        lowlevel=op['surface_contract']['lowlevel']
        lowlevel['grammar']={
            'status':status,
            'authority':'docs/SPEC.md §2 First-slice call grammar' if name in approved else 'inventory presentation only; docs/COVERAGE.md approves tier/disposition, not this syntax',
            'approved_call':approved.get(name),
            'proposed_call':None if name in approved else low,
            'native_argument_order':keys,
            'unknown_keys':'reject before dispatch; validation-only rejection does not invalidate generation',
            'default_rule':'only explicit binding defaults; model initializer is not proof of request optionality; preserve false, zero and empty',
        }
        # Legacy call is display-only for proposed rows; consumers must inspect
        # grammar.status / approved_call before treating it as a public contract.
        lowlevel['call_status']=status
        op['surface_contract']['facade']['grammar_status']=('native() uses lowlevel grammar; no convenience promised' if facade_kind.startswith('native escape') else status)
        if name=='OpenProgram':
            op['surface_contract']['facade']['grammar_status']='approved first-slice'
            op['surface_contract']['facade']['approved_call']='open{client={}, program=program_options}'
        if name=='ReadBytes':
            op['surface_contract']['lowlevel']['argument_alias']='Lua size corresponds to native length; 0..INT32_MAX before dispatch/allocation'
        if name in ['GetDecompilation','ListDecompilations']:
            op['surface_contract']['facade']['timeout_policy']='reject explicit timeout key; native default ignored; no deadline promise'
        if name=='OpenProgram':
            op['surface_contract']['facade']['rejected_keys']=['project_name','read_only']
        if name=='CloseProgram':
            op['surface_contract']['facade']['save_policy']='reject empty configured state_path with binding NO_STATE_PATH before dispatch; no implicit save'
        for request in op['request']:
            request['ignored']=request['name'] in op['ignored_fields'] or request['name']=='timeout_ms'
            for nested in request.get('nested_fields',[]):
                nested['ignored']=name=='OpenProgram' and nested['name'] in ['project_name','read_only']
        if name=='DeleteSymbol':
            # Native signature calls it name_filter; requirements describe semantic name.
            op['ignored_fields']=['name_filter']
            next(r for r in op['request'] if r['name']=='name_filter')['ignored']=True
            op['limitations'].append('native argument name_filter (semantic name) ignored: deletion by address only, never a name guard')
    return operations


def surface_audit(operations):
    included=[o for o in operations if o['implementation']]
    excluded=[o for o in operations if not o['implementation']]
    assert all(o['surface_contract']['lowlevel'] is None and o['surface_contract']['facade'] is None for o in excluded)
    proposed=[]
    for op in included:
        surface=op['surface_contract']; grammar=surface['lowlevel']['grammar']
        assert grammar['native_argument_order']==[a['name'] for a in op['request']]
        assert bool(grammar['approved_call']) != bool(grammar['proposed_call'])
        if grammar['proposed_call']:
            proposed.append({'operation':op['name'],'proposal':grammar['proposed_call'],
                             'facade_disposition':surface['facade']['disposition'],
                             'reason':'syntax requires later approval; not a missing native operation or runtime qualification claim'})
    return {'included_operations':len(included),'excluded_operations':len(excluded),
            'grammar_accounted':len(included),'approved_first_slice_count':len(included)-len(proposed),
            'proposed_grammar':proposed,
            'qualification':'inventory only; proposals explicitly unresolved, no new grammar authorization'}
