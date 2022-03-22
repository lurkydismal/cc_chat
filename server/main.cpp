#include <iostream>
#include <map>
#include <server_interface.hpp>

enum class actions : uint32_t
{
    auth,
    auth_no_user,
    auth_incorrect_passwd,
    auth_online,
    auth_success,
    ping,
    msg,
    disconnect
};

class server : public cc::net::server_interface<actions>
{
public:
    server(uint16_t port): cc::net::server_interface<actions>(port)
    {
        users.insert({ "arsenez", "04C0C3501F0140B94BDC2155ECEBF2D835CE539D878F65ACF813A354F5F168BA1F6D176068B9C15AD8B545ADA8F98A9C4798E2DB1DE8F245F0154F5A4F5CDE5C" });
    }
protected:
    bool event_client_connect(std::shared_ptr<cc::net::connection<actions>> client) override
    {
        return true;
    }

    void event_client_disconnect(std::shared_ptr<cc::net::connection<actions>> client) override
    {
        client->close();
        if(!client->get_name().empty())
            clients.erase(clients.find(client->get_name()));
        std::cout << "[" << client->get_id() << "] Disconnected." << std::endl;
    }

    void event_message(std::shared_ptr<cc::net::connection<actions>> client, cc::net::packet<actions>& packet) override
    {
        cc::net::packet<actions> return_packet;
        if (packet == actions::auth)
        {
            std::string login, passwd;
            packet >> passwd >> login;
            std::cout << "[" << client->get_id() << "] Auth" << std::endl;
            auto users_it = users.find(login);
            if (users_it == users.end())
            {
                return_packet = actions::auth_no_user;
            }
            else if (users_it->second != passwd)
            {
                return_packet = actions::auth_incorrect_passwd;
            }
            else if(clients.find(login) != clients.end())
            {
                return_packet = actions::auth_online;
            }
            else
            {
                return_packet = actions::auth_success;
                client->set_name(login);
                std::cout << "[" << client->get_id() << "] " << login << " logged in." << std::endl;
                clients.insert({ login, client });
            }
            this->send(client, return_packet);
        }
        else if(packet == actions::disconnect)
        {
            event_client_disconnect(client);
            client.reset();
            connections.erase(std::remove(connections.begin(), connections.end(), client), connections.end());
        }
    }

protected:
    std::map<std::string, std::string> users;
    std::map<std::string, std::shared_ptr<cc::net::connection<actions>>> clients;
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