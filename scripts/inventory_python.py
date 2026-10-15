"""Reconcile Python local extraction independently against native response models."""
import ast
import hashlib
import re
from inventory_semantics import body

BINDINGS = 'cpp/bindings/python_bindings.cpp'
LOCALPY = 'python/src/libghidra/local.py'


def reconcile_python(u, operations, types):
    source = (u/BINDINGS).read_text()
    python = (u/LOCALPY).read_text()
    tree = ast.parse(python)
    client = next(n for n in tree.body if isinstance(n, ast.ClassDef) and n.name == 'LocalClient')
    methods = {n.name: n for n in client.body if isinstance(n, ast.FunctionDef) and not n.name.startswith('_')}
    # Enumerate actual nanobind exports; do not infer coverage from Python names.
    exports = {}
    for m in re.finditer(r'\.def\("(\w+)"\s*,\s*\[\]', source):
        _, text = body(source, m[0])
        exports[m[1]] = text
    factory = exports.pop('create_local_client')
    assert 'CreateLocalClient' in factory
    assert set(methods) == set(exports), (set(methods)-set(exports), set(exports)-set(methods))
    converters = {}
    for m in re.finditer(r'static nb::dict to_dict\(const (\w+)& r\)', source):
        start, text = body(source, m[0])
        assigned = sorted(set(re.findall(r'd\["(\w+)"\]\s*=', text)))
        assert m[1] in types
        native = {f['name'] for f in types[m[1]]['fields']}
        # Reconcile value provenance, not only dictionary-key presence. A key
        # copied from a different member was previously invisible to this audit.
        expressions=dict(re.findall(r'd\["(\w+)"\]\s*=\s*([^;]+);',text))
        assert len(expressions)==len(assigned)
        reviewed={}
        containers={('DecompilationRecord','locals'):('locals_list','locals','l'),
                    ('DecompilationRecord','tokens'):('tokens_list','tokens','t'),
                    ('HealthStatus','warnings'):('warns','warnings','w')}
        for key,expr in expressions.items():
            expr=expr.strip()
            assert key in native, (m[1],key)
            container=containers.get((m[1],key))
            if container:
                target,member,item=container
                assert expr==target
                convert='to_dict('+item+')' if member!='warnings' else item
                assert 'for (const auto& '+item+' : r.'+member+') '+target+'.append('+convert+');' in text
                kind='ordered vector traversal; nested to_dict' if member!='warnings' else 'ordered text vector traversal'
            elif key=='kind' and m[1] in {'DecompileLocalRecord','DecompileTokenRecord'}:
                assert expr=='static_cast<int>(r.kind)'
                kind='enum to signed int; Python IntEnum construction may reject unknown values'
            else:
                assert expr=='r.'+key, (m[1],key,expr)
                kind='same-name native member copied without truthiness/default substitution'
            reviewed[key]={'expression':expr,'semantics':kind,
                           'qualification':'source only; scalar/text conversion fidelity runtime unqualified'}
        converters[m[1]] = {'path':BINDINGS,'line':source.count('\n',0,start)+1,
                              'exported_fields':assigned,'field_expressions':reviewed,'omitted_native_fields':sorted(native-set(assigned)),
                              'unknown_exported_fields':sorted(set(assigned)-native),
                              'body_sha256':hashlib.sha256(text.encode()).hexdigest()}
    audits=[]
    lookup={'get_function':'function', 'get_decompilation':'decompilation', 'get_symbol':'symbol', 'get_instruction':'instruction', 'get_type':'type'}
    flags={'close_program':'closed','save_program':'saved','discard_program':'discarded','get_revision':'modification_number','read_bytes':'data'}
    pages={'list_functions':'functions','list_leaf_functions':'functions','list_basic_blocks':'blocks','list_cfg_edges':'edges','list_decompilations':'decompilations','list_symbols':'symbols','list_memory_blocks':'blocks','list_instructions':'instructions','list_defined_strings':'strings','list_xrefs':'xrefs','list_types':'types','list_type_members':'members'}
    for name,n in methods.items():
        op = next(o for o in operations if o['lowlevel']==name)
        text=exports[name]
        native_calls=re.findall(r'self\.(\w+)\(', text)
        assert native_calls == [op['name']], (name,native_calls)
        extraction=lookup.get(name,flags.get(name,pages.get(name,'complete dict/array')))
        if name in lookup:
            assert 'resp.'+extraction+'.has_value()' in text and 'nb::none()' in text
        if name in flags:
            assert '.'+extraction in text
        direct_fields = {f['name'] for f in types.get(op['response']['native_type'],{}).get('fields',[])}
        omitted=[]
        if name=='open_program':
            exported=set(re.findall(r'd\["(\w+)"\]\s*=',text))
            omitted=sorted(direct_fields-exported)
        defaults={a.arg:ast.unparse(v) for a,v in zip(n.args.args[-len(n.args.defaults):],n.args.defaults)} if n.args.defaults else {}
        record={'method':name,'native_operation':op['name'],'source':{'path':LOCALPY,'line':n.lineno},'binding_extraction':extraction,'python_return_expressions':[ast.unparse(x.value) for x in ast.walk(n) if isinstance(x,ast.Return) and x.value], 'native_response_fields_not_exported':omitted,'python_defaults':defaults,'binding_body_sha256':hashlib.sha256(text.encode()).hexdigest(),'qualification':'source reviewed; runtime unqualified'}
        if name in ['close_program','save_program','discard_program']:
            record['fidelity']='Python returns scalar bool, unlike faithful Lua response envelope; no extra native fields currently present'
        if name=='get_type': record['fidelity']='Python returns bare TypeRecord/None, not GetTypeResponse; Lua lowlevel must preserve envelope'
        if name=='open_program': record['fidelity']='Python native binding exports only program_name/language_id/compiler_spec/image_base; Python model defaults must not be mistaken for native metadata'
        if name in pages: record['fidelity']='Python defaults limit=0 (native unbounded), unlike binding positive bounded limit=100; no such unbounded request on Lua surfaces'
        op['python_reconciliation']=record
        audits.append(record)
    helpers=[]
    for n in tree.body:
        if isinstance(n,ast.FunctionDef):
            helpers.append({'name':n.name,'path':LOCALPY,'line':n.lineno,'calls':sorted(set(ast.unparse(x.func) for x in ast.walk(n) if isinstance(x,ast.Call))), 'body_sha256':hashlib.sha256(ast.dump(n,include_attributes=False).encode()).hexdigest()})
    return {'methods':audits,'record_converters':converters,'conversion_helpers':helpers,
            'errors':'nanobind unwrap throws ValueError(code + colon-space + message); Python _call catches ValueError and maps ErrorCode; unknown-code preservation not established by Python mapping; Lua must preserve upstream code/message',
            'architecture':'Python open may mutate request language/compiler from format detection; native echo is not authoritative detection; use identical explicit hints for oracle',
            'nested_enums':'Python _to_decompilation converts locals/tokens and their enum kinds via Python IntEnum constructors; unknown values can raise ValueError unlike Lua numeric unknown-value preservation',
            'remaining':'record converter keys AND exact value expressions reconciled; omitted fields explicit, not silently supplied as native evidence; Python reconstruction/default/enum runtime behavior remains unqualified'}
