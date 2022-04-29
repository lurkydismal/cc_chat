#pragma once

#include "utils/common.hpp"
#include "utils/packet.hpp"
#include "utils/mtqueue.hpp"
#include "utils/connection.hpp"

namespace cc {
    namespace net {
        template< typename T >
        class client_interface {
        protected:
            std::unique_ptr< connection< T > > server_connection;
            asio::io_context asio_context;
            std::thread context_thread;

        private:
            mtqueue< owned_packet< T > > input_queue;

        public:
            client_interface( void ) {}
            
            virtual ~client_interface() {
                this->disconnect();
            }

            bool connect( std::string host, uint16_t port ) {
                try {
                    asio::ip::tcp::resolver::results_type endpoints =
                        asio::ip::tcp::resolver( asio_context )
                            .resolve(
                                host,
                                std::to_string( port )
                            );
                    server_connection = std::make_unique< connection< T > >(
                        connection< T >::owner_t::client,
                        asio_context,
                        asio::ip::tcp::socket( asio_context ),
                        input_queue
                    );
                    server_connection->connect_to_server( endpoints );
                    context_thread = std::thread(
                        [ this ]( void ) {
                            asio_context.run();
                        }
                    );

                } catch(...) {
                    return ( false );
                }

                return ( true );
            }

            void disconnect( void ) {
                if ( this->is_connected() ) {
                    server_connection->close();
                }

                asio_context.stop();

                if ( context_thread.joinable() ) {
                    context_thread.join();
                }

                asio_context.reset();
                server_connection.release();
            }

            bool is_connected( void ) {
                return (
                    ( server_connection )
                        ? server_connection->is_open()
                        : false;
                );
            }

            void send( const packet< T >& packet ) {
                if ( this->is_connected() ) {
                    server_connection->send( packet );
                }
            }

            mtqueue< owned_packet< T > >& incoming( void ) {
                return ( input_queue );
            }
        };
    }
}
