cmake_minimum_required(VERSION 3.16..3.27.7 FATAL_ERROR)  # tested on 3.27.7


# Import standard modules that might be of use down the line
include(FetchContent)  # very useful
include(CMakeDependentOption)
include(CheckCXXSymbolExists)

project(remote-mnist-classification
  VERSION
    1.0
  DESCRIPTION
    "Remote MNIST digit classification"
  LANGUAGES
    CXX
  HOMEPAGE_URL
    "https://github.com/Alex2034/Remote-MNIST-Classification"
)


### probably less forceful to set as a cmd opt to cmake
# if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
#   set(CMAKE_INSTALL_PREFIX <path> CACHE PATH <comment> FORCE)
# endif(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)

# set(LIB_INCLUDE_DIR "" CACHE FILEPATH "Path to external lib includes")
#
# if(NOT EXISTS ${LIB_INCLUDE_DIR}/header.h)
#   message(SEND_ERROR "Can't find header.h in ${LIB_INCLUDE_DIR}")
# endif()


# Support folders in IDEs
set_property(GLOBAL PROPERTY USE_FOLDERS ON)


set(CMAKE_CXX_STANDARD 17 CACHE STRING
	"The C++17 is standard to use nowadays, if not C++20.")
option(CMAKE_CXX_STANDARD_REQUIRED
	"When enabled, the value of CMAKE_CXX_STANDARD is a requirement."
	ON)
option(CMAKE_CXX_EXTENSIONS
	"When enabled, compiler-specific language extensions are enabled (e.g. -std=gnu++17)"
	OFF)


if(CMAKE_CXX_STANDARD LESS 17)
    message(FATAL_ERROR "We require C++17 or newer "
                        "but CMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD}")
endif()


# Export all symbols on Windows to match GCC/Clang behavior on Linux/macOS
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)


# The following code block is suggested to be used on Windows.
# According to https://github.com/pytorch/pytorch/issues/25457,
# the DLLs need to be copied to avoid memory errors.
# if (MSVC)
#   file(GLOB TORCH_DLLS "${TORCH_INSTALL_PREFIX}/lib/*.dll")
#   add_custom_command(TARGET example-app
#                      POST_BUILD
#                      COMMAND ${CMAKE_COMMAND} -E copy_if_different
#                      ${TORCH_DLLS}
#                      $<TARGET_FILE_DIR:example-app>)
# endif (MSVC)


### Require out-of-source builds
file(TO_CMAKE_PATH "${PROJECT_BINARY_DIR}/CMakeLists.txt" LOC_PATH)
if(EXISTS "${LOC_PATH}")
    message(FATAL_ERROR "You cannot build in a source directory "
                        "(or any directory with a CMakeLists.txt file). "
                        "Please make a build subdirectory. "
                        "Feel free to remove CMakeCache.txt and CMakeFiles.")
endif()


### Force g++ compiler with at least version 11 to support C++17
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "11.0.0")
        message(FATAL_ERROR "GCC version must be at least 11.0.0")
    endif()
    set(CMAKE_CXX_COMPILER "g++")
endif()

set(SOURCES
    app.cpp
)

# set(HEADERS
#     torch/script.h
#     opencv2/highgui/highgui.hpp
#     opencv2/core/core.hpp
# )


# Add libraries
find_package(Torch PATHS "${CMAKE_PREFIX_PATH}/libtorch/share/cmake/Torch"
    NO_DEFAULT_PATH REQUIRED)
find_package(OpenCV PATHS "${CMAKE_PREFIX_PATH}/opencv-4.x/build"
    NO_DEFAULT_PATH REQUIRED)

add_executable(digit-classification-model ${SOURCES})  #  ${HEADERS}

# Compile features (maybe add them with options instead?)
target_compile_features(digit-classification-model PRIVATE cxx_std_17)
# target_compile_options(digit-classification-model PRIVATE -Wall -Wextra -O2)
target_compile_options(digit-classification-model PRIVATE -O2)

message(STATUS "CVINCLUDE: ${OpenCV_INCLUDE_DIRS}")
message(STATUS "CVLIB: ${OpenCV_LIBRARIES}")
message(STATUS "TORCHINCLUDE: ${TORCH_INCLUDE_DIRS}")
message(STATUS "TORCHLIB: ${TORCH_LIBRARIES}")
target_include_directories(digit-classification-model PRIVATE
    "${OpenCV_INCLUDE_DIRS}" "${TORCH_INCLUDE_DIRS}")

target_link_libraries(digit-classification-model "${OpenCV_LIBS}")  #  "${TORCH_LIBRARIES}"
