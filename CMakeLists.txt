cmake_minimum_required(VERSION 3.3)
project(fastjetwrapper)

# Cmake policies
# ==============
if(POLICY CMP0074)
    # find_package() uses <PackageName>_ROOT variables.
    # This policy was introduced in CMake version 3.12.
    cmake_policy(SET CMP0074 NEW)
endif()

# this helps Libdl.dlopen find the right paths
set(CMAKE_MACOSX_RPATH 0)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
# includes
# ============
include(CheckCXXCompilerFlag)
include(CMakePackageConfigHelpers)
include(GenerateExportHeader)
include(GNUInstallDirs)
include(InstallRequiredSystemLibraries)

if(CMAKE_CXX_COMPILER_ID MATCHES "Clang" OR CMAKE_CXX_COMPILER_ID MATCHES "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES "Intel")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wunused-parameter -Wextra -Wreorder")
endif()
set(CMAKE_CXX_STANDARD 17)
add_definitions(-DJULIA_ENABLE_THREADING)
# JlCxx_DIR needs to be passed in with -D
find_package(JlCxx REQUIRED )

set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib;${Julia_LIBRARY_DIR}")

include_directories(${CMAKE_SOURCE_DIR}/include ${CMAKE_INSTALL_PREFIX}/include)
include_directories(${INTERFACE_INCLUDE_DIRECTORIES})
link_directories(${CMAKE_INSTALL_PREFIX}/lib lib)

################ This was a hack that is fortunately no longer needed ####################
# but maybe the code is still useful in the future...
#add_library(fastjetall SHARED IMPORTED)
#set_target_properties(fastjetall PROPERTIES
#  IMPORTED_LOCATION "${CMAKE_INSTALL_PREFIX}/lib/${CMAKE_SHARED_LIBRARY_PREFIX}fastjetall${CMAKE_SHARED_LIBRARY_SUFFIX}"
#)
#set (CMAKE_SHARED_LINKER_FLAGS "-Wl,--no-as-needed")
######################################################
# add_library(fjcore SHARED src/fjcore)
add_library(fastjetwrap SHARED src/fastJetWrap.cc)
target_link_libraries(fastjetwrap JlCxx::cxxwrap_julia JlCxx::cxxwrap_julia_stl fastjet)
install(TARGETS
  fastjetwrap
LIBRARY DESTINATION lib${LIBDIR_SUFFIX}
ARCHIVE DESTINATION lib${LIBDIR_SUFFIX}
RUNTIME DESTINATION lib${LIBDIR_SUFFIX}
INCLUDES DESTINATION include)
