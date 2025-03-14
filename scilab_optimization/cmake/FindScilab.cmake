# FindScilab.cmake - Minimal Scilab detection module for ROS/Linux (CLI only)

# === Search paths ===
set(_SCILAB_SEARCH_INCLUDE_PATHS /usr/include /usr/local/include)
set(_SCILAB_SEARCH_SHARE_PATHS /usr/share/scilab /usr/local/share/scilab)
set(_SCILAB_SEARCH_LIB_PATHS /usr/lib/scilab /usr/local/lib/scilab)

# === Find include directory ===
find_path(
  SCILAB_INCLUDE_DIR
  NAMES scilab/api_scilab.h
  PATHS ${_SCILAB_SEARCH_INCLUDE_PATHS}
)

# === Find shared data path ===
find_path(
  SCILIB_PATH
  NAMES etc/scilab.start
  PATHS ${_SCILAB_SEARCH_SHARE_PATHS}
)

# === Find actual library directory (representative .so file) ===
find_path(
  SCILAB_LIBRARY_DIR
  NAMES libscilab.so
  PATHS ${_SCILAB_SEARCH_LIB_PATHS}
)

# === Find core libraries ===
find_library(
  SCILAB_CORE_LIBRARY
  NAMES scilab-cli
  PATHS ${_SCILAB_SEARCH_LIB_PATHS}
)

find_library(
  SCILAB_CALL_SCILAB_LIBRARY
  NAMES scicall_scilab
  PATHS ${_SCILAB_SEARCH_LIB_PATHS}
)

# === List of additional Scilab libraries ===
set(_SCILAB_REQUIRED_LIBS
    libsciaction_binding-disable.so
    libsciaction_binding.so
    libsciarnoldi.so
    libscicall_scilab.so
    libscicommons-disable.so
    libscicommons.so
    libscicompletion.so
    libsciconsole-minimal.so
    libsciexternal_objects.so
    libsciexternal_objects_java.so
    libscifunctions.so
    libscihelptools.so
    libscihdf5.so
    libscihistory_browser-disable.so
    libscihistory_browser.so
    libscihistory_manager.so
    libscigraphic_export-disable.so
    libscigraphic_export.so
    libscigraphic_objects-disable.so
    libscigraphics-disable.so
    libscigraphics.so
    libscigui-disable.so
    libscigui.so
    libsciinterpolation.so
    libscijvm-disable.so
    libscilab-cli.so
    libscilab.so
    libscilocalization.so
    libscimatio.so
    libsciparallel.so
    libscipreferences-cli.so
    libscirandlib.so
    libscirenderer.so
    libsciscicos-cli.so
    libsciscicos.so
    libsciscicos_blocks-cli.so
    libsciscinotes-disable.so
    libsciscinotes.so
    libscisignal_processing.so
    libscisound.so
    libscispecial_functions.so
    libscispreadsheet.so
    libscisundials.so
    libscistatistics.so
    libscitclsci.so
    libsciumfpack.so
    libsciui_data-disable.so
    libsciui_data.so
    libscixcos-disable.so
    libscixcos.so
    libscixml.so
)

# === Collect full paths of libraries ===
set(SCILAB_LIBRARIES ${SCILAB_CORE_LIBRARY} ${SCILAB_CALL_SCILAB_LIBRARY})

foreach(_lib ${_SCILAB_REQUIRED_LIBS})
  list(
    APPEND
    SCILAB_LIBRARIES
    "${SCILAB_LIBRARY_DIR}/${_lib}"
  )
endforeach()

# === Find and validate ===
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  Scilab
  REQUIRED_VARS
    SCILAB_INCLUDE_DIR
    SCILIB_PATH
    SCILAB_LIBRARY_DIR
    SCILAB_LIBRARIES
)

# === Mark as advanced (to hide from GUIs like ccmake) ===
mark_as_advanced(
  SCILAB_INCLUDE_DIR
  SCILIB_PATH
  SCILAB_LIBRARY_DIR
  SCILAB_LIBRARIES
)
