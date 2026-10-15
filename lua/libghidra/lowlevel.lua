-- MIT Copyright 2026 Salvador Fandiño.
local native = require('libghidra._native')
local function check(value, err, response)
  if value == nil then error(err, 2) end
  return value, response
end
return { u64 = native.u64, check = check }
