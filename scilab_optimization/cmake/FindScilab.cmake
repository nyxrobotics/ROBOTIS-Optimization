# - Try to find a version of Scilab and headers/library required by the
#   used compiler.
#
# This module defines:
#  SCILAB_ROOT: Scilab installation path
#  SCILAB_BINARY: Scilab binary path
#  SCILAB_LIBRARIES: list of required and optional libraries
#
# Copyright (c) 2009 Arnaud Barré <arnaud.barre@gmail.com>
# Redistribution and use is allowed according to the terms of the BSD license.

if(SCILAB_ROOT AND SCILAB_LIBRARIES)
  set(Scilab_FIND_QUIETLY TRUE)
endif()

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
  set(SCILAB_LIBRARIES_PATHS "${SCILAB_ROOT}/bin")
  set(LIBSCILAB "LibScilab")
  set(SCILAB_BIN "Scilex")

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
  set(SCILAB_LIBRARIES_PATHS "${SCILAB_ROOT}/Contents/MacOS/lib/scilab")
  set(LIBSCILAB "scilab")
  set(SCILAB_BIN "scilab")

else()
  set(SCILAB_LIBRARIES_PATHS
      "/usr/lib/x86_64-linux-gnu/scilab"
      "/usr/lib/scilab"
      "/usr/local/lib/scilab"
  )
  find_path(
    SCILAB_ROOT
    "etc/scilab.start"
    "/usr/share/scilab"
    "/usr/local/share/scilab"
  )
  set(LIBSCILAB "scilab-cli")
  set(SCILAB_BIN "scilab-cli")
endif()

find_program(SCILAB_BINARY ${SCILAB_BIN} PATHS "/usr/bin" "/usr/local/bin")

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

find_library(
  SCILAB_SCILAB_LIBRARY ${LIBSCILAB}
  PATHS ${SCILAB_LIBRARIES_PATHS}
  NO_DEFAULT_PATH
)
_find_optional_lib(SCILAB_CALL_SCILAB_LIBRARY scicall_scilab)
_find_optional_lib(SCILAB_CONSOLE_MINIMAL_LIBRARY sciconsole-minimal)
_find_optional_lib(SCILAB_COMPLETION_LIBRARY scicompletion)
_find_optional_lib(SCILAB_COMMONS_LIBRARY scicommons)
_find_optional_lib(SCILAB_LOCALIZATION_LIBRARY scilocalization)
_find_optional_lib(SCILAB_CLI_LIBRARY scilab-cli)
_find_optional_lib(SCILAB_MEX_LIBRARY mex)
_find_optional_lib(SCILAB_MX_LIBRARY mx)
_find_optional_lib(SCILAB_SCICORE_LIBRARY scicore)

# 正しいリンク順序でライブラリを構成
set(SCILAB_LIBRARIES "")
foreach(
  lib
  SCILAB_CALL_SCILAB_LIBRARY
  SCILAB_CONSOLE_MINIMAL_LIBRARY
  SCILAB_COMPLETION_LIBRARY
  SCILAB_COMMONS_LIBRARY
  SCILAB_LOCALIZATION_LIBRARY
  SCILAB_CLI_LIBRARY
  SCILAB_SCILAB_LIBRARY
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
  SCILAB_BINARY
  SCILAB_LIBRARIES
)
