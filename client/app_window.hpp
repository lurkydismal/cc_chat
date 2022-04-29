#pragma once

#include <string>
#include <vector>

#include "client.hpp"

class app_window {
private:
    std::string input;
    std::vector< std::string > items;
    bool scroll_to_bottom;
    client server;

public:
    app_window( void );
    ~app_window();

    void draw( void );

private:
    void enter_message( std::string& message );
};