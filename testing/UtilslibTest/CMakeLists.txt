cmake_minimum_required(VERSION 3.14)
project(UtilslibTest)

set(TARGET ${PROJECT_NAME}) 

set(SOURCES
	main.cpp
	TestLibrary.cpp
	TestVector.cpp
)

include_directories(${CMAKE_SOURCE_DIR}/libsrc)

add_executable(${TARGET} ${SOURCES})

set(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR}/bin) 

target_link_libraries(${TARGET}
	utils
) 