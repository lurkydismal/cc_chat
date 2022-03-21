#include "client.hpp"
#include <imgui.h>
#include "imgui_stdlib.h"

void client::draw()
{
    ImGui::SetNextWindowSize(ImVec2(250, 100));
    ImGui::Begin("Auth form", nullptr, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize);
    ImGui::SetWindowFocus();
    ImGui::InputText("login", &input_login);
    ImGui::InputText("password", &input_passwd, ImGuiInputTextFlags_Password);
    if (ImGui::Button("Authorize") && !input_login.empty() && !input_passwd.empty())
    {
        auth(input_login, input_passwd);
    }
    ImGui::End();
}

void client::auth(const std::string &login, const std::string &passwd)
{
    packet_t packet;
    packet = actions::auth;
    packet << login << passwd;
    this->send(packet);
}

bool client::is_authorized()
{
    return false;
}