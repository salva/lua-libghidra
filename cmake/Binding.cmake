# MIT Copyright 2026 Salvador Fandiño.
find_package(PkgConfig REQUIRED)
pkg_check_modules(LUA REQUIRED lua5.4)
include(CheckCXXSourceCompiles)
set(CMAKE_REQUIRED_INCLUDES ${LUA_INCLUDE_DIRS})
check_cxx_source_compiles("#include <lua.h>
static_assert(LUA_VERSION_NUM == 504);
static_assert(sizeof(lua_Integer) == 8);
int main() { return 0; }" NATIVE_LUA_ABI_OK)
if(NOT NATIVE_LUA_ABI_OK)
  message(FATAL_ERROR "Requires Lua 5.4 with 64-bit lua_Integer")
endif()
unset(CMAKE_REQUIRED_INCLUDES)
add_library(lua_ghidra MODULE ${PROJECT_SOURCE_DIR}/src/boundary.cpp ${PROJECT_SOURCE_DIR}/src/owner.cpp)
target_compile_definitions(lua_ghidra PRIVATE LLG_OWNER)
target_include_directories(lua_ghidra PRIVATE ${LUA_INCLUDE_DIRS})
target_compile_options(lua_ghidra PRIVATE -Wall -Wextra -Wpedantic)
target_link_libraries(lua_ghidra PRIVATE binding_local_whole)
# Deliberately NO liblua: every Lua symbol must resolve to the loading host.
set_target_properties(lua_ghidra PROPERTIES PREFIX "" OUTPUT_NAME _native
  LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/libghidra")
set(LUA_MODULE_DIR lib/lua/5.4 CACHE STRING "Lua native module installation directory")
set(LUA_SOURCE_DIR share/lua/5.4 CACHE STRING "Lua source installation directory")
install(TARGETS lua_ghidra LIBRARY DESTINATION "${LUA_MODULE_DIR}/libghidra")
add_library(llg_process_guard SHARED ${PROJECT_SOURCE_DIR}/src/process_guard.cpp)
# A DT_NEEDED dependency, not an inline/weak symbol: RTLD_LOCAL copies must
# resolve the same SONAME and therefore the same mutex and occupied flag.
set_target_properties(llg_process_guard PROPERTIES SOVERSION 1)
# Install only the real SONAME file. LuaRocks deploys files individually and
# cannot preserve a versioned symlink chain while moving its targets.
install(TARGETS llg_process_guard LIBRARY DESTINATION "${LUA_MODULE_DIR}/libghidra" NAMELINK_SKIP)
set_target_properties(lua_ghidra PROPERTIES INSTALL_RPATH "$ORIGIN")
target_link_libraries(binding_local_whole INTERFACE llg_process_guard)
install(DIRECTORY "${PROJECT_SOURCE_DIR}/lua/libghidra" DESTINATION "${LUA_SOURCE_DIR}")
include(CTest)
if(BUILD_TESTING)
  find_program(LUA_EXECUTABLE lua5.4 REQUIRED)
  add_test(NAME boundary_lua COMMAND ${LUA_EXECUTABLE}
    ${PROJECT_SOURCE_DIR}/tests/run.lua ${PROJECT_SOURCE_DIR} ${CMAKE_BINARY_DIR})
  add_executable(boundary_host ${PROJECT_SOURCE_DIR}/tests/boundary_host.cpp
    ${PROJECT_SOURCE_DIR}/src/boundary.cpp)
  target_include_directories(boundary_host PRIVATE ${LUA_INCLUDE_DIRS} ${PROJECT_SOURCE_DIR}/src)
  target_compile_options(boundary_host PRIVATE -UNDEBUG)
  target_link_libraries(boundary_host PRIVATE ${LUA_LIBRARIES} binding_local_whole)
  add_test(NAME boundary_host COMMAND boundary_host)
  find_library(LUA_STATIC_ARCHIVE NAMES liblua5.4.a REQUIRED)
  add_executable(boundary_static_host ${PROJECT_SOURCE_DIR}/tests/embedded.c)
  target_include_directories(boundary_static_host PRIVATE ${LUA_INCLUDE_DIRS})
  target_link_libraries(boundary_static_host PRIVATE ${LUA_STATIC_ARCHIVE} m dl)
  target_link_options(boundary_static_host PRIVATE -Wl,--export-dynamic)
  add_test(NAME boundary_static_vm COMMAND boundary_static_host
    ${PROJECT_SOURCE_DIR}/tests/run.lua ${PROJECT_SOURCE_DIR} ${CMAKE_BINARY_DIR})
  add_executable(boundary_shared_host ${PROJECT_SOURCE_DIR}/tests/embedded.c)
  target_include_directories(boundary_shared_host PRIVATE ${LUA_INCLUDE_DIRS})
  target_link_libraries(boundary_shared_host PRIVATE ${LUA_LIBRARIES})
  add_test(NAME boundary_shared_vm COMMAND boundary_shared_host
    ${PROJECT_SOURCE_DIR}/tests/run.lua ${PROJECT_SOURCE_DIR} ${CMAKE_BINARY_DIR})
endif()
if(BUILD_TESTING)
  foreach(host IN ITEMS boundary_static_host boundary_shared_host)
    add_test(NAME ownership_${host} COMMAND ${host}
      ${PROJECT_SOURCE_DIR}/tests/run_ownership.lua ${PROJECT_SOURCE_DIR} ${CMAKE_BINARY_DIR})
    add_test(NAME ownership_close_failure_${host} COMMAND ${host}
      ${PROJECT_SOURCE_DIR}/tests/ownership_close_failure.lua ${PROJECT_SOURCE_DIR} ${CMAKE_BINARY_DIR})
    add_test(NAME ownership_entrypoints_${host} COMMAND ${host}
      ${PROJECT_SOURCE_DIR}/tests/ownership_entrypoints.lua ${PROJECT_SOURCE_DIR} ${CMAKE_BINARY_DIR})
  endforeach()
endif()
if(BUILD_TESTING)
  find_package(Threads REQUIRED)
  add_executable(ownership_threads ${PROJECT_SOURCE_DIR}/tests/ownership_threads.cpp)
  target_include_directories(ownership_threads PRIVATE ${LUA_INCLUDE_DIRS})
  target_compile_options(ownership_threads PRIVATE -UNDEBUG)
  target_link_libraries(ownership_threads PRIVATE ${LUA_LIBRARIES} Threads::Threads)
  add_test(NAME ownership_concurrent_states COMMAND ownership_threads ${PROJECT_SOURCE_DIR} ${CMAKE_BINARY_DIR})
  set_tests_properties(ownership_concurrent_states PROPERTIES TIMEOUT 120)
  add_executable(native_phases ${PROJECT_SOURCE_DIR}/tests/native_phases.cpp
    ${PROJECT_SOURCE_DIR}/src/boundary.cpp ${PROJECT_SOURCE_DIR}/src/owner.cpp)
  target_compile_definitions(native_phases PRIVATE LLG_OWNER LLG_NATIVE_PHASE_OBSERVER)
  target_include_directories(native_phases PRIVATE ${LUA_INCLUDE_DIRS})
  target_compile_options(native_phases PRIVATE -UNDEBUG)
  target_link_libraries(native_phases PRIVATE ${LUA_LIBRARIES} Threads::Threads binding_local_whole)
  add_test(NAME ownership_native_phases COMMAND native_phases ${PROJECT_SOURCE_DIR} ${CMAKE_BINARY_DIR})
  set_tests_properties(ownership_native_phases PROPERTIES TIMEOUT 120)
  add_executable(guard_contention ${PROJECT_SOURCE_DIR}/tests/guard_contention.cpp)
  target_include_directories(guard_contention PRIVATE ${LUA_INCLUDE_DIRS} ${PROJECT_SOURCE_DIR}/src)
  target_compile_options(guard_contention PRIVATE -UNDEBUG)
  target_link_libraries(guard_contention PRIVATE ${LUA_LIBRARIES} Threads::Threads llg_process_guard)
  add_test(NAME ownership_guard_contention COMMAND guard_contention ${CMAKE_BINARY_DIR})
  set_tests_properties(ownership_guard_contention PROPERTIES TIMEOUT 30)
  add_executable(ownership_host ${PROJECT_SOURCE_DIR}/tests/ownership_host.c)
  target_include_directories(ownership_host PRIVATE ${LUA_INCLUDE_DIRS})
  target_compile_options(ownership_host PRIVATE -UNDEBUG)
  target_link_libraries(ownership_host PRIVATE ${LUA_LIBRARIES})
  add_test(NAME ownership_states_faults COMMAND ownership_host ${PROJECT_SOURCE_DIR} ${CMAKE_BINARY_DIR})
endif()
if(BUILD_TESTING)
  add_executable(read_order_host ${PROJECT_SOURCE_DIR}/tests/read_order_host.cpp
    ${PROJECT_SOURCE_DIR}/src/boundary.cpp ${PROJECT_SOURCE_DIR}/src/owner.cpp)
  target_compile_definitions(read_order_host PRIVATE LLG_OWNER LLG_READ_OBSERVER LLG_ADAPTER_OBSERVER
    LLG_FIXTURE_ROOT="${PROJECT_SOURCE_DIR}")
  target_include_directories(read_order_host PRIVATE ${LUA_INCLUDE_DIRS})
  target_compile_options(read_order_host PRIVATE -UNDEBUG)
  target_link_libraries(read_order_host PRIVATE ${LUA_LIBRARIES} binding_local_whole)
  add_test(NAME read_bytes_dispatch_order COMMAND read_order_host)
endif()
if(BUILD_TESTING)
  add_executable(reentry_host ${PROJECT_SOURCE_DIR}/tests/reentry_host.cpp
    ${PROJECT_SOURCE_DIR}/src/boundary.cpp ${PROJECT_SOURCE_DIR}/src/owner.cpp)
  target_compile_definitions(reentry_host PRIVATE LLG_OWNER LLG_REENTRY_OBSERVER
    LLG_FIXTURE_ROOT="${PROJECT_SOURCE_DIR}")
  target_include_directories(reentry_host PRIVATE ${LUA_INCLUDE_DIRS})
  target_compile_options(reentry_host PRIVATE -UNDEBUG)
  target_link_libraries(reentry_host PRIVATE ${LUA_LIBRARIES} binding_local_whole)
  add_test(NAME ownership_deterministic_recheck COMMAND reentry_host)
  set_tests_properties(ownership_deterministic_recheck PROPERTIES TIMEOUT 30)
endif()
if(BUILD_TESTING)
  # Distinct file/inode forces the loader to instantiate a second module copy.
  add_custom_command(TARGET lua_ghidra POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/loaded-copy"
    COMMAND ${CMAKE_COMMAND} -E copy "$<TARGET_FILE:lua_ghidra>"
      "${CMAKE_BINARY_DIR}/loaded-copy/_native.so")
  add_test(NAME ownership_loaded_copy COMMAND ${LUA_EXECUTABLE}
    ${PROJECT_SOURCE_DIR}/tests/ownership_loaded_copy.lua ${CMAKE_BINARY_DIR})
  set_tests_properties(ownership_loaded_copy PROPERTIES TIMEOUT 30)
endif()
# Runnable first-slice example plus explicit fixture test data, not module APIs.
install(FILES ${PROJECT_SOURCE_DIR}/examples/first_slice.lua
              ${PROJECT_SOURCE_DIR}/examples/core_mutation.lua
              ${PROJECT_SOURCE_DIR}/examples/fixture_manifest.lua
        DESTINATION share/libghidra/examples)
if(BUILD_TESTING)
  add_executable(m3_seeded_host ${PROJECT_SOURCE_DIR}/tests/m3_seeded_host.cpp
    ${PROJECT_SOURCE_DIR}/src/boundary.cpp ${PROJECT_SOURCE_DIR}/src/owner.cpp)
  target_compile_definitions(m3_seeded_host PRIVATE LLG_OWNER LLG_CORE_FIXTURE)
  target_include_directories(m3_seeded_host PRIVATE ${LUA_INCLUDE_DIRS})
  target_compile_options(m3_seeded_host PRIVATE -UNDEBUG)
  target_link_libraries(m3_seeded_host PRIVATE ${LUA_LIBRARIES} binding_local_whole)
  add_test(NAME m3_seeded_core COMMAND m3_seeded_host ${PROJECT_SOURCE_DIR}/tests/m3_seeded.lua ${PROJECT_SOURCE_DIR})
endif()
