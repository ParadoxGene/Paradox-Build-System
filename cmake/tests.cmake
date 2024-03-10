function(paradox_add_tests lib_prefix lib_name link_libs)
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