cmake_minimum_required(VERSION 2.8)

# If libraries are already defined, do nothing 
IF(SCALAPACK_LIBRARIES)
  SET(SCALAPACK_FOUND TRUE)
  RETURN()
ENDIF()

SET(SCALAPACK_FIND_QUIETLY FALSE)

find_library(SCALAPACK_LIBRARY
             NAMES scalapack scalapack-openmpi mkl_scalapack_lp64
  	     PATHS ENV LD_LIBRARY_PATH)


IF (SCALAPACK_LIBRARY)
  MESSAGE(STATUS "Checking if BLACS library is needed by SCALAPACK")
  # Check if separate BLACS libraries are needed
  UNSET(BLACS_EMBEDDED)
  INCLUDE(${CMAKE_ROOT}/Modules/CheckFortranFunctionExists.cmake)
  SET(CMAKE_REQUIRED_LIBRARIES_OLD ${CMAKE_REQUIRED_LIBRARIES})
  SET(CMAKE_REQUIRED_LIBRARIES 
    ${CMAKE_Fortran_REQUIRED_LIBRARIES}
    ${SCALAPACK_LIBRARY})
  include (CheckFunctionExists)
  check_function_exists("blacs_gridinit_" BLACS_EMBEDDED)
  SET(CMAKE_REQUIRED_LIBRARIES ${CMAKE_REQUIRED_LIBRARIES_OLD})

  IF(NOT BLACS_EMBEDDED)
    MESSAGE(STATUS "Checking if BLACS library is needed by SCALAPACK -- yes")
#    FIND_PACKAGE(BLACS TRUE FALSE)
    FIND_PACKAGE(BLACS)

    IF(BLACS_FOUND)
      SET(SCALAPACK_LIBRARY ${SCALAPACK_LIBRARY} ${BLACS_LIBRARIES})
      SET(SCALAPACK_FOUND TRUE)
    ELSE()
      FIND_LIBRARY(BLACS_LIBRARY
                   NAMES blacs blacs_MPI-LINUX-0 blacs_MPI-LINUX mkl_blacs_intelmpi_lp64 mkl_blacs_openmpi_lp64 mkl_blacs_mpich_lp64 mkl_blacs_sgimpt_lp64
                   PATHS ENV LD_LIBRARY_PATH)
      IF(BLACS_LIBRARY) 
        SET(SCALAPACK_FOUND TRUE)
        SET(SCALAPACK_LIBRARY ${SCALAPACK_LIBRARY} ${BLACS_LIBRARY})
      ELSE()
        SET(SCALAPACK_FOUND FALSE)
        MESSAGE(FATAL_ERROR "BLACS library not found, needed by found SCALAPACK library.")
      ENDIF()
    ENDIF()
  ELSE()
    MESSAGE(STATUS "Checking if BLACS library is needed by SCALAPACK -- no")
    SET(SCALAPACK_FOUND TRUE)
  ENDIF()
ENDIF()
   
IF (SCALAPACK_FOUND)
  IF (NOT SCALAPACK_FIND_QUIETLY)
    MESSAGE(STATUS "A library with SCALAPACK API found.")
    MESSAGE(STATUS "SCALAPACK libraries: ${SCALAPACK_LIBRARY}")
  ENDIF()
ELSE()
  IF (SCALAPACK_FIND_REQUIRED)
    MESSAGE(FATAL_ERROR "SCALAPACK library not found.")
  ENDIF()
ENDIF()

MARK_AS_ADVANCED(
  BLACS_EMBEDDED
  SCALAPACK_FOUND
  SCALAPACK_LIBRARY
  )
