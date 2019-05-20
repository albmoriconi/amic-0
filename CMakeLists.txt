# Define project
project(amic-0)

# Define required cmake version
cmake_minimum_required(VERSION 2.8)

# Include macros
include(cmake/vhdl_macros.cmake)

# Enable testing
enable_testing()

# Add test target
add_custom_target(check COMMAND ${CMAKE_CTEST_COMMAND})

# Output default values
file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/generated_src/")
add_custom_target(assemble_microprogram COMMAND mal ${PROJECT_SOURCE_DIR}/src/main/mal/ajvm.mal -f text -o generated_src/ajvm.txt)
add_custom_target(assemble_program COMMAND ajvm ${PROJECT_SOURCE_DIR}/src/main/ajvm/program.ajvm -f text -o generated_src/program.txt)
add_custom_target(create_control_store COMMAND python3 ${PROJECT_SOURCE_DIR}/util/python/words_to_hdl.py ${CMAKE_BINARY_DIR}/generated_src/ajvm.txt ${PROJECT_SOURCE_DIR}/src/main/vhdl/control_store.vhd DEPENDS assemble_microprogram)
add_custom_target(create_ram COMMAND python3 ${PROJECT_SOURCE_DIR}/util/python/words_to_hdl.py ${CMAKE_BINARY_DIR}/generated_src/program.txt ${PROJECT_SOURCE_DIR}/src/main/vhdl/dp_ar_ram.vhd DEPENDS assemble_program)
add_custom_target(rebuild_defaults DEPENDS create_control_store create_ram)

# Parse VHDL source
add_subdirectory(src/main/vhdl/)
add_subdirectory(src/test/vhdl/)

# Add index target
add_custom_target(index ALL COMMAND ghdl -i --workdir=${CMAKE_CURRENT_BINARY_DIR} ${VHDL_SOURCES})

# Add compile test target
set(CTEST_OUTPUT_ON_FAILURE 1)
