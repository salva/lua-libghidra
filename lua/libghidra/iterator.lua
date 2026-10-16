-- MIT Copyright 2026 Salvador Fandiño.
-- Bounded serial traversal. The descriptor defines native order, not a page sort.
local native=require('libghidra._native')
local function less(a,b)
  for i=1,#a do
    if a[i]~=b[i] then return a[i]<b[i] end
  end
  return false
end
return function(owner, operation, fetch, identity, order, options, counts_only)
  local function raise(code,message)
    error({code=code,message=message,operation=operation,backend='binding'},0)
  end
  if counts_only and type(options)=='table' then
    for k in next,options do
      if k~='page_size' and k~='offset' then raise('INVALID_ARGUMENT','count page options only') end
    end
  end
  local page,err=native._validate_page(options,true)
  if not page then error(err,0) end
  local generation=owner:_generation()
  local records,index,last,previous,done={},1,nil,{},false
  local function valid()
    if not owner:_generation_matches(generation) then
      raise('ITERATOR_INVALIDATED','owner generation changed')
    end
  end
  return function()
    valid()
    if done then return nil end
    if index>#records then
      -- One offending page ends this iterator, including errors. No retries.
      done=true
      local response,failure=fetch(page)
      valid()
      if not response then error(failure,0) end
      records,index=response,1
      if #records>page.limit then raise('PAGINATION_STALLED','oversized page') end
      local seen={}
      for _,record in ipairs(records) do
        local id=identity(record)
        valid() -- identity construction may collect owner-mutating finalizers
        local key=order(record)
        valid() -- invalidation takes precedence over stale-page diagnostics
        if seen[id] or previous[id] or (last and not less(last,key)) then
          raise('PAGINATION_STALLED','duplicate or non-advancing page')
        end
        seen[id],last=true,key
      end
      previous=seen -- bounded to one page, not an unbounded history cache
      if #records==0 then return nil end
      if page.offset>2147483647-page.limit-#records then
        raise('PAGINATION_STALLED','pagination offset exhausted')
      end
      page.offset=page.offset+#records
      done=false
    end
    valid() -- any identity/key allocation above may have run a finalizer
    local record=records[index]; index=index+1; return record
  end
end
