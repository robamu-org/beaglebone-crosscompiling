cmake_minimum_required(VERSION 3.13)

# set the project name and version
project(hello VERSION 1.0)
set(TARGET_NAME ${CMAKE_PROJECT_NAME}) 

# specify the C++ standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

target_sources(${TARGET_NAME} hello.cpp)
