"""Reviewed nested request consumption and explicit remaining request ledger."""
import re
from inventory_semantics import LOCAL, body, _code_mask


def review_request_fields(u, operations):
    source=(u/LOCAL).read_text()
    open_semantics={
        'project_path':'nonempty selects loadProject BEFORE binary branch; program_path forwarded too; empty selects binary route if program_path nonempty, else INVALID_ARGUMENT',
        'program_path':'project program selector when project_path nonempty; otherwise nonempty binary filename required; not expanded/canonicalized by wrapper; also response program_name preference',
        'project_name':'ignored native request field: never read; facade rejects presence rather than silently dropping it',
        'read_only':'ignored native request field: never read; false is not absence; facade rejects presence rather than promising read-only behavior',
        'language_id':'binary only: empty selects opts.default_arch (compiler_spec_id then not appended); nonempty plus nonempty compiler_spec_id joins with colon, otherwise used unchanged; project route ignores architecture hints; response echo is not detected metadata',
        'compiler_spec_id':'binary only appended to nonempty language_id using colon when nonempty; ignored for architecture if language_id empty and on project route; response echoes field regardless',
        'format':'binary only forwarded unchanged to loadBinary; project route ignores; empty native string preserved, not an independently detected format',
        'base_address':'binary only exact uint64 forwarded to loadBinary; project route ignores; zero preserved, no zero-end range sentinel semantics',
    }
    expected={'OpenProgram':set(open_semantics),'AddPerfBenchmark':{'bench_id','query_family','dataset_profile','cold_ms_p50','cold_ms_p95','warm_ms_p50','warm_ms_p95','throughput_qps','regression_pct','status'},'PatchBytesBatch':{'address','data'}}
    ledger=[]
    for op in operations:
        if not op['implementation']:continue
        name=op['name']
        _,text=body(source,' '+name+'(')
        code=_code_mask(text)
        for arg in op['request']:
            nested=arg['nested_fields']
            if not nested:
                ledger.append({'operation':name,'path':arg['name'],'reason':'direct argument consumption/default/domain review not yet independently reconciled'})
                continue
            assert name in expected
            assert {f['path'] for f in nested}==expected[name],name
            if name=='OpenProgram':
                assert set(re.findall(r'\brequest\.(\w+)',code))==expected[name]-{'project_name','read_only'}
                assert code.index('loadProject(')<code.index('loadBinary(')
                assert 'if (request.language_id.empty())' in code and 'arch = opts_.default_arch' in code
            elif name=='AddPerfBenchmark':
                assert set(re.findall(r'\brecord\.(\w+)',code))=={'bench_id'}
                assert 'perf_benchmarks_.push_back(record)' in code
            else:
                assert set(re.findall(r'\bpatch\.(\w+)',code))=={'address','data'}
                assert 'd.writeBytes(patch.address, patch.data)' in code
            for f in nested:
                key=f['name']
                if name=='OpenProgram':sem=open_semantics[key]
                elif name=='PatchBytesBatch':
                    sem=('exact UInt64 patch start forwarded unchanged; no sorting/dedup/coalescing; patches dispatched in input order, later overlaps may overwrite earlier bytes; downstream bounds unqualified' if key=='address' else 'binary bytes forwarded unchanged per patch including NUL/empty; native input size cast and total uint32 accumulator require each and summed sizes <=UINT32_MAX for count fidelity; patch count <=UINT32_MAX; no rollback on partial effects')
                else:
                    sem=('nonempty native string required (lowercase invalid_argument on empty); exact bench_id upsert key, erase matches then append so replacement moves to tail' if key=='bench_id' else 'caller-supplied field copied unchanged with complete record; not measured/computed/validated by native, including empty strings or double zero; no adapter finite/sign acceptance policy inferred')
                f['semantics']=(f['semantics']+'; '+sem) if name=='AddPerfBenchmark' else sem
                f['request_field_review']={'consumer':LOCAL,'operation':name,'native_absence':'model initializer '+f['native_default']+'; Lua input default/requiredness must not be inferred from native model alone','qualification':'source only; runtime and binding validation unqualified'}
    return {'direct_argument_review_missing':ledger,'nested_field_review_count':sum(len(a['nested_fields']) for o in operations if o['implementation'] for a in o['request'])}
