cmake_minimum_required(VERSION 3.17)
project(verilator)

set(CMAKE_CXX_STANDARD 14)

find_package(Verilator REQUIRED)


message(${CMAKE_SYSTEM_NAME})
if(${CMAKE_SYSTEM_NAME} STREQUAL Linux)
  set(VERILATOR_INCLUDE_DIR /usr/share/verilator/include)
else(${CMAKE_SYSTEM_NAME} STREQUAL Linux)
  set(VERILATOR_INCLUDE_DIR  /usr/local/Cellar/verilator/4.030/share/verilator/include)
endif(${CMAKE_SYSTEM_NAME} STREQUAL Linux)
include_directories(${VERILATOR_INCLUDE_DIR})
include_directories(obj_dir)

add_executable(sim_tiny_rv
        ${VERILATOR_INCLUDE_DIR}/verilated.cpp
        ${VERILATOR_INCLUDE_DIR}/verilated_vcd_c.cpp
        src/main.cpp)

target_link_libraries(sim_tiny_rv ${CMAKE_CURRENT_SOURCE_DIR}/obj_dir/Vtiny_rv__ALL.a)

