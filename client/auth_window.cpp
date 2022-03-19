#include "auth_window.hpp"
#include <imgui.h>
#include "imgui_stdlib.h"
auth_window::auth_window()
{
    authorized = false;
}

auth_window::~auth_window()
{

}

void auth_window::draw()
{
    ImGui::SetNextWindowSize(ImVec2(250, 100));
    ImGui::Begin("Auth form", nullptr, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize);
    ImGui::InputText("login", &input_login);
    ImGui::InputText("password", &input_passwd);
    if (ImGui::Button("Authorize") && !input_login.empty() && !input_passwd.empty())
    {
        auth(input_login, input_passwd);
    }
    ImGui::End();
}

bool auth_window::is_authorized()
{
    return authorized;
}

void auth_window::auth(const std::string &login, const std::string &passwd)
{
    authorized = true;
}