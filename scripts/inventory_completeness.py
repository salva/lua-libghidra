"""Fail-closed cross-ledger checks, separate from source generation equality."""
import re


def validate(data):
    ops=data['operations']
    names=[o['name'] for o in ops]
    assert len(names)==len(set(names)), 'duplicate operation'
    included=[o for o in ops if o['tier']!='excluded']
    excluded=[o for o in ops if o['tier']=='excluded']
    assert len(included)==70 and len(excluded)==40
    def expand(native, prefix='', trail=()):
        base=re.sub(r'\bconst\b|&','',native).strip()
        while base.startswith(('std::optional<','std::vector<')):
            base=base[base.index('<')+1:-1]
        if base not in data['types']: return []
        assert base not in trail
        result=[]
        for f in data['types'][base]['fields']:
            path=prefix+f['name']
            result.append((path,f['native_type'],f['lua']))
            result+=expand(f['native_type'],path+'.',trail+(base,))
        return result
    direct=0; nested=0; response=0
    for op in ops:
        expected=expand(op['response']['native_type'])
        actual=[(f['path'],f['native_type'],f['lua']) for f in op['response']['fields']]
        assert actual==expected, ('response expansion',op['name'])
        for arg in op['request']:
            expected=expand(arg['native_type'])
            actual=[(f['path'],f['native_type'],f['lua']) for f in arg['nested_fields']]
            assert actual==expected, ('request expansion',op['name'],arg['name'])
        if op in excluded:
            assert op['surface_contract']['lowlevel'] is None and op['surface_contract']['facade'] is None
            continue
        assert op['implementation'] and op['program_state'] and op['dispatch'] and op['generation']
        for arg in op['request']:
            if not arg['nested_fields']:
                direct+=1
                assert arg.get('direct_argument_review') and arg.get('semantics'), (op['name'],arg['name'])
            nested+=len(arg['nested_fields'])
        response+=len(op['response']['fields'])
        for field in op['response']['fields']:
            assert field['semantics'] and field['semantics']!='native field preserved; no truthiness substitution'
        for slot in ('positive','negative'):
            assert op['evidence'][slot]['status']=='unqualified'
            assert op['evidence'][slot]['fixture'] is None and op['evidence'][slot]['command'] is None
    assert direct==156 and nested==20
    audit=data['request_audit']
    assert not audit['direct_argument_review_missing']
    assert not data['semantic_audit']['response_field_semantics_unreviewed']
    assert not data['semantic_audit']['wrapper_transition_review_missing']
    assert len(data['lifecycle']['factory_fields'])==4
    py=data['python_reconciliation']['methods']
    assert len(py)==27 and len({r['method'] for r in py})==27
    local=[r for r in data['python'] if r.get('file')=='python/src/libghidra/local.py' and r.get('method') and not r['method'].startswith('_')]
    assert {r['method'] for r in local}=={r['method'] for r in py}
    for row in py:
        op=next(o for o in included if o['name']==row['native_operation'])
        assert op['lowlevel']==row['method']
        assert row['wrapper_contract'] and row['native_dispatch_expression'] and row['binding_return_expressions']
    return {'included_operations':len(included),'excluded_operations':len(excluded),
            'direct_request_paths':direct,'nested_request_paths':nested,'expanded_response_paths':response,
            'python_local_methods':len(py),'factory_fields':4,
            'qualification':'cross-ledger source accounting only; runtime fixtures and iterator qualification remain unqualified'}
