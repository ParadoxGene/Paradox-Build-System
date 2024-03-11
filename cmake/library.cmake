# Adds a library from github
macro(paradox_add_git_library lib_prefix lib_name lib_ver)
    if(PARADOX_BUILD_LIB)
        # Download|Update the git repository
        set(${lib_prefix}_git_repo "https://github.com/ParadoxGene/${lib_name}.git")
        set(${lib_prefix}_git_dir "${PROJECT_DIR}/build/modules/${lib_name}")
        
        if(EXISTS ${${lib_prefix}_git_dir}) 
            execute_process(COMMAND cd ${${lib_prefix}_git_dir} && git checkout ${lib_ver} && git pull origin)
        else()
            execute_process(COMMAND git clone --branch=${lib_ver} ${${lib_prefix}_git_repo} ${${lib_prefix}_git_dir})
        endif()
        # ----------------------------------

        # Flag for external library
        set(${lib_prefix}_EXTERNAL ON)
        paradox_add_library(${lib_prefix} ${lib_name} ${${lib_prefix}_git_dir})
    endif()
endmacro()

# Adds a library from a directory
macro(paradox_add_library lib_prefix lib_name lib_dir)
    if(PARADOX_BUILD_LIB)
        paradox_get_global(${lib_prefix}_${PARADOX_BUILD_LANG}_LIB)
        if(NOT PARADOX_GLOBAL_${lib_prefix}_${PARADOX_BUILD_LANG}_LIB)
            paradox_set_global(${lib_prefix}_${PARADOX_BUILD_LANG}_LIB ON)

            # Grabs the external library build
            if(${lib_prefix}_EXTERNAL)
                set(${lib_prefix}_DIR ${lib_dir})
                include("${${lib_prefix}_DIR}/library.cmake")
            endif()

            # Build process for the library
            set(${lib_prefix}_${PARADOX_BUILD_LANG}_INC "${lib_dir}/api/${PARADOX_BUILD_LANG_EXT}/${lib_name}/include/" ${${lib_prefix}_${PARADOX_BUILD_LANG}_INC})
            file(GLOB_RECURSE ${lib_prefix}_${PARADOX_BUILD_LANG}_SRC "${lib_dir}/api/${PARADOX_BUILD_LANG_EXT}/${lib_name}/src/**.${PARADOX_BUILD_LANG_EXT}")
            
            add_library(${lib_name} SHARED ${${lib_prefix}_${PARADOX_BUILD_LANG}_SRC})
            target_compile_options(${lib_name} PRIVATE ${PARADOX_${PARADOX_BUILD_LANG}_COMPILE_FLAGS})
            target_compile_definitions(${lib_name} PRIVATE ${PARADOX_${PARADOX_BUILD_LANG}_COMPILE_DEFINITIONS} ${lib_prefix}_BUILD_DLL)
            target_include_directories(${lib_name} PRIVATE ${${lib_prefix}_${PARADOX_BUILD_LANG}_INC})
            
            target_link_directories(${lib_name} PRIVATE ${CMAKE_LIBRARY_OUTPUT_DIRECTORY} ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY})
            target_link_libraries(${lib_name} PRIVATE ${${lib_prefix}_${PARADOX_BUILD_LANG}_LINK_LIBS})
            target_link_options(${lib_name} PRIVATE ${${lib_prefix}_${PARADOX_BUILD_LANG}_LINK_OPTIONS})
        endif()
    endif()
endmacro()

macro(paradox_append_src_include lib_prefix libs)
    foreach(lib ${libs})
        list(APPEND ${lib_prefix}_${PARADOX_BUILD_LANG}_INC "${PROJECT_DIR}/api/${PARADOX_BUILD_LANG_EXT}/${lib}/include")
    endforeach()
endmacro()

macro(paradox_append_git_include lib_prefix libs)
    foreach(lib ${libs})
        list(APPEND ${lib_prefix}_${PARADOX_BUILD_LANG}_INC "${PROJECT_DIR}/build/modules/${lib}/api/${PARADOX_BUILD_LANG_EXT}/${lib}/include")
    endforeach()
endmacro()

macro(paradox_append_link_lib lib_prefix libs)
    foreach(lib ${libs})
        list(APPEND ${lib_prefix}_${PARADOX_BUILD_LANG}_LINK_LIBS ${lib})
        if(PARADOX_BUILD_SHARED_LIBS)
            list(APPEND ${lib_prefix}_${PARADOX_BUILD_LANG}_SHARED_LIBS ${lib})
        endif()
    endforeach()
endmacro()