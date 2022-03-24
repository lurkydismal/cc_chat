cmake_minimum_required(VERSION 3.18.0)
project(tools)

add_executable(tool_useradd tool_useradd.cpp)
set_property(TARGET tool_useradd PROPERTY CXX_STANDARD 17)
target_link_libraries(tool_useradd CONAN_PKG::cryptopp CONAN_PKG::soci)