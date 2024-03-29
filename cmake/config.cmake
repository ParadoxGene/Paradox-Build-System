if("${PARADOX_COMPILER}" STREQUAL "msvc")
    set(MSVC ON)
elseif("${PARADOX_COMPILER}" STREQUAL "gcc")
    set(GCC ON)
elseif("${PARADOX_COMPILER}" STREQUAL "clang")
    set(Clang ON)
elseif("${PARADOX_COMPILER}" STREQUAL "xcode")
    set(XCode ON)
else()
    message(FATAL_ERROR "Please set PARADOX_COMPILER to either msvc, gcc, clang, or xcode")
endif()

if("${PARADOX_LANGUAGE}" STREQUAL "cpp")
        set(PARADOX_BUILD_LANG CXX)
        set(PARADOX_BUILD_LANG_EXT "cpp")
elseif("${PARADOX_LANGUAGE}" STREQUAL "c")
    set(PARADOX_BUILD_LANG C)
    set(PARADOX_BUILD_LANG_EXT "c")
elseif("${PARADOX_LANGUAGE}" STREQUAL "swift")
    set(PARADOX_BUILD_LANG Swift)
    set(PARADOX_BUILD_LANG_EXT "swift")
else()
    message(FATAL_ERROR "Please set PARADOX_LANGUAGE to either cpp, c, or swift")
endif()

if((${CMAKE_BUILD_TYPE} STREQUAL "Release") OR (${CMAKE_BUILD_TYPE} STREQUAL "release"))
    set(PARADOX_RELEASE ON)
elseif((${CMAKE_BUILD_TYPE} STREQUAL "Debug") OR (${CMAKE_BUILD_TYPE} STREQUAL "debug"))
    set(PARADOX_DEBUG ON)
    set(PARADOX_MSVC_DEBUG_FLAGS /W4 /WX)
    set(PARADOX_CLANG_DEBUG_FLAGS -Og -Wpedantic -Wall -Wextra -Werror)
    set(PARADOX_GCC_DEBUG_FLAGS -Og -Wpedantic -Wall -Wextra -Werror)
else()
    message(FATAL_ERROR "Please set CMAKE_BUILD_TYPE to either Release or Debug" )
endif()

if(WIN32)
    if(MSVC)
        list(APPEND PARADOX_C_DEBUG_FLAGS ${PARADOX_MSVC_DEBUG_FLAGS})
        list(APPEND PARADOX_CXX_DEBUG_FLAGS ${PARADOX_MSVC_DEBUG_FLAGS})
    elseif(Clang)
        list(APPEND PARADOX_C_DEBUG_FLAGS ${PARADOX_CLANG_DEBUG_FLAGS})
        list(APPEND PARADOX_CXX_DEBUG_FLAGS ${PARADOX_CLANG_DEBUG_FLAGS})
    elseif(GCC)
        list(APPEND PARADOX_C_DEBUG_FLAGS ${PARADOX_GCC_DEBUG_FLAGS})
        list(APPEND PARADOX_CXX_DEBUG_FLAGS ${PARADOX_GCC_DEBUG_FLAGS})
    endif()
    list(APPEND PARADOX_C_COMPILE_DEFINITIONS -D_CRT_SECURE_NO_DEPRECATE)
    list(APPEND PARADOX_CXX_COMPILE_DEFINITIONS -D_CRT_SECURE_NO_DEPRECATE)
    add_definitions(${PARADOX_${PARADOX_BUILD_LANG}_COMPILE_DEFINITIONS})
elseif(LINUX)
    if(Clang)
        set(PARADOX_CXX_DEBUG_FLAGS ${PARADOX_CLANG_DEBUG_FLAGS})
    elseif(GCC)
        set(PARADOX_CXX_DEBUG_FLAGS ${PARADOX_GCC_DEBUG_FLAGS})
    endif()
elseif(APPLE)
    if(XCode)
        set(PARADOX_SWIFT_DEBUG_FLAGS ${PARADOX_XCODE_DEBUG_FLAGS})
    elseif(Clang)
        set(PARADOX_CXX_DEBUG_FLAGS ${PARADOX_CLANG_DEBUG_FLAGS})
    elseif(GCC)
        set(PARADOX_CXX_DEBUG_FLAGS ${PARADOX_GCC_DEBUG_FLAGS})
    endif()
endif()

if(PARADOX_RELEASE)
    set(PARADOX_CXX_COMPILE_FLAGS ${PARADOX_CXX_COMPILE_FLAGS} ${PARADOX_CXX_RELEASE_FLAGS})
elseif(PARADOX_DEBUG)
    set(PARADOX_CXX_COMPILE_FLAGS ${PARADOX_CXX_COMPILE_FLAGS} ${PARADOX_CXX_DEBUG_FLAGS})
endif()

if(MSVC)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${CMAKE_BUILD_TYPE} "${CMAKE_BINARY_DIR}/../../paradox-static")
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/../../paradox-static")
else()
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${CMAKE_BUILD_TYPE} "${CMAKE_BINARY_DIR}/../../paradox-shared/${CMAKE_BUILD_TYPE}")
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/../../paradox-shared/${CMAKE_BUILD_TYPE}")
endif()

if(MSVC)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${CMAKE_BUILD_TYPE} "${CMAKE_BINARY_DIR}/../../paradox-static")
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/../../paradox-static")
else()
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${CMAKE_BUILD_TYPE} "${CMAKE_BINARY_DIR}/../../paradox-static/${CMAKE_BUILD_TYPE}")
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/../../paradox-static/${CMAKE_BUILD_TYPE}")
endif()

if(MSVC)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${CMAKE_BUILD_TYPE} "${CMAKE_BINARY_DIR}/../../paradox-shared")
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/../../paradox-shared")
else()
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${CMAKE_BUILD_TYPE} "${CMAKE_BINARY_DIR}/../../paradox-shared/${CMAKE_BUILD_TYPE}")
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/../../paradox-shared/${CMAKE_BUILD_TYPE}")
endif()