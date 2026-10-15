#!/usr/bin/env python3
"""Fail-closed source inventory, not an adapter or runtime qualification tool."""
import argparse
import ast
import hashlib
import json
from pathlib import Path
import re
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from inventory_semantics import review_pages, review_aggregate_pages, review_session_records, review_open_and_creation, review_parameter_and_byte_mutations, review_member_reconstruction, review_local_and_data_edits, review_alias_symbol_comments

from inventory_python import reconcile_python
from inventory_surfaces import surfaces
from inventory_lookups import review_lookups, semantic_audit
from inventory_page_wrappers import review_page_wrappers
from inventory_record_fields import review_record_fields
from inventory_decompilation_fields import review_decompilation_fields
from inventory_graph_fields import review_graph_fields
from inventory_performance_fields import review_performance_fields
from inventory_mutation_results import review_mutation_results
from inventory_status_fields import review_status_fields
from inventory_special_results import review_special_results
from inventory_container_results import review_container_results
from inventory_request_fields import review_request_fields

PIN = 'd51ca813ae1b6b59519551a9be8c0b1ad74d862d'
ROOT = Path(__file__).resolve().parents[1]
DEFAULT = ROOT / '.cache/native-inputs' / ('libghidra-' + PIN)

def clean(s):
    # Preserve offsets/line numbers for source citations.
    return re.sub(r'/\*.*?\*/|//[^\n]*', lambda m: re.sub(r'[^\n]', ' ', m[0]), s, flags=re.S)

def norm(s):
    return ' '.join(s.split())

def split(s):
    out, start, depth = [], 0, 0
    for i, c in enumerate(s):
        depth += c in '<(['
        depth -= c in '>)]'
        if c == ',' and depth == 0:
            out.append(s[start:i].strip()); start = i + 1
    if s[start:].strip(): out.append(s[start:].strip())
    return out

def lua(t):
    t = re.sub(r'\bconst\b|&', '', t).strip()
    if t.startswith('std::optional<'): return 'optional ' + lua(t[14:-1]) + ' (absence=nil)'
    if t == 'std::vector<std::uint8_t>': return 'binary Lua string (length preserving)'
    if t.startswith('std::vector<'): return 'dense 1-based array of ' + lua(t[12:-1])
    if t == 'std::uint64_t': return 'exact UInt64'
    if t in ['std::uint32_t', 'std::int64_t', 'int', 'std::uint8_t']: return 'checked Lua integer (' + t + ')'
    if t == 'double': return 'Lua number (native double; lua_Number precision/runtime qualification required)'
    if t == 'bool': return 'boolean (preserve false)'
    if t == 'std::string': return 'Lua string (no transcoding)'
    return t + ' table/enum; resolve in types/enums'

def inventory(u):
    files = {}
    def read(p):
        s = (u / p).read_text(); files[p] = hashlib.sha256(s.encode()).hexdigest(); return s
    def cite(p, s, i): return {'path': p, 'line': s.count('\n', 0, i) + 1}
    types, enums, declarations = {}, {}, {}
    headers = sorted((u/'cpp/include/libghidra').glob('*.hpp'))
    for hp in headers:
        p = str(hp.relative_to(u)); raw = read(p); s = clean(raw)
        for m in re.finditer(r'enum class (\w+)\s*\{(.*?)\};', s, re.S):
            enums[m[1]] = {'source': cite(p, raw, m.start()), 'values': norm(m[2]), 'lua': 'documented lowercase names; unknown response values retain numeric native value'}
        # HTTP/headless option types are separately scoped; not local factory inputs.
        if hp.name not in ['http.hpp', 'headless.hpp', 'status.hpp']:
            for m in re.finditer(r'struct\s+(\w+)\s*\{(.*?)\n\};', s, re.S):
                fields = []
                for f in m[2].split(';'):
                    if not f.strip(): continue
                    fm = re.fullmatch(r'\s*([\w:<>, &]+?)\s+(\w+)(?:\s*=\s*(.*?))?\s*', f, re.S)
                    if not fm: raise ValueError('unparsed field ' + m[1] + ': ' + f)
                    t, name, default = fm.groups(); t = norm(t)
                    if default is None:
                        default = 'empty' if t.startswith(('std::string','std::vector<')) else 'absent' if t.startswith('std::optional<') else 'no explicit initializer; inspect construction'
                    fields.append({'name': name, 'native_type': t, 'lua': lua(t), 'native_default': norm(default), 'optional': t.startswith('std::optional<'), 'semantics': 'native field preserved; no truthiness substitution'})
                if m[1] in types: raise ValueError('duplicate type ' + m[1])
                types[m[1]] = {'source': cite(p, raw, m.start()), 'fields': fields}
        if hp.name not in ['api.hpp', 'http.hpp', 'headless.hpp']:
            for m in re.finditer(r'virtual\s+StatusOr<(.*?)>\s+(\w+)\((.*?)\)\s*=\s*0\s*;', s, re.S):
                if m[2] in declarations: raise ValueError('duplicate declaration ' + m[2])
                declarations[m[2]] = {'source': cite(p, raw, m.start()), 'response_type': norm(m[1]), 'arguments': norm(m[3])}
    localp = 'cpp/src/local_client.cpp'; raw = read(localp); s = clean(raw)
    implementations = {}
    for m in re.finditer(r'StatusOr<(.*?)>\s+(\w+)\((.*?)\)\s*override\s*\{', s, re.S):
        i, depth = m.end(), 1
        while depth:
            depth += (s[i] == '{') - (s[i] == '}'); i += 1
        b = s[m.end():i-1]
        implementations[m[2]] = {'source': cite(localp, raw, m.start()), 'body_sha256': hashlib.sha256(raw[m.end():i-1].encode()).hexdigest(), 'body': b}
    assert set(implementations) <= set(declarations), set(implementations)-set(declarations)
    ap = 'cpp/include/libghidra/api.hpp'; a = clean(read(ap))
    defaults = set(re.findall(r'StatusOr<.*?>\s+(\w+)\([^;{]*?\)\s*override\s*\{', a, re.S))
    assert defaults == set(declarations), (defaults-set(declarations),set(declarations)-defaults)
    # Tier names are read from the normative table, not guessed by operation prefix.
    tiers = {}
    for line in (ROOT/'docs/COVERAGE.md').read_text().splitlines():
        if line.startswith('|'):
            columns = line.split('|')
            if len(columns)>4:
                for name in re.findall(r'\b[A-Z][A-Za-z]+\b',columns[3]):
                    if name in declarations or name=='CreateLocalClient': tiers[name]=columns[2].strip().lower()
    assert set(implementations) <= set(tiers), set(implementations)-set(tiers)
    def fields(t, prefix='', trail=()):
        base = re.sub(r'\bconst\b|&', '', t).strip()
        while base.startswith(('std::vector<','std::optional<')): base=base[base.index('<')+1:-1]
        if base in trail: raise ValueError('recursive model '+base)
        if base not in types: return []
        result=[]
        for f in types[base]['fields']:
            path = prefix + f['name']; result.append(dict(f, path=path, model=base))
            result += fields(f['native_type'],path+'.',trail+(base,))
        return result
    ops=[]
    for name,d in sorted(declarations.items()):
        impl=implementations.get(name); included=impl is not None
        request=[]
        for arg in split(d['arguments']):
            fm=re.fullmatch(r'(.+?)\s+(\w+)',arg)
            if not fm: raise ValueError('unparsed argument '+name+': '+arg)
            t,key=fm.groups()
            default = '100' if key=='limit' else '0' if key in ['offset','range_start'] else 'UINT64_MAX (explicit zero sentinel only where documented)' if key=='range_end' else '30000 (ignored)' if key=='timeout_ms' else 'required (unless nested native default is recorded)'
            request.append({'name':key,'native_type':t,'lua':lua(t),'binding_default':default,'nested_fields':fields(t)})
        b=impl['body'] if impl else ''
        snake=re.sub(r'([a-z0-9])([A-Z])',r'\1_\2',re.sub(r'([A-Z]+)([A-Z][a-z])',r'\1_\2',name)).lower()
        tier=tiers.get(name,'excluded')
        cls='lifecycle' if name in ['OpenProgram','CloseProgram','Shutdown'] else 'mutation' if name.startswith(('Set','Add','Clear','Delete','Create','Rename','Apply','Write','Patch','Save','Discard')) else 'read'
        facade = 'native() escape hatch' if included else 'excluded'
        if included and (tier=='slice' or tier=='core' and name not in ['DiscardProgram']): facade='facade convenience/page; complete envelope except specified lookup extraction'
        if name=='ListDefinedStrings': facade='native() compatibility page only; no discovery iterator'
        if name=='ListFunctionSignatures': facade='facade pages only; no iterator'
        response_fields=fields(d['response_type'])
        paged=any(x['name']=='limit' for x in request)
        page=None
        if paged:
            page={'bounds':'limit>0; offset>=0; each <=INT_MAX; offset+limit<=INT_MAX; supported native collection size <INT_MAX', 'cursor_domain':'candidate functions' if name=='ListFunctionSignatures' else 'ignored' if name=='ListDefinedStrings' else 'native sequence before response extraction; inspect source order', 'post_page_filter':'missing signatures removed after candidate page' if name=='ListFunctionSignatures' else 'none observed in LocalClient; downstream adapter filtering must be resolved', 'identity':'UNRESOLVED: exact model key/comparator requires downstream review', 'order':'UNQUALIFIED; iterator disabled until serial repeated scans establish stable global order', 'range_zero_end':True if name in ['ListFunctions','ListSymbols','ListInstructions','GetComments','ListDataItems'] else 'UNRESOLVED: downstream normalization review required' if any(x['name']=='range_end' for x in request) else 'not applicable', 'extraction':[x['name'] for x in response_fields if x['native_type'].startswith('std::vector<') and '.' not in x['path']]}
        limitations=[]
        if name=='ListDefinedStrings': limitations=['constant-empty loaded-program success; ignores range/page fields; fidelity-only positive gate on known-string fixture; no discovery, scanner or iterator']
        if name in ['GetDecompilation','ListDecompilations']: limitations+=['timeout_ms ignored; facade rejects explicit timeout; completed=false/fallback preserved']
        if name=='ReadBytes': limitations+=['public uint32 length; binding 0..INT32_MAX due signed int4 loadFill; reject before dispatch/allocation']
        ignored={'OpenProgram':['project_name','read_only'],'DeleteSymbol':['name'],'CreateType':['size'],'AddTypeMember':['size'],'CreateTypeEnum':['width','is_signed']}.get(name,[])
        if ignored: limitations+=['ignored native fields: '+', '.join(ignored)]
        if name=='CreateType': limitations+=['only struct kind; others NOT_SUPPORTED']
        if name=='ListInstructions': limitations+=['linear decode from range_start; stop at first gap/zero length; default zero can be empty despite code elsewhere']
        if name=='ListLeafFunctions': limitations+=['requires analyzed project reference index']
        if name=='DiscardProgram': limitations+=['true no-op acknowledgment; no rollback']
        if name in ['SaveProgram','OpenProgram']: limitations+=['state persistence/reload limited; no byte overlay persistence guarantee']
        if name in ['CloseProgram','Shutdown']: limitations+=['logical program access closure; engines retained; owner remains usable; do not label CLOSED']
        ops.append(dict(name=name,lowlevel=snake if included else None,tier=tier,facade=facade,dispatch=cls if included else 'excluded',generation='invalidate before dispatch, including failure/partial effect' if cls!='read' and included else 'unchanged',program_state=('requires loaded program' if 'ensure_loaded()' in b else 'no ensure_loaded guard in override; inspect lifecycle/helper') if included else 'not locally implemented; inherited NOT_SUPPORTED',declaration=d,implementation={k:v for k,v in impl.items() if k!='body'} if impl else None,request=request,response={'native_type':d['response_type'],'lua':lua(d['response_type']),'fields':response_fields},native_literal_errors=sorted(set(re.findall(r'FromError\(\s*"([^"]*)"',b))),pagination=page,limitations=limitations,ignored_fields=ignored,evidence={'positive':{'status':'unqualified','fixture':None,'command':None,'assertions':'real supported case with all response fields; defined strings fidelity exception applies'},'negative':{'status':'unqualified','fixture':None,'command':None,'assertions':'unloaded/unsupported/validation and recorded limitations'},'python_oracle':'unqualified'},exclusion=None if included else 'HTTP/shared default only; api.hpp NOT_SUPPORTED does not establish local support'))
    review_pages(u, ops)
    review_aggregate_pages(u, ops)
    review_session_records(u, ops)
    review_open_and_creation(u, ops)
    review_parameter_and_byte_mutations(u, ops)
    review_member_reconstruction(u, ops)
    review_local_and_data_edits(u, ops)
    review_alias_symbol_comments(u, ops)
    review_lookups(u, ops, types)
    review_page_wrappers(u, ops)
    review_record_fields(u, ops, types)
    review_decompilation_fields(u, ops, types)
    review_graph_fields(u, ops, types)
    review_performance_fields(u, ops, types)
    review_mutation_results(u, ops, types)
    review_status_fields(u, ops, types)
    review_special_results(u, ops, types)
    review_container_results(u, ops)
    surfaces(ops)
    request_audit=review_request_fields(u, ops)
    python=[]
    # Independent public operations and model fields, including HTTP/async/headless exclusions.
    for p in sorted((u/'python/src/libghidra').glob('*.py')):
        if p.name.endswith('_pb2.py'): continue
        rel=str(p.relative_to(u)); text=read(rel); tree=ast.parse(text)
        for c in tree.body:
            if isinstance(c,ast.ClassDef):
                for n in c.body:
                    if isinstance(n,(ast.FunctionDef,ast.AsyncFunctionDef)) and (not n.name.startswith('_') or n.name in ['__init__','__enter__','__exit__']):
                        match=next((o['name'] for o in ops if o['lowlevel']==n.name),None)
                        python.append({'file':rel,'class':c.name,'method':n.name,'line':n.lineno,'signature':ast.unparse(n.args),'return':ast.unparse(n.returns) if n.returns else None,'native_operation':match if p.name=='local.py' else None,'disposition':'local constructor/lifecycle' if p.name=='local.py' and n.name.startswith('_') else 'local facade mapped' if p.name=='local.py' and match else 'excluded transport/headless/helper; not native local support','model_fields':[], 'body_sha256':hashlib.sha256(ast.dump(n, include_attributes=False).encode()).hexdigest(), 'calls':sorted(set(ast.unparse(x.func) for x in ast.walk(n) if isinstance(x,ast.Call))), 'returns':[ast.unparse(x.value) for x in ast.walk(n) if isinstance(x,ast.Return) and x.value is not None]})
                annotations=[{'name':n.target.id,'python_type':ast.unparse(n.annotation),'default':ast.unparse(n.value) if n.value else None} for n in c.body if isinstance(n,ast.AnnAssign) and isinstance(n.target,ast.Name)]
                if annotations: python.append({'file':rel,'class':c.name,'model_fields':annotations,'native_model':c.name if c.name in types else None,'disposition':'Python field inventory; narrower facade not native authority'})
    # Hash downstream primitives so source inspection can be reproduced without vendoring expression.
    for p in sorted((u/'cpp/src').glob('*adapter*.cpp')): read(str(p.relative_to(u)))
    read('cpp/src/decompiler_pool.cpp')
    read('cpp/src/local_arch_adapter.hpp')
    read('cpp/bindings/python_bindings.cpp')
    python_audit = reconcile_python(u, ops, types)
    return {'format':1,'pin':PIN,'qualification':'M0 inventory only; no adapters or runtime qualification','sources':files,'types':types,'enums':enums,'operations':ops,'semantic_audit':semantic_audit(ops),'request_audit':request_audit,'python':python,'python_reconciliation':python_audit,'lifecycle':{'factory':'CreateLocalClient(LocalClientOptions) -> unique_ptr<IClient>; lowlevel local_client, facade open constructs once then opens; failure releases new owner','factory_fields':fields('LocalClientOptions'),'restrictions':'pool_size exactly 1; process-wide single live client; serialize engine dispatch/destruction','owner_close':'binding close/__close/GC releases native owner and process slot; aliases CLOSED; no autosave; __close nonraising','native_close':'CloseProgram/Shutdown logically close access, retain engines; aliases NO_PROGRAM; reopen same owner invalidates prior iterators; detached open metadata historical','factory_tier':'slice'},'error_envelope':{'native':'StatusOr<T>: Status.code/message plus optional<T> value; status.ok && value present','lua':'response or nil,error; preserve unknown code/message/upstream_code; backend local vs binding; exceptions caught; allocation errors remain Lua errors','facade':'lookup value,nil,response; absent optional nil,NOT_FOUND,response; flags/pages preserve envelope'},'unresolved':['Exact downstream identity/order/comparator and effective numeric constraints beyond documented exceptions require operation-by-operation review; no iterators qualified','Independent semantic reconciliation of Python conversion/extraction bodies remains open; AST signatures are not behavioral equivalence evidence']}

def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--source',type=Path,default=DEFAULT); ap.add_argument('--check',action='store_true'); args=ap.parse_args()
    data=inventory(args.source); content=json.dumps(data,indent=2,sort_keys=True)+'\n'; target=ROOT/'api/coverage.json'
    if args.check:
        assert target.read_text()==content, 'inventory stale: regenerate and review differences'
    else: target.write_text(content)
    print(('Checked' if args.check else 'Generated'),len(data['operations']),'native operations;',len(data['types']),'model types;',sum(len(x['fields']) for x in data['types'].values()),'direct fields;',len(data['python']),'Python operation/model rows')
    print('UNQUALIFIED: semantic review obligations in coverage.json unresolved list remain open')
if __name__=='__main__': main()
