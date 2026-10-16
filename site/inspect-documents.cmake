# MIT Copyright 2026 Salvador Fandiño.
# Read-only inspection for freshness checks; selection remains in the package file.
cmake_minimum_required(VERSION 3.26)
include("${CMAKE_CURRENT_LIST_DIR}/../cmake/PackageDocuments.cmake")
foreach(path IN LISTS LLG_PACKAGE_DOCUMENTS)
  execute_process(COMMAND "${CMAKE_COMMAND}" -E echo "${path}" COMMAND_ERROR_IS_FATAL ANY)
endforeach()
execute_process(COMMAND "${CMAKE_COMMAND}" -E echo "--examples--" COMMAND_ERROR_IS_FATAL ANY)
foreach(path IN LISTS LLG_PACKAGE_EXAMPLES)
  execute_process(COMMAND "${CMAKE_COMMAND}" -E echo "${path}" COMMAND_ERROR_IS_FATAL ANY)
endforeach()
