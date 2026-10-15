"""Caller-supplied performance data is not native measured benchmark evidence."""
import hashlib
from inventory_semantics import LOCAL, body


def review_performance_fields(u, operations, types):
    source=(u/LOCAL).read_text()
    bodies={name:body(source,' '+name+'(')[1] for name in [
        'AddPerfBenchmark','ListPerfBenchmarks','ClearPerfBenchmarks','DeletePerfBenchmark']}
    add=bodies['AddPerfBenchmark']
    assert 'perf_benchmarks_.push_back(record)' in add
    assert 'record.bench_id.empty()' in add
    assert 'r.bench_id == record.bench_id' in add
    assert add.index('perf_benchmarks_.erase(')<add.index('perf_benchmarks_.push_back(record)')
    assert 'resp.records = perf_benchmarks_' in bodies['ListPerfBenchmarks']
    clear=bodies['ClearPerfBenchmarks']
    assert 'resp.removed_count = static_cast<std::uint32_t>(perf_benchmarks_.size())' in clear
    assert clear.index('resp.removed_count =')<clear.index('perf_benchmarks_.clear()')
    assert 'resp.cleared = true' in clear and 'resp.added = true' in add
    delete=bodies['DeletePerfBenchmark']
    assert 'const bool deleted = perf_benchmarks_.size() != before' in delete
    assert 'resp.deleted = deleted' in delete
    semantics={
        'bench_id':'caller-supplied nonempty string, sole upsert/delete key; empty rejected invalid_argument; stored verbatim and listed unchanged',
        'query_family':'caller-supplied label, empty allowed natively; no native family validation or measurement',
        'dataset_profile':'caller-supplied label, empty allowed natively; no native dataset validation',
        'status':'caller-supplied string, empty allowed natively; not a native pass/fail result or validated enum',
    }
    for name in ['cold_ms_p50','cold_ms_p95','warm_ms_p50','warm_ms_p95']:
        semantics[name]='caller-supplied double, conventional milliseconds; native stores/copies unchanged, no timing/percentile calculation, nonnegative or finite validation; Lua number uses runtime lua_Number precision, binary64 roundtrip unqualified'
    for name in ['throughput_qps','regression_pct']:
        semantics[name]='caller-supplied double, conventional '+('queries/second' if name=='throughput_qps' else 'percent')+'; native stores/copies unchanged, no computation or finite/sign/range validation; Lua number precision is runtime-dependent, binary64 roundtrip unqualified'
    assert set(semantics)=={f['name'] for f in types['PerfBenchmarkRecord']['fields']}
    flags={
        'AddPerfBenchmark': {'added':'literal true after erase-then-append upsert; true also for replacement, not new-insertion indicator'},
        'ClearPerfBenchmarks': {'cleared':'literal true, even if vector already empty', 'removed_count':'pre-clear vector size cast uint32; exact only for count<=UINT32_MAX, otherwise modulo conversion; not number of runtime measurements'},
        'DeletePerfBenchmark': {'deleted':'true iff stored vector size decreased after bench_id erase; absent key yields successful false and unchanged native revision'},
        'ListPerfBenchmarks': {'records':'complete copy of caller-supplied records in insertion/upsert order; replacement moves to tail; no pagination, filtering or native measurement'},
    }
    for op in operations:
        name=op['name']
        if name not in bodies:continue
        for field in op['response']['fields']:
            if field['model']=='PerfBenchmarkRecord':field['semantics']=semantics[field['name']]
            elif field['name'] in flags[name]:field['semantics']=flags[name][field['name']]
        if name=='AddPerfBenchmark':
            for field in op['request'][0]['nested_fields']:
                field['semantics']=semantics[field['name']]
        op['performance_field_review']={'path':LOCAL,'body_sha256':hashlib.sha256(bodies[name].encode()).hexdigest(),
            'record_fields':sorted(semantics) if name in ['AddPerfBenchmark','ListPerfBenchmarks'] else [],
            'response_fields':sorted(flags[name]),
            'qualification':'source storage semantics only; no benchmark result or runtime evidence generated'}
    return operations
