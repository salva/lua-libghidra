-- MIT Copyright 2026 Salvador Fandiño.
-- Real installed native conditional CFG; not a synthetic page producer.
local prefix,binary=assert(arg[1]),assert(arg[2])
package.path=prefix..'/share/lua/5.4/?.lua;'..prefix..'/share/lua/5.4/?/init.lua'
package.cpath=prefix..'/lib/lua/5.4/?.so'
local gh=require('libghidra'); local check=gh.check
local s <close> =check(gh.open{program={program_path=binary,language_id='x86:LE:64:default',compiler_spec_id='gcc'}})
assert(check(s:get_decompilation(0x401106)).completed)
local function page(method,limit,offset)
 return check(s[method](s,{range_start=0x401106,range_end=0x401106,limit=limit,offset=offset}))
end
local blocks=page('list_basic_blocks',100,0).blocks
local edges=page('list_cfg_edges',100,0).edges
assert(#blocks==4 and #edges==4)
local function blockkey(r) return r.function_entry:hex()..r.start_address:hex()..r.end_address:hex() end
local function edgekey(r) return r.function_entry:hex()..r.src_block_start:hex()..r.dst_block_start:hex()..r.edge_kind end
for _,row in ipairs{{'list_basic_blocks','blocks',blocks,blockkey},{'list_cfg_edges','edges',edges,edgekey}} do
 local method,field,all,key=table.unpack(row)
 for pass=1,2 do
  local repeated=page(method,100,0)[field]; assert(#repeated==#all)
  for i,r in ipairs(repeated) do assert(key(r)==key(all[i])) end
  for offset=0,#all do
   local records=page(method,1,offset)[field]
   assert(#records==(offset==#all and 0 or 1))
   if records[1] then assert(key(records[1])==key(all[offset+1])) end
  end
 end
end
local kinds={}
for _,e in ipairs(edges) do assert(e.function_entry:to_integer()==0x401106); kinds[e.edge_kind]=true end
assert(kinds.TRUE and kinds.FALSE and kinds.FALL_THROUGH)
-- Preserve the actual native-order counterexample; do not sort or invent ordinals.
assert(blocks[2].start_address:hex()>blocks[3].start_address:hex())
assert(s.iter_basic_blocks==nil and s.iter_cfg_edges==nil and s.iter_xrefs==nil)
print('M3 installed conditional CFG/block serial pages/fields and pages-only contract PASS')
