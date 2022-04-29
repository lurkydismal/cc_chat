#define WIN32_LEAN_AND_MEAN
#include <Windows.h>

#include <GLFW/glfw3.h>
#include <imgui.h>

#include "imgui/imgui_impl_glfw.h"
#include "imgui/imgui_impl_opengl3.h"
#include "app_window.hpp"

int main( int argc, char* argv[] ) {
    FreeConsole();

    glfwInit();
    glfwWindowHint( GLFW_CONTEXT_VERSION_MAJOR, 3 );
    glfwWindowHint( GLFW_CONTEXT_VERSION_MINOR, 0 );

    GLFWwindow* window = glfwCreateWindow(
        800,
        600,
        "CyberCommunity: chat",
        nullptr,
        nullptr
    );

    glfwMakeContextCurrent( window );
    glfwSwapInterval( 1 );
    glClearColor(
        0.45f,
        0.55f,
        0.60f,
        1.00f
    );

    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGui::GetIO().IniFilename = nullptr;
    ImGui::GetIO()
        .Fonts->AddFontFromFileTTF(
            "C:\\Windows\\Fonts\\Tahoma.ttf",
            17,
            nullptr,
            ImGui::GetIO()
                .Fonts->GetGlyphRangesCyrillic()
        );
    ImGui_ImplGlfw_InitForOpenGL(
        window,
        true
    );
    ImGui_ImplOpenGL3_Init( "#version 130" );

    while( !glfwWindowShouldClose( window ) ) {
        static app_window app;
        int vp_width;
        int vp_height;

        glfwPollEvents();

        ImGui_ImplGlfw_NewFrame();
        ImGui_ImplOpenGL3_NewFrame();
        ImGui::NewFrame();

        app.draw();

        ImGui::Render();

        glfwGetFramebufferSize(
            window,
            &vp_width,
            &vp_height
        );
        glViewport(
            0,
            0,
            vp_width,
            vp_height
        );
        glClear( GL_COLOR_BUFFER_BIT );

        ImGui_ImplOpenGL3_RenderDrawData( ImGui::GetDrawData() );

        glfwSwapBuffers( window );
    }

    glfwDestroyWindow( window );
    glfwTerminate();

    return ( EXIT_SUCCESS );
}
