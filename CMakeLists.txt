cmake_minimum_required(VERSION 3.13)

set(CMAKE_TOOLCHAIN_FILE "BBBToolchain.cmake")

# set the project name and version
project(hello LANGUAGES CXX C VERSION 1.0)
set(TARGET_NAME ${CMAKE_PROJECT_NAME})

# specify the C++ standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

add_executable(${TARGET_NAME})
target_sources(${TARGET_NAME} PRIVATE hello.cpp)
