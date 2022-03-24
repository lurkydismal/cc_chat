cmake_minimum_required(VERSION 3.18.0)
project(chat_server)

add_executable(${PROJECT_NAME} main.cpp)
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 17)
target_link_libraries(${PROJECT_NAME} CONAN_PKG::asio CONAN_PKG::soci)