cmake_minimum_required(VERSION 2.8.3)
project(scilab_optimization)

################################################################################
# Modules
################################################################################
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})
find_package(Scilab REQUIRED)
find_package(catkin REQUIRED COMPONENTS roscpp)

################################################################################
# Catkin package configuration
################################################################################
catkin_package(
  INCLUDE_DIRS include
  LIBRARIES scilab_optimization
  CATKIN_DEPENDS roscpp
)

################################################################################
# Include & link paths
################################################################################
include_directories(
  include
  ${catkin_INCLUDE_DIRS}
  ${SCILAB_INCLUDE_DIRS}
)

link_directories(${SCILAB_LIBRARY_DIRS})

add_definitions(-DSCILIB_PATH=\"${SCILIB_PATH}\")

################################################################################
# Build
################################################################################
add_library(scilab_optimization src/scilab_optimization.cpp)

add_dependencies(
  scilab_optimization
  ${${PROJECT_NAME}_EXPORTED_TARGETS}
  ${catkin_EXPORTED_TARGETS}
)

target_link_libraries(
  scilab_optimization
  ${SCILAB_LIBRARIES}
  ${catkin_LIBRARIES}
)

################################################################################
# Install
################################################################################
install(
  TARGETS scilab_optimization
  ARCHIVE DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
  LIBRARY DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
  RUNTIME DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

install(
  DIRECTORY include/${PROJECT_NAME}/
  DESTINATION ${CATKIN_PACKAGE_INCLUDE_DESTINATION}
)
