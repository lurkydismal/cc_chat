#pragma once
#include <string>

class auth_window
{
public:
    auth_window();
    ~auth_window();
public:
    void draw();
    bool is_authorized();
private:
    void auth(const std::string& login, const std::string& passwd);
private:
    bool authorized;
    std::string input_login;
    std::string input_passwd;
};