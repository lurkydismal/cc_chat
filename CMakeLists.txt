cmake_minimum_required(VERSION 3.18.0)
project(CyberCommunity_chat)

# Crash when nothing specified
if(NOT DEFINED BUILD_CLIENT AND NOT DEFINED BUILD_SERVER)
    message(FATAL_ERROR "Specify BUILD_CLIENT and/or BUILD_SERVER")
endif()

# Options for building a client
if(BUILD_CLIENT)
    if(NOT DEFINED SERVER_HOST OR NOT DEFINED SERVER_PORT)
        message(FATAL_ERROR "Specify SERVER_HOST and SERVER_PORT")
    endif()
    add_compile_definitions(SERVER_HOST="${SERVER_HOST}" SERVER_PORT=${SERVER_PORT})
    set(CONAN_RUN_REQUIRES "glfw/3.3.6" "imgui/1.87" "asio/1.22.0" "cryptopp/8.6.0")
    set(CONAN_RUN_OPTIONS)
    set(CONAN_RUN_IMPORTS 
        IMPORTS "./res/bindings, imgui_impl_opengl3* -> ${CMAKE_CURRENT_SOURCE_DIR}/client/imgui @ root_package=imgui"
        IMPORTS "./res/bindings, imgui_impl_glfw* -> ${CMAKE_CURRENT_SOURCE_DIR}/client/imgui @ root_package=imgui"
    )
endif()

# Options for building a server
if(BUILD_SERVER)
    if(NOT DEFINED SERVER_PORT)
        message(FATAL_ERROR "Specify SERVER_PORT")
    endif()
    if(NOT DEFINED MYSQL_HOST OR NOT DEFINED MYSQL_PORT OR NOT DEFINED MYSQL_USER OR NOT DEFINED MYSQL_PASSWD OR NOT DEFINED MYSQL_DB)
        message(FATAL_ERROR "Specify MYSQL_HOST, MYSQL_PORT, MYSQL_DB, MYSQL_USER and MYSQL_PASSWD")
    endif()
    add_compile_definitions(MYSQL_HOST="${MYSQL_HOST}" MYSQL_PORT=${MYSQL_PORT} MYSQL_DB="${MYSQL_DB}" MYSQL_USER="${MYSQL_USER}" MYSQL_PASSWD="${MYSQL_PASSWD}" SERVER_PORT=${SERVER_PORT})
    
    set(CONAN_RUN_REQUIRES ${CONAN_RUN_REQUIRES} "soci/4.0.3" "cryptopp/8.6.0" "asio/1.22.0")
    set(CONAN_RUN_OPTIONS ${CONAN_RUN_OPTIONS} "soci:with_mysql=True" "soci:shared=False")
    set(CONAN_IMPORTS)
endif()

# Global options
set(CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_SOURCE_DIR})
set(CMAKE_CXX_STANDARD 17)

# Download conan.cmake if missing
if(NOT EXISTS "${CMAKE_BINARY_DIR}/conan.cmake")
    message(STATUS "Downloading conan.cmake...")
    file(DOWNLOAD "https://raw.githubusercontent.com/conan-io/cmake-conan/develop/conan.cmake" "${CMAKE_BINARY_DIR}/conan.cmake")
endif()
include(${CMAKE_BINARY_DIR}/conan.cmake)

# Include cc_net lib
include_directories(cc_net)

# Run conan
conan_cmake_run(
    REQUIRES
        ${CONAN_RUN_REQUIRES}
    OPTIONS
        ${CONAN_RUN_OPTIONS}
    BUILD missing
    ${CONAN_RUN_IMPORTS}
    BASIC_SETUP CMAKE_TARGETS
)

# Build targets
if(BUILD_CLIENT)
    add_subdirectory(client)
    install(TARGETS chat DESTINATION bin)
endif()

if(BUILD_SERVER)
    add_subdirectory(server)
    add_subdirectory(tools)
    install(TARGETS chat_server DESTINATION bin)
    install(TARGETS tool_useradd DESTINATION bin)
endif()