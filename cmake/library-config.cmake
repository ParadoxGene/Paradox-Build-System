if(PARADOX_COMPILER STREQUAL "msvc")
    
elseif(PARADOX_COMPILER STREQUAL "gcc")
    set(GCC ON)
elseif(PARADOX_COMPILER STREQUAL "clang")
    set(Clang ON)
elseif(PARADOX_COMPILER STREQUAL "xcode")
    set(XCode ON)
endif()

if((${CMAKE_BUILD_TYPE} STREQUAL "Release") OR (${CMAKE_BUILD_TYPE} STREQUAL "release"))
    set(PARADOX_RELEASE ON)
elseif((${CMAKE_BUILD_TYPE} STREQUAL "Debug") OR (${CMAKE_BUILD_TYPE} STREQUAL "debug"))
    set(PARADOX_DEBUG ON)
    set(PARADOX_MSVC_DEBUG_FLAGS /W4 /WX)
    set(PARADOX_CLANG_DEBUG_FLAGS -Og -Wpedantic -Wall -Wextra -Werror)
    set(PARADOX_GCC_DEBUG_FLAGS -Og -Wpedantic -Wall -Wextra -Werror)
endif()

if(WIN32)
    if(MSVC)
        set(PARADOX_CXX_DEBUG_FLAGS ${PARADOX_MSVC_DEBUG_FLAGS})
    elseif(Clang)
        set(PARADOX_CXX_DEBUG_FLAGS ${PARADOX_CLANG_DEBUG_FLAGS})
    elseif(GCC)
        set(PARADOX_CXX_DEBUG_FLAGS ${PARADOX_GCC_DEBUG_FLAGS})
    endif()
    set(PARADOX_C_COMPILE_DEFINITIONS ${PARADOX_C_COMPILE_DEFINITIONS} _CRT_SECURE_NO_DEPRECATE)
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

include("${CMAKE_CURRENT_LIST_DIR}/tests/googletest.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/tests/unity.cmake")

# Standard options
function(paradox_library_options lib_name lib_prefix)
    option(${lib_prefix}_BUILD_LIBS "Build the ${lib_name} libraries" ON)
    option(${lib_prefix}_BUILD_C_LIB "Build the ${lib_name} static|shared ${lib_name} c library" ON)
    option(${lib_prefix}_BUILD_CXX_LIB "Build the ${lib_name} static|shared ${lib_name} cpp library" ON)
endfunction()

function(paradox_tests_options lib_prefix)
    option(PARADOX_PLATFORM_BUILD_TESTS "Build the ${lib_name} test cases" OFF)
endfunction()

function(paradox_documentation_options lib_prefix)
    option(PARADOX_PLATFORM_BUILD_DOCS "Build the ${lib_name} documentation" OFF)
endfunction()
# ----------------

function(paradox_add_ext_library lib_name lib_prefix lib_ver)
    paradox_add_ext_library_repo("https://github.com/ParadoxGene/${lib_name}.git" "main" "${PROJECT_DIR}/build/modules/${lib_name}")
    set(${lib_prefix}_BUILD_LIBS ON)
    
    if(PARADOX_LANGUAGE STREQUAL "c")
        set(${lib_prefix}_BUILD_C_LIB ON)
        paradox_get_global(${lib_prefix}_C_LIB)
        if(NOT PARADOX_GLOBAL_${lib_prefix}_C_LIB)
            add_subdirectory("${PROJECT_DIR}/build/modules/${lib_name}" "${CMAKE_BINARY_DIR}/../../${lib_name}")
        endif()
    elseif(PARADOX_LANGUAGE STREQUAL "cpp")
        set(${lib_prefix}_BUILD_CXX_LIB ON)
        paradox_get_global(${lib_prefix}_CXX_LIB)
        if(NOT PARADOX_GLOBAL_${lib_prefix}_CXX_LIB)
            add_subdirectory("${PROJECT_DIR}/build/modules/${lib_name}" "${CMAKE_BINARY_DIR}/../../${lib_name}")
        endif()
    endif()
endfunction()

function(paradox_add_ext_library_repo repo ver dir)
    if(EXISTS "${dir}") 
        execute_process(COMMAND cd ${dir} && git checkout ${ver} && git pull origin)
    else()
        execute_process(COMMAND git clone --branch=${ver} ${repo} ${dir})
    endif()

endfunction()

function(paradox_add_library lib_name lib_prefix)
    set(${lib_prefix}_BUILD_LIBS ON)
    if(${lib_prefix}_BUILD_C_LIB)
        paradox_c_library(${lib_name} ${lib_prefix})
    endif()

    if(${lib_prefix}_BUILD_CXX_LIB)
        paradox_cxx_library(${lib_name} ${lib_prefix})
    endif()
endfunction()

function(paradox_c_library lib_name lib_prefix)
    paradox_get_global(${lib_prefix}_C_LIB)
    if(NOT PARADOX_GLOBAL_${lib_prefix}_C_LIB AND PARADOX_LANGUAGE STREQUAL "c")
        paradox_set_global(${lib_prefix}_C_LIB ON)
        file(GLOB_RECURSE ${lib_prefix}_C_SRC "${PROJECT_DIR}/api/c/${lib_name}/src/**.c")
        add_library(${lib_name} SHARED ${${lib_prefix}_C_SRC})
        set_target_properties(${lib_name} PROPERTIES
            LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/../../paradox-static/$<CONFIG>"
            ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/../../paradox-static/$<CONFIG>"
            RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/../../paradox-shared/$<CONFIG>")

        target_compile_options(${lib_name} PRIVATE ${PARADOX_CXX_COMPILE_FLAGS})
        target_compile_definitions(${lib_name} PRIVATE ${PARADOX_C_COMPILE_DEFINITIONS} ${lib_prefix}_BUILD_DLL)
        target_include_directories(${lib_name} PUBLIC "${PROJECT_DIR}/api/c/${lib_name}/include/")
    endif()
endfunction()

function(paradox_cxx_library lib_name lib_prefix)
    paradox_cxx_library_full_path(${lib_name} ${lib_prefix} "${PROJECT_DIR}")
endfunction()

function(paradox_cxx_library_full_path lib_name lib_prefix lib_path)
    paradox_get_global(${lib_prefix}_CXX_LIB)
    if(NOT PARADOX_GLOBAL_${lib_prefix}_CXX_LIB AND PARADOX_LANGUAGE STREQUAL "cpp")
        paradox_set_global(${lib_prefix}_CXX_LIB ON)
        file(GLOB_RECURSE ${lib_prefix}_CXX_SRC "${lib_path}/api/cpp/${lib_name}/src/**.cpp")
        add_library(${lib_name} SHARED ${${lib_prefix}_CXX_SRC})
        set_target_properties(${lib_name} PROPERTIES
            LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/../../paradox-static/$<CONFIG>"
            ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/../../paradox-static/$<CONFIG>"
            RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/../../paradox-shared/$<CONFIG>")

        target_compile_options(${lib_name} PRIVATE ${PARADOX_CXX_COMPILE_FLAGS})
        target_compile_definitions(${lib_name} PRIVATE ${PARADOX_CXX_COMPILE_DEFINITIONS} ${lib_prefix}_BUILD_DLL)
        target_include_directories(${lib_name} PUBLIC "${lib_path}/api/cpp/${lib_name}/include/")
    endif()
endfunction()

function(paradox_add_tests lib_name lib_prefix link_libs)
    set(${lib_prefix}_BUILD_TESTS ON)
    if(${lib_prefix}_BUILD_TESTS AND PARADOX_LANGUAGE STREQUAL "c")
        paradox_get_global(${lib_prefix}_C_TESTS)
        if(NOT PARADOX_GLOBAL_${lib_prefix}_C_TESTS)
            paradox_set_global(${lib_prefix}_C_TESTS ON)
            paradox_add_unity_testing_lib("master")
            file(GLOB_RECURSE ${lib_prefix}_TESTS_C_SRC "${PROJECT_DIR}/api/c/${lib_name}/tests/**.c")
            add_executable(${lib_name}-unit-tests ${${lib_prefix}_TESTS_C_SRC})
            set_target_properties(${lib_name}-unit-tests PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/../../${lib_name}-unit-tests/$<CONFIG>")

            target_include_directories(${lib_name}-unit-tests PRIVATE "${PROJECT_DIR}/api/c/${lib_name}/include")
            target_link_libraries(${lib_name}-unit-tests PRIVATE "${lib_name}" ${linklibs} unity::framework)
            target_link_directories(${lib_name}-unit-tests PRIVATE "${CMAKE_BINARY_DIR}/../../paradox-static/$<CONFIG>")

            paradox_add_tests_resources(${lib_name} "${link_libs}")
        endif()
    endif()

    if(${lib_prefix}_BUILD_TESTS AND PARADOX_LANGUAGE STREQUAL "cpp")
        paradox_get_global(${lib_prefix}_CXX_TESTS)
        if(NOT PARADOX_GLOBAL_${lib_prefix}_CXX_TESTS)
            paradox_set_global(${lib_prefix}_CXX_TESTS ON)
            paradox_add_google_tests_lib("v1.14.0")

            enable_testing()

            file(GLOB_RECURSE ${lib_prefix}_TESTS_CXX_SRC "${PROJECT_DIR}/api/cpp/${lib_name}/tests/**.cpp")
            add_executable(${lib_name}-unit-tests ${${lib_prefix}_TESTS_CXX_SRC})
            set_target_properties(${lib_name}-unit-tests PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/../../${lib_name}-unit-tests/$<CONFIG>")

            target_include_directories(${lib_name}-unit-tests PRIVATE "${PROJECT_DIR}/api/cpp/${lib_name}/include")
            target_link_libraries(${lib_name}-unit-tests PRIVATE "${lib_name}" ${linklibs} GTest::gtest_main)
            target_link_directories(${lib_name}-unit-tests PRIVATE "${CMAKE_BINARY_DIR}/../../paradox-static/$<CONFIG>")
            
            paradox_add_tests_resources(${lib_name} "${link_libs}")

            include(GoogleTest)
            gtest_discover_tests(${lib_name}-unit-tests)
        endif()
    endif()
endfunction()

function(paradox_add_tests_resources lib_name shared_libs)
    string(REPLACE " " ";" ${lib_name}_shared_libs ${shared_libs})
    foreach(${lib_name}_shared_lib ${${lib_name}_shared_libs})
        paradox_set_shared_lib_name(${lib_name}_shared_lib)
        get_property(${lib_name}_shared_lib GLOBAL PROPERTY ${lib_name}_shared_lib_property)
        set(${lib_name}_shared_lib_copy_command
            COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_BINARY_DIR}/../../paradox-shared/$<CONFIG>/${${lib_name}_shared_lib}" "$<TARGET_FILE_DIR:${lib_name}-unit-tests>/${${lib_name}_shared_lib}"
            ${${lib_name}_shared_lib_copy_command})
    endforeach()

    if(WIN32)
        add_custom_command(TARGET ${lib_name}-unit-tests POST_BUILD 
            ${${lib_name}_shared_lib_copy_command}
            COMMENT "Copying shared libraries to ${lib_name} bin folder")
    endif()
endfunction()

function(paradox_set_shared_lib_name shared_lib_var)
    if(WIN32)
        if(MSVC OR Clang)
            set_property(GLOBAL PROPERTY ${shared_lib_var}_property ${${shared_lib_var}}.dll)
            get_property(${shared_lib_var} GLOBAL PROPERTY ${shared_lib_var}_property)
        elseif(GCC)
            set_property(GLOBAL PROPERTY ${shared_lib_var}_property lib${${shared_lib_var}}.dll)
            get_property(${shared_lib_var} GLOBAL PROPERTY ${shared_lib_var}_property)
        endif()
    elseif(LINUX)
        if(Clang OR GCC)
            set_property(GLOBAL PROPERTY ${shared_lib_var}_property lib${${shared_lib_var}}.so)
            get_property(${shared_lib_var} GLOBAL PROPERTY ${shared_lib_var}_property)
        endif()
    elseif(APPLE)
        if(Clang OR GCC)
            # TODO
        endif()
    endif()
endfunction()

function(paradox_set_global prefix value)
    set_property(GLOBAL PROPERTY PARADOX_GLOBAL_${prefix} ${value})
endfunction()

function(paradox_get_global prefix)
    get_property(PARADOX_GLOBAL_${prefix} GLOBAL PROPERTY PARADOX_GLOBAL_${prefix}_PROPERTY)
endfunction()