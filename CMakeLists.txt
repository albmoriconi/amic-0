# Define project
project(amic-0)

# Define required cmake version
cmake_minimum_required(VERSION 2.8)

# Include macros
include(cmake/vhdl_macros.cmake)

# Enable testing
enable_testing()

# Add custom targets
add_custom_target(check COMMAND ${CMAKE_CTEST_COMMAND})

# Parse VHDL source
add_subdirectory(src/main/vhdl/)
add_subdirectory(src/test/vhdl/)

add_custom_target(index ALL COMMAND ghdl -i --workdir=${CMAKE_CURRENT_BINARY_DIR} ${VHDL_SOURCES})

# Add compile test target
set(CTEST_OUTPUT_ON_FAILURE 1)
