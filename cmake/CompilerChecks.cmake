include(CheckCXXCompilerFlag)

function(env_set var_name default_value type docstring)
  set(val ${default_value})
  if(DEFINED ENV{${var_name}})
    set(val $ENV{${var_name}})
  endif()
  set(${var_name} ${val} CACHE ${type} "${docstring}")
endfunction()

function(default_linker var_name)
  if(APPLE)
    set("${var_name}" "DEFAULT" PARENT_SCOPE)
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    find_program(lld_path ld.lld "Path to LLD - is only used to determine default linker")
    if(lld_path)
      set("${var_name}" "LLD" PARENT_SCOPE)
    else()
      set("${var_name}" "DEFAULT" PARENT_SCOPE)
    endif()
  else()
    set("${var_name}" "DEFAULT" PARENT_SCOPE)
  endif()
endfunction()

function(use_libcxx out)
  if(APPLE OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    set("${out}" ON PARENT_SCOPE)
  else()
    set("${out}" OFF PARENT_SCOPE)
  endif()
endfunction()

function(static_link_libcxx out)
  if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    default_linker(linker)
    if(NOT linker STREQUAL "LLD")
      set("${out}" OFF PARENT_SCOPE)
      return()
    endif()
    find_library(libcxx_a libc++.a)
    find_library(libcxx_abi libc++abi.a)
    if(libcxx_a AND libcxx_abi)
      set("${out}" ON PARENT_SCOPE)
    else()
      set("${out}" OFF PARENT_SCOPE)
    endif()
  else()
    set("${out}" ON PARENT_SCOPE)
  endif()
endfunction()
