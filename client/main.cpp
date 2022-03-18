#include <GLFW/glfw3.h>
#define WIN32_LEAN_AND_MEAN
#include <Windows.h>

int main(int argc, char** argv)
{
    FreeConsole();
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);
    GLFWwindow *window = glfwCreateWindow(800, 600, "CyberCommunity: chat", nullptr, nullptr);
    glfwMakeContextCurrent(window);
    glfwSwapInterval(1);
    glClearColor(0.45f, 0.55f, 0.60f, 1.00f);

    while(!glfwWindowShouldClose(window))
    {
        glfwPollEvents();
        int vp_width, vp_height;
        glfwGetFramebufferSize(window, &vp_width, &vp_height);
        glViewport(0, 0, vp_width, vp_height);
        glClear(GL_COLOR_BUFFER_BIT);
        glfwSwapBuffers(window);
    }

    glfwDestroyWindow(window);
    glfwTerminate();
    return 0;
}