rockspec_format = '3.0'
package = 'lua-libghidra'
version = 'scm-1'
-- Local development only. This descriptor grants no distribution permission.
source = { url = 'file://.' }
description = {
  summary = 'Native-local Lua binding for the pinned libghidra SDK',
  detailed = 'Original wrapper is MIT; linked dependencies retain their own licenses. Local development package, not a distribution approval.',
  license = 'MIT (original wrapper only)',
}
supported_platforms = { 'linux' }
dependencies = { 'lua >= 5.4, < 5.5' }
build = {
  type = 'command',
  build_command = '$(LUA) scripts/luarocks-build.lua build "$(PREFIX)" "$(LIBDIR)" "$(LUADIR)" "$(LUA)" "$(LUA_INCDIR)"',
  install_command = '$(LUA) scripts/luarocks-build.lua install "$(PREFIX)" "$(LIBDIR)" "$(LUADIR)"',
  copy_directories = {},
}
