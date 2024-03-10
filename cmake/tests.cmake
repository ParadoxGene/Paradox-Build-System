macro(paradox_add_tests lib_prefix lib_name)
    if(PARADOX_BUILD_TESTS)
    paradox_get_global(${lib_prefix}_${PARADOX_BUILD_LANG}_TESTS)
    if(NOT PARADOX_GLOBAL_${lib_prefix}_${PARADOX_BUILD_LANG}_TESTS)
        paradox_set_global(${lib_prefix}_${PARADOX_BUILD_LANG}_TESTS ON)
            if("${PARADOX_BUILD_LANG}" STREQUAL "C")
                paradox_add_unity_testing_lib("master")
                set(${lib_prefix}_${PARADOX_BUILD_LANG}_LINK_LIBS ${${lib_prefix}_LINK_LIBS} unity::framework)
            elseif("${PARADOX_BUILD_LANG}" STREQUAL "CXX")
                paradox_add_google_tests_lib("v1.14.0")
                enable_testing()
                set(${lib_prefix}_${PARADOX_BUILD_LANG}_LINK_LIBS ${${lib_prefix}_LINK_LIBS} GTest::gtest_main)
            endif()
            file(GLOB_RECURSE ${lib_prefix}_TESTS_${PARADOX_BUILD_LANG}_SRC "${PROJECT_DIR}/api/${PARADOX_BUILD_LANG_EXT}/${lib_name}/tests/**.${PARADOX_BUILD_LANG_EXT}")
            if(NOT ("${${lib_prefix}_TESTS_${PARADOX_BUILD_LANG}_SRC}" STREQUAL ""))
                add_executable(${lib_name}-unit-tests ${${lib_prefix}_TESTS_${PARADOX_BUILD_LANG}_SRC})
                set_target_properties(${lib_name}-unit-tests PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/../../${lib_name}-unit-tests/$<CONFIG>")
                target_include_directories(${lib_name}-unit-tests PRIVATE ${${lib_prefix}_${PARADOX_BUILD_LANG}_INC})
                target_link_directories(${lib_name}-unit-tests PRIVATE ${CMAKE_LIBRARY_OUTPUT_DIRECTORY} ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY})
                target_link_libraries(${lib_name}-unit-tests PRIVATE ${lib_name} ${${lib_prefix}_${PARADOX_BUILD_LANG}_LINK_LIBS})
                target_link_options(${lib_name}-unit-tests PRIVATE ${${lib_prefix}_${PARADOX_BUILD_LANG}_LINK_OPTIONS})

                paradox_add_tests_resources(${lib_prefix} ${lib_name})

                if("${PARADOX_BUILD_LANG}" STREQUAL "CXX")
                    include(GoogleTest)
                    gtest_discover_tests(${lib_name}-unit-tests)
                endif()
            endif()
        endif()
    endif()
endmacro()

macro(paradox_add_tests_resources lib_prefix lib_name)
    string(REPLACE " " ";" ${lib_name}_${PARADOX_BUILD_LANG}_shared_libs ${lib_prefix}_${PARADOX_BUILD_LANG}_SHARED_LIBS)
    foreach(${lib_name}_${PARADOX_BUILD_LANG}_shared_lib ${${lib_name}_${PARADOX_BUILD_LANG}_shared_libs})
        paradox_set_shared_lib_name(${lib_name}_${PARADOX_BUILD_LANG}_shared_lib)
        get_property(${lib_name}_${PARADOX_BUILD_LANG}_shared_lib GLOBAL PROPERTY ${lib_name}_${PARADOX_BUILD_LANG}_shared_lib_property)
        set(${lib_name}_${PARADOX_BUILD_LANG}_shared_lib_copy_command
            COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_BINARY_DIR}/../../paradox-shared/$<CONFIG>/${${lib_name}_${PARADOX_BUILD_LANG}_shared_lib}" "$<TARGET_FILE_DIR:${lib_name}-unit-tests>/${${lib_name}_${PARADOX_BUILD_LANG}_shared_lib}"
            ${${lib_name}_${PARADOX_BUILD_LANG}_shared_lib_copy_command})
    endforeach()

    if(WIN32)
        add_custom_command(TARGET ${lib_name}-unit-tests POST_BUILD 
            ${${lib_name}_${PARADOX_BUILD_LANG}_shared_lib_copy_command}
            COMMENT "Copying shared libraries to ${lib_name} bin folder")
    endif()
endmacro()

macro(paradox_set_shared_lib_name shared_lib_var)
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
endmacro()