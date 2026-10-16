-- MIT Copyright 2026 Salvador Fandiño.
-- Presentation only. The package owner must expose its existing heading allocator;
-- never substitute Pandoc's auto identifiers or a second slug approximation.
local source_root=assert(os.getenv('LLG_SITE_SOURCE'),'LLG_SITE_SOURCE required')
package.path=source_root..'/site/?.lua;'..source_root..'/scripts/?.lua;'..package.path
local content=require('content')
local json=require('tool_json')
local config=json.decode(content.read(assert(os.getenv('LLG_SITE_CONFIG'))))
local policy=dofile(source_root..'/scripts/package-documents.lua')
assert(type(policy.heading_ids)=='function' and type(policy.heading_texts)=='function',
  'shared-heading-api: package owner must export heading_ids allocator before site rendering')
local next_id=policy.heading_ids()
local source_ids={}
for _,raw in ipairs(policy.heading_texts(content.read(source_root..'/'..config.source))) do
  source_ids[#source_ids+1]=next_id(raw)
end
local header_index=0
local route=assert(config.routes[config.source])
local external={}
-- Generated C++ type notation is text, not an HTML extension. Permit only
-- exact ledger model names (and bool) on the generated fields page, escaped
-- through Str. All attributes, closing tags and other raw markup still fail.
local ledger=json.decode(content.read(source_root..'/api/coverage.json'))
local function raw_inline(el)
  local name=el.text:match('^<([%w_]+)>$')
  assert(config.source=='api/FIELDS.md' and el.format=='html' and name
    and (ledger.types[name] or name=='bool'), 'unsupported raw inline markup')
  return pandoc.Str(el.text)
end
local native_names={}
for _,model in pairs(ledger.types) do
  for _,field in ipairs(model.fields or {}) do
    for name in field.native_type:gmatch('std::[%w_]+') do native_names[name]=true end
  end
end
local function target(el)
  -- Pandoc recognizes angle-bracket C++ namespace notation as a URI scheme.
  -- Restore exact visible text only for ledger-native names, never arbitrary
  -- schemes or explicit labelled links.
  if config.source=='api/FIELDS.md' and native_names[el.target]
    and el.t=='Link' and pandoc.utils.stringify(el.content)==el.target then
    return pandoc.Str('<'..el.target..'>')
  end
  local value,is_external=content.link(config.source,el.target or el.src,config.routes)
  if is_external then external[value]=true end
  if el.t=='Image' then assert(not is_external,'remote image forbidden'); el.src=value
  else el.target=value end
  return el
end
return {
  { Header=function(el)
      header_index=header_index+1
      el.identifier=assert(source_ids[header_index], 'heading-count: extra AST Header')
      return el
    end,
    Link=target, Image=target,
    RawBlock=function() error('unsupported raw block markup') end,
    RawInline=raw_inline,
    Table=function(el)
      return pandoc.Div({el},pandoc.Attr('',{'table-scroll'},
        {{'role','region'},{'aria-label','Scrollable table'},{'tabindex','0'}}))
    end,
    CodeBlock=function(el) el.attributes.tabindex='0'; return el end,
  },
  { Pandoc=function(doc)
      assert(header_index==#source_ids, 'heading-count: missing AST Header')
      -- Full example display comes from the exported exact download bytes.
      if config.source=='docs/EXAMPLES.md' then
        for _,path in ipairs(config.examples) do
          doc.blocks:insert(pandoc.Header(2,path,pandoc.Attr(next_id(path))))
          doc.blocks:insert(pandoc.Para({pandoc.Link('Download '..path,
            content.page_relative(route.output,config.routes[path].output))}))
          doc.blocks:insert(pandoc.CodeBlock(content.read(source_root..'/'..path),
            pandoc.Attr('',{'lua'},{tabindex='0'})))
        end
      end
      local nav={}
      for _,item in ipairs(content.navigation(config.routes)) do
        nav[#nav+1]={label=item.label,href=content.page_relative(route.output,item.output),
          current=item.source==config.source}
      end
      doc.meta.navigation=nav
      doc.meta.stylesheet=content.page_relative(route.output,'assets/style.css')
      doc.meta.notices=content.page_relative(route.output,config.routes['docs/NOTICES.md'].output)
      doc.meta.canonical=config.origin..config.baseurl..'/'..route.output
      doc.meta.pagetitle=doc.meta.title or config.source:gsub('%.md$','')
      return doc
    end,
  }
}
