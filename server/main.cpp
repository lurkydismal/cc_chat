#include <iostream>
#include <server_interface.hpp>

enum class actions : uint32_t
{
    auth,
    ping,
    disconnect
};

class server : public cc::net::server_interface<actions>
{
public:
    server(uint16_t port): cc::net::server_interface<actions>(port)
    {}
};

int main ()
{
    server server(1337);
    server.start();
    while(true)
    {
        server.update();
    }
    return 0;
}