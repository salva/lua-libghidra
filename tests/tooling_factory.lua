-- MIT Copyright 2026 Salvador Fandiño. Factory consumers and fail-closed drift.
package.path='scripts/?.lua;'..package.path
local U,R=require('tool_util'),require('inventory_factory')
local root=arg[1] or '.cache/native-inputs-patched/libghidra-d51ca813ae1b6b59519551a9be8c0b1ad74d862d'
local raw=U.read(root..'/cpp/src/local_client.cpp'); local pool=U.read(root..'/cpp/src/decompiler_pool.cpp')
local types={}
for path in U.capture{'find',root..'/cpp/include/libghidra','-name','*.hpp'}:gmatch('[^\n]+') do
 local t=require('inventory_source').header(path,U.read(path)); for k,v in pairs(t) do types[k]=v end
end
assert(R.review(raw,pool,types).fields.pool_size:find('exact 1',1,true))
local cases={
 {raw,'std::max(opts_.pool_size, 1), opts_.ghidra_root','opts_.pool_size, opts_.ghidra_root','local'},
 {raw,'~LocalClient() override = default;','~LocalClient() override {}','local'},
 {raw,'return std::make_unique<LocalClient>(std::move(options));','return nullptr;','local'},
 {raw,'pool_->loadState(opts_.state_path)','pool_->loadState("")','local'},
 {pool,'std::max<std::size_t>(pool_size, 1)','pool_size','pool'},
 {pool,'slots_.resize(n);','slots_.resize(1);','pool'},
 {pool,'if (ghidra_root.empty())','if (true)','pool'},
 {pool,'std::make_unique<ghidra_standalone::Decompiler>(ghidra_root)','std::make_unique<ghidra_standalone::Decompiler>("")','pool'},
}
for _,c in ipairs(cases) do
 local i,j=assert(c[1]:find(c[2],1,true)); local changed=c[1]:sub(1,i-1)..c[3]..c[1]:sub(j+1)
 assert(not pcall(R.review,c[4]=='local' and changed or raw,c[4]=='pool' and changed or pool,types),'consumer mutation accepted '..c[2])
end
types.LocalClientOptions.fields[#types.LocalClientOptions.fields+1]={name='unreviewed'}
assert(not pcall(R.review,raw,pool,types),'new factory field accepted without review')
print('Lua four factory option consumers and nine field/consumer mutations PASS')
