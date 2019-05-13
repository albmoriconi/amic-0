# Copyright 2017 Pedro Cuadra <pjcuadra@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Add test sources macro
macro (add_test_sources)
    file (RELATIVE_PATH _relPath "${PROJECT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}")
    foreach (_src ${ARGN})
        if (_relPath)
            set(FILE_SRC "${_relPath}/${_src}")
        else()
            set(FILE_SRC "${_src}")
        endif()

        message("File was ${FILE_SRC}")
        message("Entity was ${_src}")
        string(REGEX REPLACE ".vhdl?$" "" TEST_NAME "${FILE_SRC}")
        string(REGEX REPLACE "/" "." TEST_NAME "${TEST_NAME}")
        string(REGEX REPLACE ".vhdl?$" "" ENTITY_NAME "${_src}")
        message("File is ${TEST_NAME}")
        message("Entity is ${ENTITY_NAME}")
        file (RELATIVE_PATH TEST_REL_PATH "${PROJECT_SOURCE_DIR}/test" "${CMAKE_CURRENT_SOURCE_DIR}")
        set(TRACE_PATH "${CMAKE_BINARY_DIR}/trace/${TEST_REL_PATH}")
        file(MAKE_DIRECTORY ${TRACE_PATH})
        set(TRACE_PATH "${TRACE_PATH}/${ENTITY_NAME}.vcd")

        add_custom_target("${TEST_NAME}" COMMAND ghdl -m --workdir="${CMAKE_BINARY_DIR}" ${ENTITY_NAME} DEPENDS index)
        list (APPEND VHDL_SOURCES "${CMAKE_SOURCE_DIR}/${FILE_SRC}")
        add_test(NAME "${TEST_NAME}" COMMAND ghdl -r --workdir="${CMAKE_BINARY_DIR}" "${ENTITY_NAME}" --vcd=${TRACE_PATH})

        add_dependencies(check "${TEST_NAME}")

        # message("-- Adding VHDL Test: ${CMAKE_SOURCE_DIR}/${FILE_SRC}")
    endforeach()
    if (_relPath)
        # propagate SRCS to parent directory
        set (VHDL_SOURCES ${VHDL_SOURCES} PARENT_SCOPE)
    endif()
endmacro()

# Add source directory macro
macro (add_test_sources_directory)
  file (RELATIVE_PATH _relPath "${PROJECT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}")
  foreach (_src ${ARGN})
      add_subdirectory(${_src})
      # propagate SRCS to parent directory
      set (VHDL_SOURCES ${VHDL_SOURCES} PARENT_SCOPE)
  endforeach()
endmacro()
