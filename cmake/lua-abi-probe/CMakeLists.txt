# MIT Copyright 2026 Salvador Fandiño.
cmake_minimum_required(VERSION 3.26)
project(llg_abi_probe LANGUAGES C)
add_library(llg_abi_probe MODULE probe.c)
target_include_directories(llg_abi_probe PRIVATE "${LLG_LUA_INCLUDE_DIR}")
# No liblua: resolve against the selected loading host.
set_target_properties(llg_abi_probe PROPERTIES PREFIX "" OUTPUT_NAME lua-abi-probe
  LIBRARY_OUTPUT_DIRECTORY "${LLG_PROBE_OUTPUT}")
