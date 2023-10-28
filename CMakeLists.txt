cmake_minimum_required(VERSION 3.26 FATAL_ERROR)
project(mnist)

file(TO_CMAKE_PATH "${PROJECT_BINARY_DIR}/CMakeLists.txt" LOC_PATH)
if(EXISTS "${LOC_PATH}")
    message(FATAL_ERROR "You cannot build in a source directory (or any directory with a CMakeLists.txt file). Please make a build subdirectory. Feel free to remove CMakeCache.txt and CMakeFiles.")
endif()

set_property(CMAKE_CXX_STANDARD 17)

# Add and configure dynamic libraries
find_package(OpenCV REQUIRED)

message(STATUS "CVINCLUDE: ${OpenCV_INCLUDE_DIRS}")
include_directories(${OpenCV_INCLUDE_DIRS})
target_link_libraries(example-app ${TORCH_LIBRARIES} ${OpenCV_LIBS})


find_package(Torch REQUIRED)

add_executable(example-app main.cpp)
