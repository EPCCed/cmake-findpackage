#[=======================================================================[.rst:
FindHwloc
-------
 
Finds the hwloc library. Use HWLOC_ROOT to specify a prefix path -- $HWLOC_ROOT/lib and $HWLOC_ROOT/include will be searched.

Result Variables
^^^^^^^^^^^^^^^^

This will define the following variables:

``HWLOC_FOUND``
True if libhwloc and hwloc.h are found.
``HWLOC_INCLUDE_DIRS``
Include directories needed to use hwloc.
``HWLOC_LIBRARIES``
Libraries needed to link to hwloc.

Cache Variables
^^^^^^^^^^^^^^^

The following cache variables may also be set:

``HWLOC_INCLUDE_DIR``
The directory containing ``hwloc.h``.
``HWLOC_LIBRARY``
The path to the hwloc library.

#]=======================================================================]

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET)
pkg_check_modules(PC_HWLOC hwloc QUIET)

if(NOT DEFINED HWLOC_ROOT)
  set(HWLOC_ROOT $ENV{HWLOC_ROOT})
endif()

find_path(HWLOC_INCLUDE_DIR
  NAMES hwloc.h
  PATHS
    ${PC_HWLOC_INCLUDE_DIRS}
    ${HWLOC_ROOT}
    ${HWLOC_ROOT}/include
)
find_library(HWLOC_LIBRARY
  NAMES hwloc
  PATHS
    ${PC_HWLOC_LIBRARY_DIRS}
    ${HWLOC_ROOT}
    ${HWLOC_ROOT}/lib
)

if(PC_HWLOC_FOUND)
  set(HWLOC_VERSION ${PC_HWLOC_VERSION})
elseif(HWLOC_LIBRARY)
  # we found the library, so we may still
  # be able to pull version from lstopo
  find_program(LSTOPO
    lstopo
    PATHS
      ${PC_HWLOC_PREFIX}
      ${PC_HWLOC_PREFIX}/bin
      ${HWLOC_ROOT}
      ${HWLOC_ROOT}/bin
  )

  if(LSTOPO)
    if(NOT hwloc_FIND_QUIETLY)  
      message("Getting hwloc version from lstopo")
    endif()
    execute_process(
      COMMAND ${LSTOPO} --version
      COMMAND grep -woe "[[:digit:]]\\+\\.[[:digit:]]\\+\\.*[[:digit:]]\\+"
      OUTPUT_VARIABLE HWLOC_VERSION
    )
  endif()
endif()

find_package_handle_standard_args(hwloc
  FOUND_VAR HWLOC_FOUND
  REQUIRED_VARS
    HWLOC_INCLUDE_DIR
    HWLOC_LIBRARY
  VERSION_VAR HWLOC_VERSION
  REASON_FAILURE_MESSAGE "If hwloc is installed, try setting HWLOC_ROOT to directory which contains hwloc lib and include directories"
)

if(HWLOC_FOUND AND NOT hwloc_FIND_QUIETLY AND HWLOC_VERSION)
  message("Found hwloc version ${HWLOC_VERSION}")
endif()

mark_as_advanced(HWLOC_FOUND HWLOC_INCLUDE_DIR HWLOC_LIBRARY HWLOC_VERSION)

if(HWLOC_FOUND AND NOT TARGET hwloc::hwloc)
  set(HWLOC_INCLUDE_DIRS ${HWLOC_INCLUDE_DIR})
  set(HWLOC_LIBRARIES ${HWLOC_LIBRARY})

  if (NOT hwloc_FIND_QUIETLY)
    message("Creating hwloc::hwloc target.")
  endif()
  
  add_library(hwloc::hwloc INTERFACE IMPORTED)
  target_include_directories(hwloc::hwloc INTERFACE ${HWLOC_INCLUDE_DIRS})
  target_link_libraries(hwloc::hwloc INTERFACE ${HWLOC_LIBRARIES})
endif()
