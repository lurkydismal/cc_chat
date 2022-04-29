#include <iostream>
#include <map>
#include <stdexcept>

#include <server_interface.hpp>
#include <soci/soci.h>
#include <soci/mysql/soci-mysql.h>

enum class actions : uint32_t {
    auth,
    auth_no_user,
    auth_incorrect_passwd,
    auth_online,
    auth_success,
    ping,
    msg,
    disconnect
};

bool event_client_connect( std::shared_ptr< cc::net::connection< actions_t > > client ) {
    return ( true );
}

void event_client_disconnect( std::shared_ptr< cc::net::connection< actions_t > > client ) {
    client->close();

    if ( !client->get_name().empty() ) {
        clients.erase( clients.find( client->get_name() ) );
    }

    std::cout
        << "[" << client->get_id() << "] Disconnected."
    << std::endl;
}

void event_message(
    std::shared_ptr< cc::net::connection< actions_t > > client,
    cc::net::packet< actions_t >& packet
) {
    cc::net::packet< actions_t > return_packet;

    if ( packet == actions_t::auth ) {
        std::string login;
        std::string passwd;
        std::string db_passwd;

        packet
            >> passwd
            >> login;

        std::cout
            << "[" << client->get_id() << "] Auth"
        << std::endl;

        db_session.once
            << "select passwd from users where user=:login",
            soci::use( login ),
            soci::into( db_passwd );

        if( db_passwd.empty() ) {
            return_packet = actions_t::auth_no_user;

        } else if( db_passwd != passwd ) {
            return_packet = actions_t::auth_incorrect_passwd;

        } else if( clients.find( login ) != clients.end() ) {
            return_packet = actions_t::auth_online;

        } else {
            return_packet = actions_t::auth_success;

            client->set_name( login );

            std::cout
                << "[" << client->get_id() << "] "
                << login << " logged in."
            << std::endl;

            clients.insert(
                {
                    login,
                    client
                }
            );
        }

        this->send(
            client,
            return_packet
        );

    } else if( packet == actions_t::disconnect ) {
        event_client_disconnect( client );
        client.reset();
        connections.erase(
            std::remove(
                connections.begin(),
                connections.end(),
                client
            ),
            connections.end()
        );

    } else if( packet == actions_t::msg ) {
        std::string msg;

        packet >> msg;

        std::string return_msg = client->get_name() + ": " + msg;

        return_packet = actions_t::msg;

        return_packet << return_msg;

        for ( auto& user : clients ) {
            user.second->send( return_packet );
        }
    }
}

void listen( void ) {
    asio_acceptor.async_accept(
        [ this ]( std::error_code ec, asio::ip::tcp::socket socket ) {
            if ( !ec ) {
                std::cout
                    << "[ SERVER ] New connection: " << socket.remote_endpoint().address().to_string()
                << std::endl;

                std::shared_ptr< connection< T > > new_connection =
                    std::make_shared< connection< T > >(
                        connection< T >::owner_t::server,
                        asio_context,
                        std::move( socket ),
                        input_queue
                    );

                if ( event_client_connect( new_connection ) ) {
                    connections.push_back( std::move( new_connection ) );
                    connections.back()->connect_to_client( last_id++ );

                    std::cout
                        << "[" << connections.back()->get_id() << "] Connection approved"
                    << std::endl;

                } else {
                    std::cout
                        << "[----] Connection refused"
                    << std::endl;
                }

            } else {
                std::cerr
                    << "[ SERVER ] New connection error" << ec.message()
                << std::endl;
            }

            listen();
        }
    );
}

template < typename eventType >
void idle( eventType event ) {
    for ( ;; ) {
        if ( !event() ) {
            break;
        }
    }
}

int main ( int argc, char* argv[] ) {
    std::map<
        std::string,
        std::shared_ptr<
            cc::net::connection< actions_t >
        >
    > clients;
    mtqueue< owned_packet< actions_t > > input_queue;
    asio::io_context asio_context;
    soci::session db_session;
    uint16_t server_port = SERVER_PORT;
    uint16_t mysql_port  = 3306;
    std::string mysql_db     = MYSQL_DB;
    std::string mysql_user   = MYSQL_USER;
    std::string mysql_passwd = MYSQL_PASSWD;
    std::string mysql_host   = "localhost";
    bool table_exists = false;

    asio_acceptor(
        asio_context,
        asio::ip::tcp::endpoint(
            asio::ip::tcp::v4(),
            port
        )
    );

    db_session(
        soci::mysql,
        (
            "db=" +
            mysql_db +
            " user=" +
            mysql_user +
            " password=\'" +
            mysql_passwd +
            "\' host=" +
            mysql_host +
            " port=" +
            std::to_string( mysql_port )
        )
    );

    if( !db_session.is_connected() ) {
        throw (
            std::exception( "Unable to connect" )
        );
    }

    soci::rowset< std::string > tables(
        db_session.prepare << "show tables"
    );

    for ( auto& table : tables ) {
        if ( table == "users" )  {
            table_exists = true;
            soci::rowset< soci::row > fields(
                db_session.prepare << "describe users"
            );
            bool field_user = false;
            bool field_passwd = false;

            for ( auto field : fields ) {
                if ( field->get< std::string >( "Field" ) == "user" ) {
                    field_user = true;

                    if ( field->get< std::string >( "Type" ) != "text" ) {
                        db_session.alter_column(
                            "users",
                            "user",
                            soci::data_type::dt_string
                        );
                    }
                } else if ( field->get< std::string >( "Field" ) == "passwd" ) {
                    field_passwd = true;

                    if ( field->get< std::string >( "Type" ) != "text" ) {
                        db_session.alter_column(
                            "users",
                            "passwd",
                            soci::data_type::dt_string
                        );
                    }
                }
            }

            if ( !field_user ) {
                db_session.add_column(
                    "users",
                    "user",
                    soci::data_type::dt_string
                );
            }

            if ( !field_passwd ) {
                db_session.add_column(
                    "users",
                    "passwd",
                    soci::data_type::dt_string
                );
            }

            break;
        }
    }

    if ( !table_exists ) {
        db_session.create_table(
            "users"
        ).column(
            "user",
            soci::data_type::dt_string
        ).column(
            "passwd",
            soci::data_type::dt_string
        );
    }

    listen();

    std::thread context_thread = std::thread(
        [ this ]( void ) {
            asio_context.run();
        }
    );

    std::cout
        << "[ SERVER ] Started."
    << std::endl;

    idle(
        [ & ]( void ) {
            input_queue.wait();

            while ( !input_queue.empty() ) {
                auto packet = input_queue.pop_front();

                event_message(
                    packet.owner,
                    packet.packet
                );
            }
        }
    );

    asio_context.stop();

    if ( context_thread.joinable() ) { 
        context_thread.join();
    }

    std::cout
        << "[ SERVER ] Stopped"
    << std::endl;

    return ( EXIT_SUCCESS );
}
