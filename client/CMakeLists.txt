cmake_minimum_required(VERSION 3.18.0)
project(chat)

add_executable(${PROJECT_NAME} 
    main.cpp
    app_window.cpp
    imgui_stdlib.cpp
    imgui/imgui_impl_glfw.cpp
    imgui/imgui_impl_opengl3.cpp
)
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 17)
target_link_libraries(${PROJECT_NAME} CONAN_PKG::glfw CONAN_PKG::imgui)