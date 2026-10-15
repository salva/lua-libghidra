"""Normative Lua surface disposition, not implemented adapters."""

def surfaces(operations):
    lookups={'GetFunction':'function','GetDecompilation':'decompilation','GetInstruction':'instruction','GetSymbol':'symbol','GetType':'type','GetFunctionSignature':'signature','ReadBytes':'data'}
    grammar={'GetFunction':'get_function(address)','GetInstruction':'get_instruction(address)','GetSymbol':'get_symbol(address)','GetType':'get_type(path)','GetFunctionSignature':'get_function_signature(address)','ReadBytes':'read_bytes(address, size)','GetDecompilation':'get_decompilation(address, options={})','CloseProgram':'close_program{policy="save"|"discard"}','OpenProgram':'open_program(program_options)'}
    for op in operations:
        if not op['implementation']:
            op['surface_contract']={'lowlevel':None,'facade':None,'disposition':'excluded: inherited NOT_SUPPORTED; no Lua adapter promised'}
            continue
        name=op['name']; keys=[r['name'] for r in op['request']]
        low=grammar.get(name,op['lowlevel']+'('+(', '.join(keys))+')')
        if op['pagination']: low=op['lowlevel']+'(options={})'
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
