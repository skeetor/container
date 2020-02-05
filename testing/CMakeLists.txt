cmake_minimum_required(VERSION 3.10)
project(TestProjects)

set(UTILSLIB_PATH "${CMAKE_SOURCE_DIR}/.." CACHE STRING "Path to lib")
set (UTILSLIB_DIR "${UTILSLIB_PATH}/utilslib")

set (CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${UTILSLIB_DIR}/CMake")
include(AmigaCompilerOptions)

set(CMAKE_CXX_STANDARD 14)

include_directories(${UTILSLIB_PATH})
link_directories(${UTILSLIB_PATH}/lib/${CMAKE_BUILD_TYPE}) 

add_subdirectory(JoystickTest)
add_subdirectory(UtilslibTest)
add_subdirectory(SystemTakeover)
