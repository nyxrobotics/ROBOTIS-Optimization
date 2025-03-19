# - Try to find a version of Scilab and headers/library required by the
#   used compiler.
#
# This module defines:
#  SCILAB_ROOT: Scilab installation path
#  SCILAB_BINARY: Scilab binary path
#  SCILAB_MEX_INCLUDE_DIR: include path for mex.h (optional)
#  SCILAB_CORE_INCLUDE_DIR: main headers (optional)
#  SCILAB_MEX_LIBRARY: path to libmex.so (optional)
#  SCILAB_MX_LIBRARY:  path to libmx.so (optional)
#  SCILAB_SCICORE_LIBRARY: path to scicore (optional)
#  SCILAB_LIBRARIES:   list of required and optional libraries
#
# Copyright (c) 2009 Arnaud Barré <arnaud.barre@gmail.com>
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.

if(SCILAB_ROOT AND SCILAB_LIBRARIES)
  set(Scilab_FIND_QUIETLY TRUE)
endif()

# platform-specific paths
if(WIN32)
  get_filename_component(
    SCILAB_VER
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Scilab;LASTINSTALL]"
    NAME
  )
  find_path(
    SCILAB_ROOT
    "etc/scilab.start"
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Scilab\\${SCILAB_VER};SCIPATH]"
  )
  set(SCILAB_MODULE_PATHS "${SCILAB_ROOT}/modules")
  set(SCILAB_LIBRARIES_PATHS "${SCILAB_ROOT}/bin")
  set(SCILAB_MODULES_MEXLIB_PATHS "${SCILAB_MODULE_PATHS}/mexlib/includes")
  set(SCILAB_MODULES_CORE_PATHS "${SCILAB_MODULE_PATHS}/core/includes")
  set(SCILAB_BINARY_PATHS "${SCILAB_ROOT}/bin")
  set(LIBMEX "libmex.dll")
  set(LIBMX "libmx.dll")
  set(LIBSCILAB "LibScilab")
  set(LIBSCICORE "")
  set(SCILAB_BIN "Scilex")
  set(SCILAB_SCICORE_LIBRARY "NOTUSED")

elseif(APPLE)
  file(
    GLOB
    SCILAB_PATHS
    "/Applications/Scilab*"
  )
  find_path(
    SCILAB_ROOT
    "Contents/MacOS/share/scilab/etc/scilab.start"
    ${SCILAB_PATHS}
  )
  set(SCILAB_MODULE_PATHS "${SCILAB_ROOT}/Contents/MacOS/share/scilab/modules")
  set(SCILAB_LIBRARIES_PATHS "${SCILAB_ROOT}/Contents/MacOS/lib/scilab")
  set(SCILAB_MODULES_MEXLIB_PATHS "${SCILAB_ROOT}/Contents/MacOS/include/scilab")
  set(SCILAB_MODULES_CORE_PATHS "${SCILAB_ROOT}/Contents/MacOS/include/scilab")
  set(SCILAB_BINARY_PATHS "${SCILAB_ROOT}/Contents/MacOS/bin")
  set(LIBMEX "libmex.dylib")
  set(LIBMX "libmx.dylib")
  set(LIBSCILAB "scilab")
  set(LIBSCICORE "scicore")
  set(SCILAB_BIN "scilab")

else()
  set(SCILAB_PATHS
      "/usr/share/scilab"
      "/usr/local/share/scilab"
      "/opt/local/share/scilab"
  )
  set(SCILAB_MODULE_PATHS
      "/usr/include/scilab"
      "/usr/local/include/scilab"
      "/opt/local/include/scilab"
  )
  set(SCILAB_LIBRARIES_PATHS
      "/usr/lib/x86_64-linux-gnu/scilab"
      "/usr/lib/scilab"
      "/usr/local/lib/scilab"
      "/opt/local/lib/scilab"
  )
  set(SCILAB_MODULES_MEXLIB_PATHS
      "/usr/include/scilab/mexlib"
      "/usr/local/include/scilab/mexlib"
      "/opt/local/include/scilab/mexlib"
  )
  set(SCILAB_MODULES_CORE_PATHS
      "/usr/include/scilab/core"
      "/usr/local/include/scilab/core"
      "/opt/local/include/scilab/core"
  )
  set(SCILAB_BINARY_PATHS
      "/usr/bin"
      "/usr/local/bin"
      "/opt/local/bin"
  )

  find_path(
    SCILAB_ROOT
    "etc/scilab.start"
    ${SCILAB_PATHS}
  )

  set(LIBSCILAB "scilab-cli")
  set(LIBSCICORE "scicore")
  set(LIBMEX "libmex.so")
  set(LIBMX "libmx.so")
  set(SCILAB_BIN "scilab-cli")
endif()

find_program(
  SCILAB_BINARY
  ${SCILAB_BIN}
  ${SCILAB_BINARY_PATHS}
)
find_library(
  SCILAB_SCILAB_LIBRARY
  ${LIBSCILAB}
  ${SCILAB_LIBRARIES_PATHS}
  NO_DEFAULT_PATH
)

# Optional libraries (linked in order)
macro(
  _find_optional_lib
  var
  name
)
  find_library(
    ${var}
    NAMES ${name}
    PATHS ${SCILAB_LIBRARIES_PATHS}
    NO_DEFAULT_PATH
  )
  if(NOT ${var})
    message(WARNING "Optional Scilab library '${name}' not found.")
  endif()
endmacro()

_find_optional_lib(SCILAB_CALL_SCILAB_LIBRARY scicall_scilab)
_find_optional_lib(SCILAB_CONSOLE_MINIMAL_LIBRARY sciconsole-minimal)
_find_optional_lib(SCILAB_COMPLETION_LIBRARY scicompletion)
_find_optional_lib(SCILAB_COMMONS_LIBRARY scicommons)
_find_optional_lib(SCILAB_LOCALIZATION_LIBRARY scilocalization)
_find_optional_lib(SCILAB_CLI_LIBRARY scilab-cli)
_find_optional_lib(SCILAB_MEX_LIBRARY ${LIBMEX})
_find_optional_lib(SCILAB_MX_LIBRARY ${LIBMX})
_find_optional_lib(SCILAB_SCICORE_LIBRARY ${LIBSCICORE})
_find_optional_lib(SCILAB_API_LIBRARY sciapi)
_find_optional_lib(SCILAB_TYPES_LIBRARY scitypes)

find_path(
  SCILAB_MEX_INCLUDE_DIR
  "mex.h"
  ${SCILAB_MODULES_MEXLIB_PATHS}
  "${SCILAB_MODULES_MEXLIB_PATHS}/mexlib"
  NO_DEFAULT_PATH
)
find_path(
  SCILAB_CORE_INCLUDE_DIR
  "core_math.h"
  ${SCILAB_MODULES_CORE_PATHS}
  "${SCILAB_MODULES_CORE_PATHS}/core"
  NO_DEFAULT_PATH
)

# Compose SCILAB_LIBRARIES
set(SCILAB_LIBRARIES ${SCILAB_SCILAB_LIBRARY})
foreach(
  lib
  SCILAB_CALL_SCILAB_LIBRARY
  SCILAB_CONSOLE_MINIMAL_LIBRARY
  SCILAB_COMPLETION_LIBRARY
  SCILAB_COMMONS_LIBRARY
  SCILAB_LOCALIZATION_LIBRARY
  SCILAB_CLI_LIBRARY
  SCILAB_MEX_LIBRARY
  SCILAB_MX_LIBRARY
  SCILAB_SCICORE_LIBRARY
  SCILAB_API_LIBRARY
  SCILAB_TYPES_LIBRARY
)
  if(${lib})
    list(
      APPEND
      SCILAB_LIBRARIES
      ${${lib}}
    )
  endif()
endforeach()

if(SCILAB_ROOT)
  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(
    Scilab
    REQUIRED_VARS
      SCILAB_ROOT
      SCILAB_BINARY
      SCILAB_SCILAB_LIBRARY
  )
endif()

mark_as_advanced(
  SCILAB_SCILAB_LIBRARY
  SCILAB_SCICORE_LIBRARY
  SCILAB_MEX_LIBRARY
  SCILAB_MX_LIBRARY
  SCILAB_LIBRARIES
  SCILAB_BINARY
)
