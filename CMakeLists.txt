project(fastjetwrapper)

cmake_minimum_required(VERSION 2.8.12)
# this helps Libdl.dlopen find the right paths
set(CMAKE_MACOSX_RPATH 0)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
add_definitions(-DJULIA_ENABLE_THREADING)
# JlCxx_DIR needs to be passed in with -D
find_package(JlCxx REQUIRED )

set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib;${Julia_LIBRARY_DIR}")

include_directories(${CMAKE_SOURCE_DIR}/include)
include_directories(${INTERFACE_INCLUDE_DIRECTORIES})
link_directories(${CMAKE_INSTALL_PREFIX}/lib)

################ This was a hack that is fortunately no longer needed ####################
# but maybe the code is still useful in the future...
#add_library(fastjetall SHARED IMPORTED)
#set_target_properties(fastjetall PROPERTIES
#  IMPORTED_LOCATION "${CMAKE_INSTALL_PREFIX}/lib/${CMAKE_SHARED_LIBRARY_PREFIX}fastjetall${CMAKE_SHARED_LIBRARY_SUFFIX}"
#)
#set (CMAKE_SHARED_LINKER_FLAGS "-Wl,--no-as-needed")
######################################################
add_library(fjcore SHARED src/fjcore)
add_library(fastjetwrap SHARED src/fastJetWrap.cc src/fjcore.cc)
target_link_libraries(fastjetwrap JlCxx::cxxwrap_julia)
install(TARGETS
  fastjetwrap fjcore
LIBRARY DESTINATION lib${LIBDIR_SUFFIX}
ARCHIVE DESTINATION lib${LIBDIR_SUFFIX}
RUNTIME DESTINATION lib${LIBDIR_SUFFIX}
INCLUDES DESTINATION include)
