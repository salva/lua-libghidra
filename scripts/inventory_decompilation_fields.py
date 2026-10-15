"""Branch-specific decompilation population, including unreachable token schema."""
import hashlib
import re
from inventory_semantics import ADAPTER, LOCAL, body

POOL = 'cpp/src/decompiler_pool.cpp'


def review_decompilation_fields(u, operations, types):
    local=(u/LOCAL).read_text()
    pool=(u/POOL).read_text()
    adapter=(u/ADAPTER).read_text()
    _,single=body(local,' GetDecompilation(')
    _,batch=body(pool,'DecompilerPool::decompileMany(')
    _,collect=body(adapter,'void collect_function_locals(')
    _,extract=body(adapter,'ArchAdapter::decompileWithLocals(')
    # Check both result branches, not the union of assigned keys alone.
    success=single[single.index('} else {'):]
    failure=single[:single.index('} else {')]
    assert set(re.findall(r'\brec\.(\w+)\s*=',success))=={
        'function_entry_address','pseudocode','locals','completed'}
    assert set(re.findall(r'resp\.decompilation->(\w+)\s*=',failure))=={
        'function_entry_address','completed','error_message'}
    assert 'error_message = dl.error' in failure and 'completed = false' in failure
    assert 'rec.completed = true' in success
    assert 'rec.locals = std::move(dl.locals)' in success
    assert 'rec.pseudocode = std::move(dl.pseudocode)' in success
    assert set(re.findall(r'results\[i\]\.(\w+)\s*=',batch))=={
        'function_entry_address','function_name','pseudocode','locals','completed','error_message'}
    assert batch.count('if (i < names.size()) results[i].function_name = names[i]')==2
    assert batch.count('results[i].error_message = dl.error')==2
    assert batch.count('results[i].completed = false')==2
    assert batch.count('results[i].completed = true')==2
    assert 'std::vector<DecompilationRecord> results(addresses.size())' in batch
    assert 'f.get();' in batch
    local_fields={
        'local_id':'canonical_local_id opaque string: arg category index for parameters; signed Stack offset for stack locals; otherwise space/offset, dynamic hash or anonymous plus signed-int first-use displacement snapshot; no cross-generation identity promise',
        'kind':'parameter category -> kParam; nonmapped first entry -> kTemp; otherwise kLocal (including no first entry); native numeric enum preserved',
        'name':'symbol name; empty name replaced by canonical local_id',
        'data_type':'symbol datatype name or empty string when absent, NOT undefined',
        'storage':'empty for no first entry; hash for nonmapped entry; Stack[signed hex offset] for stack; otherwise space:0xoffset; display string not a stable address object',
        'ordinal':'parameter category index cast to signed int; nonparameters -1 sentinel, not Lua array index',
    }
    assert set(re.findall(r'\brec\.(\w+)\s*=',collect))==set(local_fields)
    assert 'if (sym->isHiddenReturn()) return' in collect
    assert 'if (!seen_ids.insert(rec.local_id).second) return' in collect
    assert 'if (rec.name.empty()) rec.name = rec.local_id' in collect
    assert 'dt->getName() : ""' in collect
    assert 'static_cast<int>(sym->getCategoryIndex())' in collect and ': -1' in collect
    assert collect.index('local->begin()') < collect.index('local->beginDynamic()')
    assert extract.index('reapplyLocalRenames(func_entry, fd)') < extract.index('docFunction(fd)') < extract.index('collect_function_locals(arch_, fd, pairs)')
    assert 'result.ok = !result.pseudocode.empty()' in extract
    assert 'result.error = describe_current_exception()' in extract
    for op in operations:
        if op['name'] not in ['GetDecompilation','ListDecompilations']: continue
        is_batch=op['name']=='ListDecompilations'
        path,text,signature=(POOL,batch,'DecompilerPool::decompileMany(') if is_batch else (LOCAL,single,' GetDecompilation(')
        review={'path':path,'body_sha256':hashlib.sha256(text.encode()).hexdigest(),
                'model':'DecompilationRecord','branches':{
                    'success_assigned':['function_entry_address','pseudocode','locals','completed']+(['function_name'] if is_batch else []),
                    'failure_assigned':['function_entry_address','error_message','completed']+(['function_name'] if is_batch else []),
                },'qualification':'source branch population only; runtime positive/negative fixtures unqualified'}
        op.setdefault('record_field_reviews',[]).append(review)
        semantics={
            'function_entry_address':'candidate input address in both success/failure; copied unchanged, not independently normalized entry',
            'function_name':('candidate list name assigned in BOTH success/failure if matching names index exists; normal wrapper supplies one name per address' if is_batch else 'never assigned by single decompilation wrapper; model empty even on success'),
            'pseudocode':'success: printer output after persisted local rename reapplication; failure: record empty initializer (partial adapter output discarded)',
            'completed':'dl.ok (nonempty printer output) -> true; failure -> false but record remains PRESENT, not native StatusOr error or optional absence',
            'error_message':'failure: actual dl.error; success: model empty; not pool getError stale state',
            'locals':'success: adapter collected locals before analysis cleanup; failure: empty initializer even if adapter collected partial locals; dedup by Symbol* and canonical ID, hidden returns skipped; mapped traversal then dynamic traversal, no sort',
            'prototype':'never assigned by producer; model empty even on success',
            'is_fallback':'never assigned by producer; model false even on failure; not a measured fallback flag',
            'tokens':'never populated by native-local producer; empty vector on success AND failure; nested token schema is unreachable here',
        }
        assert set(semantics)=={f['name'] for f in types['DecompilationRecord']['fields']}
        assert set(local_fields)=={f['name'] for f in types['DecompileLocalRecord']['fields']}
        for field in op['response']['fields']:
            model,name=field['model'],field['name']
            if model=='DecompilationRecord': field['semantics']=semantics[name]
            elif model=='DecompileLocalRecord': field['semantics']=local_fields[name]
            elif model=='DecompileTokenRecord':
                field['semantics']='unreachable nested token element: producer never appends tokens; declared initializer '+field['native_default']+' is schema only, NOT an observed token field or output item'
            else:continue
            field['producer_review']={'path':path if model=='DecompilationRecord' else ADAPTER,'method':signature if model=='DecompilationRecord' else 'collect_function_locals / decompileWithLocals'}
        op['decompilation_extraction_review']={
            'path':ADAPTER,'body_sha256':hashlib.sha256((collect+extract).encode()).hexdigest(),
            'locals_order':'mapped scope iteration then dynamic scope iteration; first occurrence retained by symbol and canonical-ID seen sets; no sorted order promise',
            'failure':'missing architecture leaves default failed result; failed perform or empty print supplies diagnostic; exceptions describe/log caught error; wrapper discards partial data when dl.ok false',
            'analysis':'find/create function and perform; reapply persisted local renames before print/locals; RAII clears analysis including exceptional exits; no wrapper native revision increment',
            'identity_limits':'opaque local_id uses native casts/space snapshots; first-use displacement narrows to int, stack formatting signed arithmetic follows native; cross-runtime/address-boundary behavior unqualified',
        }
    return operations
