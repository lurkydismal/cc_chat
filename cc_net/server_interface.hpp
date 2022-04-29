#pragma once

#include <iostream>

#include "utils/common.hpp"
#include "utils/connection.hpp"
#include "utils/mtqueue.hpp"
#include "utils/packet.hpp"

namespace cc {
    namespace net {
        template< typename T >
        class server_interface {
        protected:
            asio::io_context asio_context;
            std::thread context_thread;
            asio::ip::tcp::acceptor asio_acceptor;
            mtqueue< owned_packet< T > > input_queue;
            std::deque< std::shared_ptr< connection< T > > > connections;
            uint32_t last_id = 1;

        public:
            server_interface( uint16_t port )
                : asio_acceptor(
                    asio_context,
                    asio::ip::tcp::endpoint(
                        asio::ip::tcp::v4(),
                        port
                    )
                )
            {}

            virtual ~server_interface() {
                this->stop();
            }

            bool start( void ) {
                try {
                    listen();

                    context_thread = std::thread(
                        [ this ]( void ) {
                            asio_context.run();
                        }
                    );

                } catch( const std::exception& e ) {
                    std::cerr
                        << "[ SERVER ] Exception: " << e.what()
                    << std::endl;
                    
                    return ( false );
                }

                std::cout
                    << "[ SERVER ] Started."
                << std::endl;

                return ( true );
            }

            void stop( void ) {
                asio_context.stop();

                if ( context_thread.joinable() ) { 
                    context_thread.join();
                }

                std::cout
                    << "[ SERVER ] Stopped"
                << std::endl;
            }

            void send( std::shared_ptr< connection< T > > client, const packet< T >& packet ) {
                if ( ( client ) && ( client->is_open() ) ) {
                    client->send( packet );

                } else {
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
                }
            }

            void send_all( const packet< T >& packet, std::shared_ptr< connection< T > > ignore = nullptr ) {
                bool invalid_exists = false;

                for ( auto& client : connections ) {
                    if ( ( client ) && ( client->is_open() ) ) {
                        if ( client != ignore ) {
                            client->send( packet );
                        }

                    } else {
                        event_client_disconnect( client );
                        client.reset();
                        invalid_exists = true;
                    }
                }

                if ( invalid_exists ) {
                    connections.erase(
                        std::remove(
                            connections.begin(),
                            connections.end(),
                            nullptr
                        ),
                        connections.end()
                    );
                }
            }

            void update( void ) {
                input_queue.wait();

                while ( !input_queue.empty() ) {
                    auto packet = input_queue.pop_front();

                    event_message(
                        packet.owner,
                        packet.packet
                    );
                }
            }

        protected:
            virtual bool event_client_connect( std::shared_ptr< connection< T > > client ) {
                return ( false );
            }

            virtual void event_message( std::shared_ptr< connection< T > > client, packet< T >& packet ) {}

            virtual void event_client_disconnect( std::shared_ptr< connection< T > > client ) {}

        private:
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
        };
    }
}
