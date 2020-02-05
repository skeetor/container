cmake_minimum_required(VERSION 3.10)

project(SystemTakeover)

enable_language(VASM)

set(TARGET ${PROJECT_NAME}) 


set(ASM_SOURCES
	takeover.asm
)

set(SOURCES
	main.cpp
	${ASM_SOURCES}
)

add_executable(${TARGET} ${SOURCES})
set_source_files_properties(${ASM_SOURCES} PROPERTIES LANGUAGE VASM)

set(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR}/bin) 
