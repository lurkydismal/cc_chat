#include "client.hpp"
#include <imgui.h>
#include "imgui_stdlib.h"
#include <cryptopp/sha.h>
#include <cryptopp/hex.h>

client::~client()
{
    packet_t packet;
    packet = actions::disconnect;
    this->send(packet);
}

void client::draw()
{
    ImGui::SetNextWindowSize(ImVec2(250, 125));
    ImGui::Begin("Auth form", nullptr, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize);
    ImGui::SetWindowFocus();
    if (!last_error.empty())
        ImGui::TextColored(ImVec4(1.0f, 0.0f, 0.0f, 1.0f), last_error.c_str());
    ImGui::InputText("login", &input_login);
    ImGui::InputText("password", &input_passwd, ImGuiInputTextFlags_Password);
    if (ImGui::Button("Authorize") && !input_login.empty() && !input_passwd.empty())
    {
        this->auth(input_login, input_passwd);
    }
    ImGui::End();
}

void client::auth(const std::string &login, const std::string &passwd)
{
    std::string encoded_passwd;
    CryptoPP::SHA512 hash;
    uint8_t encoded_array[CryptoPP::SHA512::DIGESTSIZE];
    hash.CalculateDigest(encoded_array, reinterpret_cast<const uint8_t*>(passwd.c_str()), passwd.size());
    CryptoPP::HexEncoder hex_to_str;
    hex_to_str.Attach(new CryptoPP::StringSink(encoded_passwd));
    hex_to_str.Put(encoded_array, CryptoPP::SHA512::DIGESTSIZE);
    hex_to_str.MessageEnd();

    packet_t packet;
    packet = actions::auth;
    packet << login << encoded_passwd;
    this->send(packet);
}

void client::logout()
{
    authorized = false;
}

bool client::is_authorized()
{
    if (authorized)
        return true;
    if (this->incoming().empty())
        return false;
    auto answer = this->incoming().pop_front();
    if (answer.packet == actions::auth_success)
    {
        authorized = true;
        return true;
    }
    if (answer.packet == actions::auth_no_user)
    {
        last_error = "User " + input_login + " does not exists.";
        return false;
    }
    if (answer.packet == actions::auth_incorrect_passwd)
    {
        last_error = "Incorrect password.";
        return false;
    }
    if (answer.packet == actions::auth_online)
    {
        last_error = "User " + input_login + " is online.";
        return false;
    }
    return false;
}