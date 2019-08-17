cmake_minimum_required(VERSION 3.1)
project(enet C)

set(ENET_DEBUG OFF CACHE BOOL "Enable debug functionality")
set(ENET_STATIC OFF CACHE BOOL "Create a static library")
set(ENET_SHARED OFF CACHE BOOL "Create a shared library")
set(ENET_LZ4 OFF CACHE BOOL "Add support for an optional packet-level compression")

if (ENET_DEBUG)
    add_definitions(-DENET_DEBUG)
endif()

if (ENET_LZ4)
    add_definitions(-DENET_LZ4)
    set(SOURCES lz4/lz4.c)
endif()

if (ENET_STATIC)
    add_library(enet_static STATIC enet.c ${SOURCES})

    if (WIN32)
        target_link_libraries(enet_static winmm ws2_32)
		target_compile_definitions(enet PRIVATE _CRT_SECURE_NO_WARNINGS)
        SET_TARGET_PROPERTIES(enet_static PROPERTIES PREFIX "")
    endif()
endif()

if (ENET_SHARED)
    add_definitions(-DENET_DLL)
    add_library(enet SHARED enet.c ${SOURCES})

    if (WIN32)
        target_link_libraries(enet winmm ws2_32)
		target_compile_definitions(enet PRIVATE _CRT_SECURE_NO_WARNINGS)
        SET_TARGET_PROPERTIES(enet PROPERTIES PREFIX "")
    endif()
endif()
