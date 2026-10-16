-- MIT Copyright 2026 Salvador Fandiño.
local prefix,root=assert(arg[1]),assert(arg[2])
package.path=prefix..'/share/lua/5.4/?.lua;'..prefix..'/share/lua/5.4/?/init.lua'
package.cpath=prefix..'/lib/lua/5.4/?.so'
local gh=require('libghidra'); local check=gh.check
for _,project in ipairs{false,true} do
 local program={program_path=root..'/tests/fixtures/inputs/authored.elf',language_id='x86:LE:64:default',compiler_spec_id='gcc'}
 if project then program.project_path=root..'/tests/fixtures/project/authored.gpr' end
 local s <close> =check(gh.open{program=program})
 for _,a in ipairs{0x401106,0x40111f,0x40113c} do assert(check(s:get_decompilation(a)).completed) end
 for _,row in ipairs{{'functions','functions','entry_address'},{'symbols','symbols','address'},
  {'memory_blocks','blocks','start_address'},
  {'basic_blocks','blocks','start_address'},{'xrefs','xrefs','from_address'}} do
  local family,field,key=table.unpack(row)
  local function page(opts)
   if family=='types' then return check(s:list_types('',opts))[field] end
   return check(s['list_'..family](s,opts))[field]
  end
  local function iter(opts)
   if family=='types' then return s:iter_types('',opts) end
   return s['iter_'..family](s,opts)
  end
  local all=page{limit=100}; assert(#all>0)
  for pass=1,2 do
   for _,size in ipairs{1,2,100} do
    local i=0
    for r in iter{page_size=size} do
     i=i+1; assert(all[i] and tostring(r[key])==tostring(all[i][key]))
    end
    assert(i==#all)
   end
  end
  local it=iter{offset=100000,page_size=1}; assert(it()==nil and it()==nil)
  for _,opts in ipairs{{page_size=0},{page_size=1,offset=2147483647}} do
   local ok,e=pcall(iter,opts); assert(not ok and e.code=='INVALID_ARGUMENT')
  end
  local it=iter{page_size=2}; assert(it()) -- early exit: no prefetch
  assert(check(s:native():discard_program()).discarded)
  local ok,e=pcall(it); assert(not ok and e.code=='ITERATOR_INVALIDATED')
  print((project and 'project' or 'ELF')..' serial '..family..' PASS records='..#all)
 end
 -- Native anonymous types collide at path_name='/'; no fabricated identity.
 local types=check(s:list_types('',{limit=100})).types
 local paths,duplicate={},false
 for _,t in ipairs(types) do if paths[t.path_name] then duplicate=true end; paths[t.path_name]=true end
 assert(duplicate and s.iter_types==nil)
 assert(s.iter_function_signatures==nil and s.iter_defined_strings==nil)
end
-- Owning iterator primitive: caps, stalls, errors and finalizers independent of producer.
local iterate=require('libghidra.iterator')
local native=require('libghidra._native')
local function key(r) return {r.id} end
local function id(r) return tostring(r.id) end
local owner={generation=1}
function owner:_generation() return self.generation end
function owner:_generation_matches(g) return self.generation==g end
local function make(pages,opts)
 local calls=0
 return iterate(owner,'test',function(p)
  calls=calls+1; return pages[calls] or {}
 end,id,key,opts or {page_size=2}),function() return calls end
end
local it,calls=make{{{id=1}},{{id=2}},{{id=3}},{}}
for i=1,3 do assert(it().id==i) end
assert(it()==nil and calls()==4) -- short/capped pages are not exhaustion
local it,calls=make{{{id=1},{id=2}}}; assert(it().id==1 and calls()==1)
assert(it().id==2 and calls()==1) -- buffered, no prefetch
for _,pages in ipairs{{{{id=1},{id=1}}},{{{id=1},{id=2},{id=3}}},{{{id=2}},{{id=1}}},{{{id=1}},{{id=1}}}} do
 local it,calls=make(pages)
 local ok,e=pcall(function() while it() do end end)
 assert(not ok and e.code=='PAGINATION_STALLED'); local n=calls()
 assert(it()==nil and calls()==n)
end
local it=iterate(owner,'test',function() return nil,{code='NATIVE_TEST'} end,id,key,{})
local ok,e=pcall(it); assert(not ok and e.code=='NATIVE_TEST'); assert(it()==nil)
-- Publication and key construction may collect owner-mutating finalizers.
for _,phase in ipairs{'publication','key','buffer'} do
 owner.generation=1
 local function mutate() owner.generation=2 end
 local function finalize() local x=setmetatable({},{__gc=mutate}); x=nil; collectgarbage() end
 local it=iterate(owner,'test',function()
  if phase=='publication' then finalize() end
  return {{id=1},{id=2}}
 end,id,function(r) if phase=='key' then finalize() end; return key(r) end,{page_size=2})
 if phase=='buffer' then assert(it().id==1); finalize() end
 local ok,e=pcall(it); assert(not ok and e.code=='ITERATOR_INVALIDATED')
end
print('M3 iterator primitive bounds/caps/stalls/errors/early exit/finalizers PASS')
