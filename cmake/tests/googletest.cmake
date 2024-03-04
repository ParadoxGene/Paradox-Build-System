function(paradox_add_google_tests_lib version)
    get_property(GOOGLE_TESTS_LIB_EXISTS GLOBAL PROPERTY GOOGLE_TESTS_LIB_EXISTS_PROPERTY)
    if(NOT GOOGLE_TESTS_LIB_EXISTS AND PARADOX_LANGUAGE STREQUAL "cpp")
        set_property(GLOBAL PROPERTY GOOGLE_TESTS_LIB_EXISTS_PROPERTY ON)
        include(FetchContent)
        set(gtest_force_shared_crt on)
        FetchContent_Declare(
            googletest
            GIT_REPOSITORY "https://github.com/google/googletest.git"
            GIT_TAG ${version}
            SOURCE_DIR "${PROJECT_DIR}/modules/googletest")
        FetchContent_Populate(googletest)
        add_subdirectory("${PROJECT_DIR}/modules/googletest" "${CMAKE_BINARY_DIR}/../../unit-tests/googletests/")
    endif()
endfunction()