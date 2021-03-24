#
# Copyright (c) 2019 Chris Burns <chris@kitty.city>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

set(ENET_LIB_NAME enet)
cmake_minimum_required(VERSION 3.1)
project(${ENET_LIB_NAME} LANGUAGES C)

set(ENET_DEBUG OFF CACHE BOOL "Enables debug and trace logging")
set(ENET_PLUGIN_DIR_BASE "${CMAKE_CURRENT_SOURCE_DIR}/Unity/Plugins")
set(ENET_PLUGIN_DIR_ARCH "x86_64")
set(ENET_DEFINES -DENET_NO_PRAGMA_LINK -DENET_DLL)
set(ENET_DEPS "")
set(ENET_SRCDIR "Source/Native")
set(ENET_SRCS
	${ENET_SRCDIR}/enet.c
	${ENET_SRCDIR}/enet.h
	${ENET_SRCDIR}/custom/enet_logging.h
)

if(ENET_DEBUG)
    list(APPEND ENET_DEFINES -DENET_DEBUG)
endif()

if(MSVC)
	set(CompilerFlags
        CMAKE_C_FLAGS
        CMAKE_C_FLAGS_RELEASE
        CMAKE_C_FLAGS_DEBUG        
    )
	foreach(CompilerFlag ${CompilerFlags})
	  string(REPLACE "/MD" "/MT" ${CompilerFlag} "${${CompilerFlag}}")
	endforeach()

    list(APPEND ENET_DEFINES -D_CRT_SECURE_NO_WARNINGS)
	list(APPEND ENET_DEPS Ws2_32 Winmm)
endif()

include_directories(${ENET_SRCDIR})
add_library(${ENET_LIB_NAME} SHARED ${ENET_SRCS})
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
