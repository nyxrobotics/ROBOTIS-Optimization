# - Try to find a version of Scilab and headers/library required by the 
#   used compiler.
#
# This module defines: 
#  SCILAB_ROOT: Scilab installation path
#  SCILAB_BINARY: Scilab binary path
#  SCILAB_MEX_INCLUDE_DIR: include path for mex.h (used for libmex)
#  SCILAB_CORE_INCLUDE_DIR: main headers
#  SCILAB_MEX_LIBRARY: path to libmex.so (optional)
#  SCILAB_MX_LIBRARY:  path to libmx.so (optional)
#  SCILAB_SCICORE_LIBRARY: path to scicore (optional)
#  SCILAB_LIBRARIES:   list of required and optional libraries
#
# Copyright (c) 2009 Arnaud Barré <arnaud.barre@gmail.com>
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.

IF(SCILAB_ROOT AND SCILAB_LIBRARIES)
   SET(Scilab_FIND_QUIETLY TRUE)
ENDIF()

IF(WIN32)
  GET_FILENAME_COMPONENT(SCILAB_VER  "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Scilab;LASTINSTALL]" NAME)
  FIND_PATH(SCILAB_ROOT "etc/scilab.start" "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Scilab\\${SCILAB_VER};SCIPATH]")
  SET(SCILAB_MODULE_PATHS "${SCILAB_ROOT}/modules")
  SET(SCILAB_LIBRARIES_PATHS "${SCILAB_ROOT}/bin")
  SET(SCILAB_MODULES_MEXLIB_PATHS "${SCILAB_MODULE_PATHS}/mexlib/includes")
  SET(SCILAB_MODULES_CORE_PATHS "${SCILAB_MODULE_PATHS}/core/includes")
  SET(SCILAB_BINARY_PATHS "${SCILAB_ROOT}/bin")
  SET(LIBMEX "libmex.dll")
  SET(LIBMX "libmx.dll")
  SET(LIBSCILAB "LibScilab")
  SET(LIBSCICORE "")
  SET(SCILAB_BIN "Scilex")
  SET(SCILAB_SCICORE_LIBRARY "NOTUSED")

ELSEIF(APPLE)
  FILE(GLOB SCILAB_PATHS "/Applications/Scilab*")
  FIND_PATH(SCILAB_ROOT "Contents/MacOS/share/scilab/etc/scilab.start" ${SCILAB_PATHS})
  SET(SCILAB_MODULE_PATHS "${SCILAB_ROOT}/Contents/MacOS/share/scilab/modules")
  SET(SCILAB_LIBRARIES_PATHS "${SCILAB_ROOT}/Contents/MacOS/lib/scilab")
  SET(SCILAB_MODULES_MEXLIB_PATHS "${SCILAB_ROOT}/Contents/MacOS/include/scilab")
  SET(SCILAB_MODULES_CORE_PATHS "${SCILAB_ROOT}/Contents/MacOS/include/scilab")
  SET(SCILAB_BINARY_PATHS "${SCILAB_ROOT}/Contents/MacOS/bin")
  SET(LIBMEX "libmex.dylib")
  SET(LIBMX "libmx.dylib")
  SET(LIBSCILAB "scilab")
  SET(LIBSCICORE "scicore")
  SET(SCILAB_BIN "scilab")

ELSE()
  # Linux - supports Ubuntu 20.04 and 24.04
  SET(SCILAB_PATHS 
    "/usr/share/scilab"
    "/usr/local/share/scilab"
    "/opt/local/share/scilab"
  )
  SET(SCILAB_MODULE_PATHS 
    "/usr/include/scilab"
    "/usr/local/include/scilab"
    "/opt/local/include/scilab"
  )
  SET(SCILAB_LIBRARIES_PATHS
    "/usr/lib/x86_64-linux-gnu/scilab"
    "/usr/lib/scilab"
    "/usr/local/lib/scilab"
    "/opt/local/lib/scilab"
  )
  SET(SCILAB_MODULES_MEXLIB_PATHS 
    "/usr/include/scilab/mexlib"
    "/usr/local/include/scilab/mexlib"
    "/opt/local/include/scilab/mexlib"
  )
  SET(SCILAB_MODULES_CORE_PATHS
    "/usr/include/scilab/core"
    "/usr/local/include/scilab/core"
    "/opt/local/include/scilab/core"
  )
  SET(SCILAB_BINARY_PATHS
    "/usr/bin"
    "/usr/local/bin"
    "/opt/local/bin"
  )

  FIND_PATH(SCILAB_ROOT "etc/scilab.start" ${SCILAB_PATHS})

  # Prefer CLI version to avoid GUI dependency
  SET(LIBSCILAB "scilab-cli")
  SET(LIBSCICORE "scicore")
  SET(LIBMEX "libmex.so")
  SET(LIBMX "libmx.so")
  SET(SCILAB_BIN "scilab-cli")
ENDIF()

# Binary
FIND_PROGRAM(SCILAB_BINARY
  ${SCILAB_BIN}
  ${SCILAB_BINARY_PATHS}
)

# Required main Scilab library
FIND_LIBRARY(SCILAB_SCILAB_LIBRARY
  ${LIBSCILAB}
  ${SCILAB_LIBRARIES_PATHS} NO_DEFAULT_PATH
)

# Optional libraries
FIND_LIBRARY(SCILAB_SCICORE_LIBRARY
  ${LIBSCICORE}
  ${SCILAB_LIBRARIES_PATHS} NO_DEFAULT_PATH
)
FIND_LIBRARY(SCILAB_MEX_LIBRARY
  ${LIBMEX}
  ${SCILAB_LIBRARIES_PATHS} NO_DEFAULT_PATH
)
FIND_LIBRARY(SCILAB_MX_LIBRARY
  ${LIBMX}
  ${SCILAB_LIBRARIES_PATHS} NO_DEFAULT_PATH
)

# Include headers
FIND_PATH(SCILAB_MEX_INCLUDE_DIR
  "mex.h"
  ${SCILAB_MODULES_MEXLIB_PATHS}
  "${SCILAB_MODULES_MEXLIB_PATHS}/mexlib"
  NO_DEFAULT_PATH
)
FIND_PATH(SCILAB_CORE_INCLUDE_DIR
  "core_math.h"
  ${SCILAB_MODULES_CORE_PATHS}
  "${SCILAB_MODULES_CORE_PATHS}/core"
  NO_DEFAULT_PATH
)

# Compose SCILAB_LIBRARIES list
SET(SCILAB_LIBRARIES
  ${SCILAB_SCILAB_LIBRARY}
)

IF(SCILAB_SCICORE_LIBRARY)
  LIST(APPEND SCILAB_LIBRARIES ${SCILAB_SCICORE_LIBRARY})
ELSE()
  MESSAGE(WARNING "Scilab optional library 'scicore' not found.")
ENDIF()

IF(SCILAB_MEX_LIBRARY)
  LIST(APPEND SCILAB_LIBRARIES ${SCILAB_MEX_LIBRARY})
ELSE()
  MESSAGE(WARNING "Scilab optional library 'libmex.so' not found.")
ENDIF()

IF(SCILAB_MX_LIBRARY)
  LIST(APPEND SCILAB_LIBRARIES ${SCILAB_MX_LIBRARY})
ELSE()
  MESSAGE(WARNING "Scilab optional library 'libmx.so' not found.")
ENDIF()

# Final check (do not require optional libs)
IF(SCILAB_ROOT)
  INCLUDE(FindPackageHandleStandardArgs)
  FIND_PACKAGE_HANDLE_STANDARD_ARGS(Scilab DEFAULT_MSG
    SCILAB_ROOT
    SCILAB_BINARY
    SCILAB_MEX_INCLUDE_DIR
    SCILAB_CORE_INCLUDE_DIR
    SCILAB_SCILAB_LIBRARY
  )
ENDIF()

# Hide from cmake-gui
MARK_AS_ADVANCED(
  SCILAB_SCILAB_LIBRARY
  SCILAB_SCICORE_LIBRARY
  SCILAB_MEX_LIBRARY
  SCILAB_MX_LIBRARY
  SCILAB_LIBRARIES
  SCILAB_MEX_INCLUDE_DIR
  SCILAB_CORE_INCLUDE_DIR
  SCILAB_BINARY
)
