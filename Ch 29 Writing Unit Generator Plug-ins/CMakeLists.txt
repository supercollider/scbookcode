cmake_minimum_required (VERSION 3.5)

set(PROJECT "Flanger")
message(STATUS "Project name is ${PROJECT}")
project (${PROJECT})

# Specify the source file
set(FILENAME "Figure_29-10_Flanger_2.cpp") # old-style version
# set(FILENAME "Figure_29-10b_Flanger_2 C++ interface.cpp") # modern C++ version

include (CheckCXXCompilerFlag)

# set default build type to Release
if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type" FORCE)
endif()
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")

set(SC_PATH "" CACHE PATH "Path to SuperCollider source code")
message(STATUS "SC_PATH: ${SC_PATH}")
include_directories(${SC_PATH}/include/plugin_interface)
include_directories(${SC_PATH}/include/common)
include_directories(${SC_PATH}/common)

if (WIN32)
    set(SC_INSTALLDIR "$ENV{LOCALAPPDATA}/SuperCollider/Extensions/" CACHE PATH "Installation directoy")
elseif(APPLE)
    set(SC_INSTALLDIR "~/Library/Application Support/SuperCollider/Extensions/" CACHE PATH "Installation directoy")
else()
    set(SC_INSTALLDIR "~/.local/share/SuperCollider/Extensions/" CACHE PATH "Installation directoy")
endif()
message(STATUS "SC_INSTALLDIR: ${SC_INSTALLDIR}")

option(SUPERNOVA "Build plugins for supernova" OFF)
message(STATUS "Build Supernova version: ${SUPERNOVA}")

# no library prefix!
set(CMAKE_SHARED_MODULE_PREFIX "")
# set plugin extension
if (APPLE OR WIN32)
    set(CMAKE_SHARED_MODULE_SUFFIX ".scx")
endif()

if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    set(CMAKE_COMPILER_IS_CLANG 1)
endif()

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_COMPILER_IS_CLANG)
    # hide all symbols by default
    add_definitions(-fvisibility=hidden)

    CHECK_CXX_COMPILER_FLAG(-msse HAS_SSE)
    if (HAS_SSE)
        add_compile_options(-msse)
    endif()

    CHECK_CXX_COMPILER_FLAG(-msse2 HAS_SSE2)
    if (HAS_SSE2)
        add_compile_options(-msse2)
    endif()

    # it's safe to assume at least SSE3
    CHECK_CXX_COMPILER_FLAG(-msse3 HAS_SSE3)
    if (HAS_SSE3)
        add_compile_options(-msse3)
    endif()

    CHECK_CXX_COMPILER_FLAG(-mfpmath=sse HAS_FPMATH_SSE)
    if (HAS_FPMATH_SSE)
        add_compile_options(-mfpmath=sse)
    endif()

    option(NATIVE "Optimize for this machine (not portable!)" OFF)
    if (NATIVE)
        add_compile_options(-march=native)
    endif()

    if (CMAKE_COMPILER_IS_CLANG)
        add_compile_options(-stdlib=libc++)
    endif()
endif()

if(MINGW)
    add_compile_options(-mstackrealign)
endif()

add_library(${PROJECT} MODULE ${FILENAME})

if(SUPERNOVA)
    add_library(${PROJECT}_supernova MODULE ${FILENAME})
    target_compile_definitions(${PROJECT}_supernova PRIVATE SUPERNOVA)
    target_include_directories(${PROJECT}_supernova PRIVATE ${SC_PATH}/external_libraries/nova-tt)
    # for <boost/atomic.hpp>
    target_include_directories(${PROJECT}_supernova PRIVATE ${SC_PATH}/external_libraries/boost)
endif()

# installation

install(TARGETS ${PROJECT} DESTINATION "${SC_INSTALLDIR}/${PROJECT}/plugins")

if (SUPERNOVA)
    install(TARGETS ${PROJECT}_supernova DESTINATION "${SC_INSTALLDIR}/${PROJECT}/plugins")
endif()

install(FILES "Flanger.sc" DESTINATION "${SC_INSTALLDIR}/${PROJECT}/classes")
install(FILES "Flanger.schelp" DESTINATION "${SC_INSTALLDIR}/${PROJECT}/HelpSource/Classes")
install(FILES "README.md" "LICENSE.txt" DESTINATION "${SC_INSTALLDIR}/${PROJECT}")
