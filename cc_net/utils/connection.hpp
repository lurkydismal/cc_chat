#pragma once

#include "common.hpp"
#include "packet.hpp"
#include "mtqueue.hpp"

namespace cc {
    namespace net {
        template< typename T >
        class connection : public std::enable_shared_from_this< connection< T > > {
        protected:
            asio::io_context& asio_context;
            asio::ip::tcp::socket socket;
            mtqueue< packet< T > > output_queue;
            mtqueue< owned_packet< T > >& input_queue;
            owner_t parent;
            packet< T > input_temp_packet;
            uint32_t id = 0;
            std::string name;
            uint64_t input_handshake;
            uint64_t output_handshake;
            uint64_t right_handshake;

        public:
            enum owner_t {
                server,
                client
            };

        public:
            connection(
                owner_t parent,
                asio::io_context& asio_context,
                asio::ip::tcp::socket socket,
                mtqueue< owned_packet< T > >& input_queue
            )
                : parent( parent ),
                asio_context( asio_context ),
                socket( std::move( socket ) ),
                input_queue( input_queue )
            {
                if ( parent == owner_t::server ) {
                    output_handshake = static_cast< uint64_t >(
                        std::chrono::system_clock::now().time_since_epoch().count()
                    );
                    right_handshake = encrypt( output_handshake );
                    input_handshake = 0;

                } else {
                    output_handshake = 0;
                    input_handshake = 0;
                }
            }

            virtual ~connection() {
                this->close();
            }

            void connect_to_server( asio::ip::tcp::resolver::results_type& endpoints ) {
                if ( parent == owner_t::client ) {
                    asio::async_connect(
                        socket,
                        endpoints, 
                        [ this ](
                            std::error_code ec,
                            asio::ip::tcp::endpoint ep
                        ) {
                            if ( !ec ) {
                                read_handshake();

                            } else {
                                socket.close();
                            }
                        }
                    );
                }
            }

            void connect_to_client( int32_t uid ) {
                if ( parent == owner_t::server ) {
                    if ( socket.is_open() ) {
                        id = uid;
                        write_handshake();
                    }
                }
            }

            void send( const packet< T >& packet ) {
                asio::post(
                    asio_context,
                    [ this, packet ]( void ) {
                        bool b = !output_queue.empty();
                        output_queue.push_back( packet );

                        if ( !b ) {
                            write_header();
                        }
                    }
                );
            }

            void close( void ) {
                if ( socket.is_open() ) {
                    asio::post(
                        asio_context,
                        [ this ]( void ) {
                            socket.close();
                        }
                    );
                }
            }

            bool is_open() const {
                return ( socket.is_open() );
            }

            uint32_t get_id() const
            {
                return ( id );
            }

            void set_name( const std::string& value ) {
                name = value;
            }

            std::string get_name() const {
                return ( name );
            }

            std::string get_ip() const {
                return (
                    socket.remote_endpoint().address().to_string()
                );
            }

        private:
            void read_handshake( void ) {
                asio::async_read(
                    socket,
                    asio::buffer( &input_handshake, sizeof( uint64_t ) ),
                    [ this ]( std::error_code ec, size_t length ) {
                        if ( !ec ) {
                            if ( parent == owner_t::client ) {
                                output_handshake = encrypt( input_handshake );
                                write_handshake();

                            } else {
                                if ( input_handshake == right_handshake ) {
                                    read_header();

                                } else {
                                    socket.close();
                                }
                            }

                        } else {
                            socket.close();
                        }
                    }
                );
            }

            void write_handshake( void ) {
                asio::async_write(
                    socket,
                    asio::buffer( &output_handshake, sizeof( uint64_t ) ),
                    [ this ]( std::error_code ec, size_t length ) {
                        if ( !ec ) {
                            if ( parent == owner_t::client ) {
                                read_header();

                            } else {
                                read_handshake();
                            }

                        } else {
                            socket.close();
                        }
                    }
                );
            }

            void read_header( void ) {
                asio::async_read(
                    socket,
                    asio::buffer( &input_temp_packet.header, sizeof( PacketHeader< T > ) ),
                    [ this ]( std::error_code ec, size_t length ) {
                        if ( !ec ) {
                            if ( input_temp_packet.header.size ) {
                                input_temp_packet.buff.resize( input_temp_packet.header.size );
                                read_body();

                            } else {
                                add();
                            }

                        } else {
                            socket.close();
                        }
                    }
                );
            }

            void read_body( void ) {
                asio::async_read(
                    socket,
                    asio::buffer( input_temp_packet.buff ),
                    [ this ]( std::error_code ec, size_t length ) {
                        if ( !ec ) {
                            add();

                        } else {
                            socket.close();
                        }
                    }
                );
            }

            void write_header( void ) {
                asio::async_write(
                    socket,
                    asio::buffer( &output_queue.front().header, sizeof( PacketHeader< T > ) ),
                    [ this ]( std::error_code ec, size_t length ) {
                        if ( !ec ) {
                            if ( output_queue.front().header.size ) {
                                write_body();

                            } else {
                                output_queue.pop_front();

                                if ( !output_queue.empty() ) {
                                    write_header();
                                }
                            }

                        } else {
                            socket.close();
                        }
                    }
                );
            }

            void write_body( void ) {
                asio::async_write(
                    socket,
                    asio::buffer( output_queue.front().buff ),
                    [ this ]( std::error_code ec, size_t length ) {
                        if ( !ec ) {
                            output_queue.pop_front();

                            if ( !output_queue.empty() ) {
                                write_header();
                            }

                        } else {
                            socket.close();
                        }
                    }
                );
            }

            void add( void ) {
                if ( parent == owner_t::client ) {
                    input_queue.push_back(
                        {
                            nullptr,
                            std::move( input_temp_packet )
                        }
                    );

                } else {
                    input_queue.push_back(
                        {
                            this->shared_from_this(),
                            std::move( input_temp_packet )
                        }
                    );
                }

                read_header();
            }

            uint64_t encrypt( uint64_t data ) {
                data = ( data ^ 0xBADC0DEDEADAAAAA );
                data = (
                    ( data & 0xA0B0C0D0E0F01020 ) 
                    << 4
                    | ( data & 0x30405060708090A0 )
                    >> 4
                );

                return ( data ^ 0xC0DEFACE02042022 );
            }
        };
    }
}
