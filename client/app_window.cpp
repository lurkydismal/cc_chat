#include "app_window.hpp"
#include <imgui.h>
#include "imgui_stdlib.h"

app_window::app_window()
{
    server.connect("127.0.0.1", 1337);
    packet_t packet;
    packet = actions::ping;
    server.send(packet);
    scroll_to_bottom = false;
}

app_window::~app_window()
{

}

void app_window::draw()
{
    ImGuiViewport *viewport = ImGui::GetMainViewport();
    ImGui::SetNextWindowPos(viewport->WorkPos);
    ImGui::SetNextWindowSize(viewport->WorkSize);
    ImGui::Begin("main", nullptr, ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoDecoration);

    if (!server.is_connected())
    {
        ImGui::Text("Establishing connection to the server...");
    }
    else if (!server.is_authorized())
    {
        server.draw();
    }
    else
    {
        ImGui::Separator();
        const float footer_reserve = ImGui::GetStyle().ItemSpacing.y + ImGui::GetFrameHeightWithSpacing();
        ImGui::BeginChild("chat", ImVec2(0, -footer_reserve), false, ImGuiWindowFlags_HorizontalScrollbar);
        for (std::string& item : items)
        {
            ImGui::Text(item.c_str());
        }
        if (scroll_to_bottom)
            ImGui::SetScrollHereY(1.0f);
        scroll_to_bottom = false;
        ImGui::EndChild();
        ImGui::Separator();
        bool reclaim_focus = false;
        if (ImGui::InputText("input", &input, ImGuiInputTextFlags_EnterReturnsTrue))
        {
            if (!input.empty())
                enter_message(input);
            input.clear();
            reclaim_focus = true;
        }
        ImGui::SetItemDefaultFocus();
        if (reclaim_focus)
        {
            ImGui::SetKeyboardFocusHere(-1);
        }
#ifndef NDEBUG
        ImGui::SameLine();
        if (ImGui::Button("Debug text"))
        {
            for (int i = 0; i < 50; i++)
                items.push_back("Debug text");
        }
#endif
    }
    ImGui::End();
}

void app_window::enter_message(std::string& message)
{
    items.push_back(message);
    scroll_to_bottom = true;
}