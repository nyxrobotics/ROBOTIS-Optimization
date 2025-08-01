#------------------------------------------------------------------------------
# Find a compatible Scilab installation with the necessary headers and libraries.
#
# This module locates Scilab's root directory, binary, and libraries required
# for linking, including both mandatory and optional components.
#
# It defines the following variables:
#   SCILAB_ROOT           - The root directory of the Scilab installation
#   SCILAB_BINARY         - The path to the Scilab executable
#   SCILAB_LIBRARIES      - A list of required and optional Scilab libraries
#   SCILAB_LIBRARY_DIR    - Directory where Scilab libraries were found
#------------------------------------------------------------------------------

# Skip search if already found
if(SCILAB_ROOT
   AND SCILAB_BINARY
   AND SCILAB_LIBRARIES
   AND SCILAB_LIBRARY_DIR
)
  set(Scilab_FIND_QUIETLY TRUE)
endif()

#------------------------------------------------------------------------------
# Search paths for Linux/Unix only
#------------------------------------------------------------------------------

set(_SCILAB_CANDIDATE_LIBRARY_DIRS
    "/usr/lib/x86_64-linux-gnu/scilab"
    "/usr/lib/scilab"
    "/usr/local/lib/scilab"
)

find_path(SCILAB_ROOT "etc/scilab.start" PATHS "/usr/share/scilab" "/usr/local/share/scilab")

find_program(
  SCILAB_BINARY
  NAMES scilab-cli
  PATHS "/usr/bin" "/usr/local/bin"
)

#------------------------------------------------------------------------------
# Find optional Scilab libraries in link order
#------------------------------------------------------------------------------

set(_SCILAB_OPTIONAL_LIBS
    # Required libraries
    scicall_scilab
    sciconsole-minimal
    scigui-disable
    scigui
    sciui_data-disable
    sciui_data
    scigraphics-disable
    scigraphics
    scigraphic_objects-disable
    scigraphic_objects
    scijvm-disable
    scijvm
    scirenderer
    scicompletion
    scicommons-disable
    scicommons
    scilocalization
    scilab-cli
    scixml
    sciexternal_objects
    # Optional libraries
    sciexternal_objects_java
    sciumfpack
    sciscicos-cli
    scihdf5
    sciaction_binding-disable
    sciaction_binding
    sciscicos
    scihistory_browser-disable
    scihistory_browser
    sciinterpolation
    scihistory_manager
    sciparallel
    scispecial_functions
    scifunctions
    scipreferences-cli
    scimatio
    scispreadsheet
    scirandlib
    sciarnoldi
    sciscinotes-disable
    sciscinotes
    scistatistics
    scilab
    scitclsci
    scisound
    scioptimization
    scigraphic_export-disable
    scigraphic_export
    scisundials
    sciscicos_blocks-cli
    scihelptools
    scixcos-disable
    scixcos
)

set(SCILAB_LIBRARIES "")
unset(SCILAB_LIBRARY_DIR CACHE)

foreach(lib_name IN LISTS _SCILAB_OPTIONAL_LIBS)
  string(TOUPPER "${lib_name}" upper_name)
  string(
    REPLACE "-"
            "_"
            upper_name
            "${upper_name}"
  )
  set(var_name "SCILAB_${upper_name}_LIB")

  find_library(
    ${var_name}
    NAMES ${lib_name}
    PATHS ${_SCILAB_CANDIDATE_LIBRARY_DIRS}
    NO_DEFAULT_PATH
  )

  if(${var_name})
    list(
      APPEND
      SCILAB_LIBRARIES
      ${${var_name}}
    )
    if(NOT
       DEFINED
       SCILAB_LIBRARY_DIR
    )
      get_filename_component(
        SCILAB_LIBRARY_DIR
        "${${var_name}}"
        DIRECTORY
      )
    endif()
  else()
    message(WARNING "Optional Scilab library '${lib_name}' not found.")
  endif()
endforeach()

#------------------------------------------------------------------------------
# Handle final result
#------------------------------------------------------------------------------

if(SCILAB_ROOT)
  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(
    SCILAB
    REQUIRED_VARS
      SCILAB_ROOT
      SCILAB_BINARY
      SCILAB_LIBRARIES
      SCILAB_LIBRARY_DIR
  )
endif()

mark_as_advanced(
  SCILAB_ROOT
  SCILAB_BINARY
  SCILAB_LIBRARIES
  SCILAB_LIBRARY_DIR
)
