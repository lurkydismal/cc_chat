#include <iostream>
#include <server_interface.hpp>

enum class actions : uint32_t
{
    auth,
    ping,
    msg,
    disconnect
};

class server : public cc::net::server_interface<actions>
{
public:
    server(uint16_t port): cc::net::server_interface<actions>(port)
    {}
protected:
    bool event_client_connect(std::shared_ptr<cc::net::connection<actions>> client) override
    {
        return true;
    }

    void event_message(std::shared_ptr<cc::net::connection<actions>> client, cc::net::packet<actions>& packet) override
    {
        if (packet == actions::auth)
        {
            std::string login, passwd;
            packet >> passwd >> login;
            std::cout << "[" << client->get_id() << "] Auth" << std::endl << "Login: " << login << "Password: " << passwd << std::endl;
        }
    }
};

int main (int argc, char** argv)
{
    server server(1337);
    server.start();
    while(true)
    {
        server.update();
    }
    return 0;
}