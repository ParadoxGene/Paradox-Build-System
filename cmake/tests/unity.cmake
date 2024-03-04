function(paradox_add_unity_testing_lib version)
    get_property(UNITY_TESTING_LIB_EXISTS GLOBAL PROPERTY UNITY_TESTING_LIB_EXISTS_PROPERTY)
    if(NOT UNITY_TESTING_LIB_EXISTS AND PARADOX_LANGUAGE STREQUAL "c")
        set_property(GLOBAL PROPERTY UNITY_TESTING_LIB_EXISTS_PROPERTY ON)
        include(FetchContent)
        FetchContent_Declare(
            Unity
            GIT_REPOSITORY "https://github.com/ThrowTheSwitch/Unity.git"
            GIT_TAG "${version}"
            SOURCE_DIR "${PROJECT_DIR}/modules/Unity")
        FetchContent_Populate(Unity)
        add_subdirectory("${PROJECT_DIR}/modules/Unity" "${CMAKE_BINARY_DIR}/../../unit-tests/unity/")
    endif()
endfunction()

