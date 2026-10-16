-- MIT Copyright 2026 Salvador Fandiño. Lookup absence is not a native error.
local S=require('inventory_source')
local M={}
local methods={GetFunction={'getFunction','FunctionRecord'},GetSymbol={'getSymbol','SymbolRecord'},GetType={'getType','TypeRecord'},GetInstruction={'getInstruction','InstructionRecord'},GetFunctionSignature={'getFunctionSignature','FunctionSignatureRecord'},ReadBytes={'readBytes'}}
local function has(code,x) assert(code:find(x,1,true),'lookup branch missing '..x) end
function M.review(raw,adapter,types,fingerprint)
 local out={}
 local function source(source,signature,path)
  local start,text=S.body(source,signature); local _,line=source:sub(1,start-1):gsub('\n','')
  local r={path=path,line=line+1}; if fingerprint then r.body_sha256=fingerprint(text) end
  return r,S.mask(text,false)
 end
 for name,c in pairs(methods) do
  local method,model=table.unpack(c)
  local localreview,code=source(raw,' '..name..'(','cpp/src/local_client.cpp')
  has(code,'ensure_loaded()')
  local ar,producer=source(adapter,'ArchAdapter::'..method..'(','cpp/src/local_arch_adapter.cpp')
  has(producer,'catch (...)')
  local r={consumer=localreview,producer=ar,qualification='source accounting, not new runtime qualification'}
  if model then
   has(producer,'return std::nullopt')
   local assigned={}; for f in producer:gmatch('%f[%w_]rec%.([%w_]+)%s*=') do assigned[f]=true end
   local declared={}; local defaults={}
   for _,field in ipairs(assert(types[model]).fields) do declared[field.name]=true; if not assigned[field.name] then defaults[field.name]=field.native_default end end
   for f in pairs(assigned) do assert(declared[f],'unknown record assignment '..f) end
   r.model=model; r.assigned=assigned; r.default_only=defaults
   r.absence='missing or caught/logged adapter exception becomes successful absent optional; not native NOT_FOUND; facade synthesizes NOT_FOUND with full response'
  else
   has(producer,'result.resize(length)'); has(producer,'static_cast<int4>(length)'); has(producer,'result.clear()')
   assert(producer:find('result.resize(length)',1,true)<producer:find('static_cast<int4>(length)',1,true),'read allocation/cast ordering changed')
   r.semantics='allocate requested vector BEFORE signed int4 cast; binding must reject length>INT32_MAX before dispatch; zero or caught failure empty success, not verified read length; raw FileBytes/extreme-address limitations unchanged'
  end
  if name=='GetType' then has(producer,'findByName(name)'); assert(not code:find('substr',1,true),'literal type lookup normalization changed'); r.lookup='literal name unchanged, unlike member slash normalization; path_name not proof of lookup identity' end
  if name=='GetFunctionSignature' then has(code,'pool_->primary().decompileAt(address);'); r.analysis='decompile return ignored before extraction; analysis side effects not revision increment' end
  out[name]=r
 end
 local r,code=source(raw,' GetDecompilation(','cpp/src/local_client.cpp')
 for _,token in ipairs{'resp.decompilation = DecompilationRecord{}','resp.decompilation->completed = false','resp.decompilation->error_message = dl.error','rec.completed = true','rec.locals = std::move(dl.locals)','rec.function_entry_address = address','resp.decompilation->function_entry_address = address'} do has(code,token) end
 r.semantics='both native success and failure present records; failed completed=false with dl.error, not absent optional; timeout ignored; unassigned tokens/metadata default-only'
 out.GetDecompilation=r
 local d,dc=source(raw,' ListDefinedStrings(','cpp/src/local_client.cpp'); has(dc,'ensure_loaded()'); assert(not dc:find('resp.strings',1,true),'constant empty fidelity changed'); d.semantics='loaded constant-empty success, ignored range/pages; no discovery iterator'; out.ListDefinedStrings=d
 return out
end
return M
