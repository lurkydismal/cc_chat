#include <iostream>
#include <map>
#include <server_interface.hpp>
#include <soci/soci.h>
#include <soci/mysql/soci-mysql.h>
#include <stdexcept>

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
    server(uint16_t server_port, std::string mysql_db, std::string mysql_user, std::string mysql_passwd, std::string mysql_host = "localhost", uint16_t mysql_port = 3306)
        : cc::net::server_interface<actions>(server_port), db_session(soci::mysql, "db=" + mysql_db + " user=" + mysql_user + " password='" + mysql_passwd + "' host=" + mysql_host + " port=" + std::to_string(mysql_port))
    {
        if(!db_session.is_connected())
            throw std::runtime_error("Unable to connect to DB");
        soci::rowset<std::string> tables(db_session.prepare << "show tables");
        bool table_exists = false;
        for (auto& table : tables)
        {
            if (table == "users") 
            {
                table_exists = true;
                soci::rowset<soci::row> fields(db_session.prepare << "describe users");
                bool field_user = false, field_passwd = false;
                for (auto field = fields.begin(); field != fields.end(); field++)
                {
                    if (field->get<std::string>("Field") == "user")
                    {
                        field_user = true;
                        if (field->get<std::string>("Type") != "text")
                            db_session.alter_column("users", "user", soci::data_type::dt_string);
                    }
                    else if (field->get<std::string>("Field") == "passwd")
                    {
                        field_passwd = true;
                        if (field->get<std::string>("Type") != "text")
                            db_session.alter_column("users", "passwd", soci::data_type::dt_string);
                    }
                }
                if (!field_user)
                    db_session.add_column("users", "user", soci::data_type::dt_string);
                if (!field_passwd)
                    db_session.add_column("users", "passwd", soci::data_type::dt_string);
                break;
            }
        }
        if (!table_exists)
            db_session.create_table("users").column("user", soci::data_type::dt_string).column("passwd", soci::data_type::dt_string);
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
            std::string db_passwd;
            db_session.once << "select passwd from users where user=:login", soci::use(login), soci::into(db_passwd);
            if(db_passwd.empty())
            {
                return_packet = actions::auth_no_user;
            }
            else if(db_passwd != passwd)
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
        else if(packet == actions::msg)
        {
            std::string msg;
            packet >> msg;
            std::string return_msg = client->get_name() + ": " + msg;
            return_packet = actions::msg;
            return_packet << return_msg;
            for (auto& user : clients)
            {
                user.second->send(return_packet);
            }
        }
    }

protected:
    soci::session db_session;
    std::map<std::string, std::shared_ptr<cc::net::connection<actions>>> clients;
};

int main (int argc, char** argv)
{
    try
    {
        server server(SERVER_PORT, MYSQL_DB, MYSQL_USER, MYSQL_PASSWD);
        server.start();
        while(true)
        {
            server.update();
        }
    }
    catch(const std::exception& e)
    {
        std::cerr << e.what() << '\n';
        return 1;
    }
    return 0;
}