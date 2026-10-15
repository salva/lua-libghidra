"""Factory option consumption; native construction is not binding owner qualification."""
import re
from inventory_semantics import LOCAL, body


def review_factory_fields(u, fields):
    local=(u/LOCAL).read_text()
    pool=(u/'cpp/src/decompiler_pool.cpp').read_text()
    assert {f['path'] for f in fields}=={'ghidra_root','state_path','default_arch','pool_size'}
    assert set(re.findall(r'opts_\.(\w+)',local))=={f['name'] for f in fields}
    assert 'std::max(opts_.pool_size, 1), opts_.ghidra_root' in local
    assert '~LocalClient() override = default;' in local
    _,factory=body(local,'CreateLocalClient(LocalClientOptions options)')
    assert 'return std::make_unique<LocalClient>(std::move(options));' in factory
    assert 'std::size_t n = std::max<std::size_t>(pool_size, 1);' in pool
    assert 'slots_.resize(n);' in pool
    assert 'if (ghidra_root.empty())' in pool
    assert 'std::make_unique<ghidra_standalone::Decompiler>();' in pool
    assert 'std::make_unique<ghidra_standalone::Decompiler>(ghidra_root)' in pool
    _,opened=body(local,' OpenProgram(')
    _,saved=body(local,' SaveProgram(')
    _,closed=body(local,'StatusOr<CloseProgramResponse> closeProgramLocked(ShutdownPolicy policy)')
    assert 'pool_->loadState(opts_.state_path)' in opened
    assert 'pool_->saveState(opts_.state_path)' in saved and 'pool_->saveState(opts_.state_path)' in closed
    meanings={
        'ghidra_root':'native empty string chooses default Decompiler constructor per slot; nonempty forwarded unchanged to constructor; no path expansion/canonicalization in these consumers; embedded-spec availability/invalid-path failure and downstream resource initialization unqualified',
        'pool_size':'native int default 1; LocalClient clamps <=0 to 1 BEFORE conversion into pool size_t, pool also clamps to >=1; >1 allocates independent engines and changes parallel branch ordering; Lua MUST accept exactly 1 only, reject other values before owner allocation; no native maximum/resource-failure guarantee inferred',
        'default_arch':'native empty string default retained; OpenProgram binary route uses only when request.language_id empty (compiler hint not appended then); nonempty request hint overrides; project loading ignores it but response language echo can still use it; not detected architecture proof',
        'state_path':'native empty string disables best-effort load and native close-save; explicit SaveProgram then NO_STATE_PATH; nonempty forwarded unchanged to loadState after successful open (return ignored), saveState on explicit save or should_save close; no native autosave on default destructor; failed save precedes adapter reset; facade save-close missing path validation remains distinct',
    }
    for f in fields:
        f['semantics']=meanings[f['name']]
        f['factory_review']={'consumer':LOCAL+' / cpp/src/decompiler_pool.cpp','binding_default':'1' if f['name']=='pool_size' else 'native empty string initializer; binding configuration grammar governs omission, not truthiness','lifecycle':'CreateLocalClient unique_ptr factory constructs pool immediately; no StatusOr wrapper, construction exceptions may escape; binding single-process owner reservation/cleanup on failure and serialized destruction remain required, unqualified','qualification':'source only; positive/negative construction, owner-slot recovery and resource-path fixtures unqualified'}
    return fields
