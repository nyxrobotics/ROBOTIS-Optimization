# FindScilab.cmake - Minimal Scilab detection module for ROS/Linux (CLI only)

# Find include dir
find_path(
  SCILAB_INCLUDE_DIR
  NAMES scilab/api_scilab.h
  PATHS /usr/include /usr/local/include
)

# Find shared data path
find_path(
  SCILIB_PATH
  NAMES etc/scilab.start
  PATHS /usr/share/scilab /usr/local/share/scilab
)

# Find library dir
find_library(
  SCILAB_CORE_LIBRARY
  NAMES scilab-cli
  PATHS /usr/lib/scilab /usr/local/lib/scilab
)

# Optional but useful: find call_scilab and related modules
find_library(
  SCILAB_CALL_SCILAB_LIBRARY
  NAMES scicall_scilab
  PATHS /usr/lib/scilab /usr/local/lib/scilab
)

# Define results
set(SCILAB_INCLUDE_DIRS ${SCILAB_INCLUDE_DIR})
set(SCILAB_LIBRARY_DIRS "/usr/lib/scilab")

set(SCILAB_LIBRARIES ${SCILAB_CORE_LIBRARY} ${SCILAB_CALL_SCILAB_LIBRARY})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  Scilab
  REQUIRED_VARS
    SCILAB_INCLUDE_DIRS
    SCILIB_PATH
    SCILAB_LIBRARIES
)

mark_as_advanced(
  SCILAB_INCLUDE_DIRS
  SCILIB_PATH
  SCILAB_LIBRARIES
  SCILAB_LIBRARY_DIRS
)
