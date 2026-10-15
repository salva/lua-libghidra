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
    def statements(node):
        return [ast.dump(x,include_attributes=False) for x in node.body
                if not (isinstance(x,ast.Expr) and isinstance(x.value,ast.Constant) and isinstance(x.value.value,str))]
    def expected_statements(text):
        return statements(ast.parse(text))
    page_models={
        'list_functions':('ListFunctionsResponse','functions','function'),
        'list_leaf_functions':('ListFunctionsResponse','functions','function'),
        'list_basic_blocks':('ListBasicBlocksResponse','blocks','basic_block'),
        'list_cfg_edges':('ListCFGEdgesResponse','edges','cfg_edge'),
        'list_decompilations':('ListDecompilationsResponse','decompilations','decompilation'),
        'list_symbols':('ListSymbolsResponse','symbols','symbol'),
        'list_memory_blocks':('ListMemoryBlocksResponse','blocks','memory_block'),
        'list_instructions':('ListInstructionsResponse','instructions','instruction'),
        'list_defined_strings':('ListDefinedStringsResponse','strings','defined_string'),
        'list_xrefs':('ListXrefsResponse','xrefs','xref'),
        'list_types':('ListTypesResponse','types','type'),
        'list_type_members':('ListTypeMembersResponse','members','type_member')}
    wrapper_contracts={}
    for name,node in methods.items():
        args=', '.join(a.arg for a in node.args.args if a.arg!='self')
        call='self._call(self._client.'+name+(', '+args if args else '')+')'
        if name in page_models:
            model,key,convert=page_models[name]
            expected='items = '+call+'\nreturn '+model+'('+key+'=[_to_'+convert+'(d) for d in items])'
        elif name in lookup:
            key=lookup[name]
            if name=='get_type':expected='d = '+call+'\nreturn _to_type(d) if d is not None else None'
            else:
                variable={'function':'func','decompilation':'dec','symbol':'sym','instruction':'insn'}[key]
                model={'function':'GetFunctionResponse','decompilation':'GetDecompilationResponse','symbol':'GetSymbolResponse','instruction':'GetInstructionResponse'}[key]
                expected='d = '+call+'\n'+variable+' = _to_'+key+'(d) if d is not None else None\nreturn '+model+'('+key+'='+variable+')'
        elif name in {'close_program','save_program','discard_program'}:expected='return '+call
        elif name=='get_revision':expected='rev = '+call+'\nreturn RevisionResponse(modification_number=rev)'
        elif name=='read_bytes':expected='data = '+call+'\nreturn ReadBytesResponse(data=data)'
        elif name=='get_status':expected='d = '+call+'\nreturn HealthStatus(**d)'
        elif name=='get_capabilities':expected='items = '+call+'\nreturn [Capability(**d) for d in items]'
        elif name in {'rename_function','rename_symbol'}:
            model='RenameFunctionResponse' if name=='rename_function' else 'RenameSymbolResponse'
            expected='d = '+call+'\nreturn '+model+'(**d)'
        elif name=='open_program':
            expected='if isinstance(request, str):\n    request = OpenProgramRequest(program_path=request)\nif self._auto_detect and request.program_path and not request.language_id:\n    detected = detect(request.program_path)\n    request.language_id = detected.language_id\n    if not request.compiler_spec_id:\n        request.compiler_spec_id = detected.compiler_spec_id\nd = self._call(self._client.open_program, program_path=request.program_path, read_only=request.read_only, project_path=request.project_path, project_name=request.project_name, language_id=request.language_id, compiler_spec_id=request.compiler_spec_id, format=request.format, base_address=request.base_address)\nreturn OpenProgramResponse(**d)'
        else:raise AssertionError(('unreviewed wrapper',name))
        assert statements(node)==expected_statements(expected),('Python wrapper',name)
        wrapper_contracts[name]={'statements':expected.splitlines(),'status':'exact AST reconstruction/dispatch/control flow reviewed; runtime unqualified'}
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
        # Match every native lambda return expression, not a field token that
        # may occur only in a guard or an unrelated statement.
        compact=lambda value: re.sub(r'\s+','',value)
        actual_returns=re.findall(r'\breturn\s+([^;]+);',text)
        call=re.search(r'self\.'+op['name']+r'\([^;]*?\)',text)
        assert call, name
        if name in lookup:
            expected_returns=['to_dict(resp.'+extraction+'.value())','nb::none()']
        elif name in flags:
            if name=='read_bytes':
                expected_returns=['nb::bytes(reinterpret_cast<const char*>(resp.data.data()), resp.data.size())']
            elif name=='close_program': expected_returns=['resp.closed']
            else: expected_returns=['unwrap('+call[0]+').'+extraction]
        elif name in pages:
            if name=='list_decompilations':
                assert 'for (const auto& d : resp.decompilations) result.append(to_dict(d));' in text
                expected_returns=['result']
            elif 'auto resp =' in text: expected_returns=['to_list(resp.'+extraction+')']
            else: expected_returns=['to_list(unwrap('+call[0]+').'+extraction+')']
        elif name in {'open_program','rename_function','rename_symbol'}:
            assignments=dict(re.findall(r'd\["(\w+)"\]\s*=\s*([^;]+);',text))
            expected_keys={'program_name','language_id','compiler_spec','image_base'} if name=='open_program' else {'renamed','name'}
            assert set(assignments)==expected_keys
            assert all(expr.strip()=='resp.'+key for key,expr in assignments.items())
            expected_returns=['d']
        elif name=='get_status': expected_returns=['to_dict(unwrap(self.GetStatus()))']
        elif name=='get_capabilities': expected_returns=['to_list(unwrap(self.GetCapabilities()))']
        else: raise AssertionError(('unreviewed extraction',name))
        assert list(map(compact,actual_returns))==list(map(compact,expected_returns)), (name,actual_returns,expected_returns)
        direct_fields = {f['name'] for f in types.get(op['response']['native_type'],{}).get('fields',[])}
        omitted=[]
        if name=='open_program':
            exported=set(re.findall(r'd\["(\w+)"\]\s*=',text))
            omitted=sorted(direct_fields-exported)
        defaults={a.arg:ast.unparse(v) for a,v in zip(n.args.args[-len(n.args.defaults):],n.args.defaults)} if n.args.defaults else {}
        record={'method':name,'native_operation':op['name'],'source':{'path':LOCALPY,'line':n.lineno},'binding_extraction':extraction,'binding_return_expressions':actual_returns,'wrapper_contract':wrapper_contracts[name],'python_return_expressions':[ast.unparse(x.value) for x in ast.walk(n) if isinstance(x,ast.Return) and x.value], 'native_response_fields_not_exported':omitted,'python_defaults':defaults,'binding_body_sha256':hashlib.sha256(text.encode()).hexdigest(),'qualification':'source reviewed; runtime unqualified'}
        if name in ['close_program','save_program','discard_program']:
            record['fidelity']='Python returns scalar bool, unlike faithful Lua response envelope; no extra native fields currently present'
        if name=='get_type': record['fidelity']='Python returns bare TypeRecord/None, not GetTypeResponse; Lua lowlevel must preserve envelope'
        if name=='open_program': record['fidelity']='Python native binding exports only program_name/language_id/compiler_spec/image_base; Python model defaults must not be mistaken for native metadata'
        if name in pages: record['fidelity']='Python defaults limit=0 (native unbounded), unlike binding positive bounded limit=100; no such unbounded request on Lua surfaces'
        op['python_reconciliation']=record
        audits.append(record)
    # Independently specified AST shapes for dictionary reconstruction. Match
    # statements as well as returns so wrong nested defaults cannot hide in hashes.
    helper_models={'function':'FunctionRecord','symbol':'SymbolRecord',
        'instruction':'InstructionRecord','memory_block':'MemoryBlockRecord',
        'xref':'XrefRecord','type':'TypeRecord','type_member':'TypeMemberRecord',
        'basic_block':'BasicBlockRecord','cfg_edge':'CFGEdgeRecord',
        'defined_string':'DefinedStringRecord'}
    expected_helpers={ '_to_'+key:'return '+model+'(**d)' for key,model in helper_models.items() }
    expected_helpers.update({
        '_to_decompile_local':'d["kind"] = DecompileLocalKind(d.get("kind", 0))\nreturn DecompileLocalRecord(**d)',
        '_to_decompile_token':'d["kind"] = DecompileTokenKind(d.get("kind", 0))\nreturn DecompileTokenRecord(**d)',
        '_to_decompilation':'d["locals"] = [_to_decompile_local(l) for l in d.get("locals", [])]\nd["tokens"] = [_to_decompile_token(t) for t in d.get("tokens", [])]\nreturn DecompilationRecord(**d)',
    })
    found={n.name:n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name.startswith('_to_')}
    assert set(found)==set(expected_helpers)
    for name,expected in expected_helpers.items():
        assert [ast.dump(n,include_attributes=False) for n in found[name].body]==[ast.dump(n,include_attributes=False) for n in ast.parse(expected).body],name
    # Local Python ownership and error transformation are not service methods.
    private={n.name:n for n in client.body if isinstance(n,ast.FunctionDef) and n.name.startswith('_')}
    private_expected={
        '__init__': '_require_native()\nopts = options or LocalClientOptions()\nself._opts = opts\nself._auto_detect = opts.default_arch in ("", "auto")\nself._client = _native.create_local_client(ghidra_root=opts.ghidra_root, state_path=opts.state_path, default_arch="" if self._auto_detect else opts.default_arch, pool_size=opts.pool_size)',
        '_call': 'try:\n    return method(*args, **kwargs)\nexcept ValueError as e:\n    msg = str(e)\n    if ":" in msg:\n        code_str, _, message = msg.partition(": ")\n        code = ErrorCode.from_rpc_code(code_str)\n    else:\n        code = ErrorCode.API_ERROR\n        message = msg\n    raise GhidraError(code, message)'}
    assert set(private)==set(private_expected)
    for name,node in private.items():
        assert statements(node)==expected_statements(private_expected[name]),name
    other_helpers={n.name:n for n in tree.body if isinstance(n,ast.FunctionDef) and not n.name.startswith('_to_')}
    assert set(other_helpers)=={'detect_arch','_require_native'}
    detect_expected='try:\n    return detect(filepath).language_id\nexcept (OSError, UnsupportedFormatError):\n    return None\nreturn None'
    assert statements(other_helpers['detect_arch'])==expected_statements(detect_expected)
    require=other_helpers['_require_native']
    assert len(require.body)==1 and isinstance(require.body[0],ast.If)
    guard=require.body[0]
    assert ast.unparse(guard.test)=='_native is None' and not guard.orelse
    assert len(guard.body)==1 and isinstance(guard.body[0],ast.Raise)
    exc=guard.body[0].exc
    assert isinstance(exc,ast.Call) and ast.unparse(exc.func)=='ImportError' and len(exc.args)==1 and not exc.keywords
    assert isinstance(exc.args[0],ast.Constant) and isinstance(exc.args[0].value,str)
    private_audit={name:{'statements':text.splitlines(),'qualification':'source only; runtime unqualified'} for name,text in private_expected.items()}
    helpers=[]
    for n in tree.body:
        if isinstance(n,ast.FunctionDef):
            helpers.append({'name':n.name,'path':LOCALPY,'line':n.lineno,'calls':sorted(set(ast.unparse(x.func) for x in ast.walk(n) if isinstance(x,ast.Call))), 'body_sha256':hashlib.sha256(ast.dump(n,include_attributes=False).encode()).hexdigest(), 'reviewed_statements':[ast.unparse(x) for x in n.body] if n.name in expected_helpers else None, 'review_status':'exact reconstruction AST reconciled; runtime unqualified' if n.name in expected_helpers else 'control flow reviewed; diagnostic text not a behavior gate; runtime unqualified'})
    return {'methods':audits,'record_converters':converters,'conversion_helpers':helpers,'private_lifecycle_and_errors':private_audit,'non_converter_helpers':{'detect_arch':'detect language ID; OSError/UnsupportedFormatError -> None; other exceptions propagate','_require_native':'only _native is None raises ImportError with diagnostic string; otherwise returns None'},
            'errors':'nanobind unwrap throws ValueError(code + colon-space + message); Python _call catches ValueError and maps ErrorCode; unknown-code preservation not established by Python mapping; Lua must preserve upstream code/message',
            'architecture':'Python open may mutate request language/compiler from format detection; native echo is not authoritative detection; use identical explicit hints for oracle',
            'nested_enums':'Python _to_decompilation converts locals/tokens and their enum kinds via Python IntEnum constructors; unknown values can raise ValueError unlike Lua numeric unknown-value preservation',
            'remaining':'record converter keys AND exact value expressions reconciled; omitted fields explicit, not silently supplied as native evidence; Python reconstruction/default/enum runtime behavior remains unqualified'}
