set(ENET_LIB_NAME enet)
cmake_minimum_required(VERSION 3.1)
project(${ENET_LIB_NAME} LANGUAGES C)

set(ENET_DEBUG OFF CACHE BOOL "Do debug things")
set(ENET_PLUGIN_DIR_BASE "${CMAKE_CURRENT_SOURCE_DIR}/Unity/Plugins")
set(ENET_PLUGIN_DIR_ARCH "x86_64")
set(ENET_DEFINES -DENET_NO_PRAGMA_LINK -DENET_DLL)
set(ENET_DEPS "")
set(ENET_SRCDIR "../Source/Native")
set(ENET_SRCS
        ${ENET_SRCDIR}/enet.c
        ${ENET_SRCDIR}/enet.h
        ${ENET_SRCDIR}/custom/enet_logging.h
	${ENET_SRCDIR}/custom/enet_iosFixes.h
)

if(ENET_DEBUG)
    list(APPEND ENET_DEFINES -DENET_DEBUG)
endif()

include_directories(${ENET_SRCDIR})
add_library(${ENET_LIB_NAME} STATIC ${ENET_SRCS})
target_link_libraries(${ENET_LIB_NAME} ${ENET_DEPS})
target_compile_definitions(${ENET_LIB_NAME} PRIVATE ${ENET_DEFINES})

set(ENET_PLUGIN_DIR ${ENET_PLUGIN_DIR_BASE}/${ENET_PLUGIN_DIR_ARCH})
set(ENET_LIB_PREFIX ${CMAKE_SHARED_LIBRARY_PREFIX})
string(REPLACE ".dylib" ".bundle" ENET_LIB_SUFFIX ${CMAKE_SHARED_LIBRARY_SUFFIX})
set(ENET_PLUGIN_NAME ${ENET_LIB_PREFIX}${ENET_LIB_NAME}${ENET_LIB_SUFFIX})

file(MAKE_DIRECTORY ${ENET_PLUGIN_DIR})
add_custom_command(
    TARGET ${ENET_LIB_NAME}
    POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy
        $<TARGET_FILE:${ENET_LIB_NAME}>
        ${ENET_PLUGIN_DIR}/${ENET_PLUGIN_NAME}
)

