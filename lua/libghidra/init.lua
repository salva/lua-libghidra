-- MIT Copyright 2026 Salvador Fandiño.
-- Foundation only: owner/session dispatch is supplied by the following slice.
local lowlevel = require('libghidra.lowlevel')
return { u64 = lowlevel.u64, check = lowlevel.check }
