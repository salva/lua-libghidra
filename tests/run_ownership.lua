-- MIT Copyright 2026 Salvador Fandiño.
package.path = arg[1] .. '/lua/?.lua;' .. arg[1] .. '/lua/?/init.lua'
package.cpath = arg[2] .. '/?.so'
dofile(arg[1] .. '/tests/ownership.lua')
dofile(arg[1] .. '/tests/ownership_reentry.lua')
