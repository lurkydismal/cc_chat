cmake_minimum_required(VERSION 3.18.0)
project(CyberCommunity_chat)

set(CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_SOURCE_DIR})
set(CMAKE_CXX_STANDARD 17)

add_subdirectory(client)

install(TARGETS chat DESTINATION bin)