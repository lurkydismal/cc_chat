#pragma once

#include "common.hpp"

namespace cc {
    namespace net {
        template< typename T > // T is a banana
        struct PacketHeader {
            T action{};
            size_t size = 0;
        };

        template< typename T > // T is a banana
        struct Packet {
            PacketHeader< T > header{};
            std::vector< uint8_t > buffer;

            Packet< T >& operator=( const T rhs ) {
                this->header.action = rhs;

                return ( *this );
            }

            bool operator==( const T rhs ) const {
                return ( this->header.action == rhs );
            }

            bool operator!=( const T rhs ) const {
                return ( !( *this == rhs ) );
            }

            Packet< T >& operator<<( const std::string& rhs ) {
                buff.resize(
                    this->header.size + rhs.size() + sizeof( uint32_t )
                );
                memcpy(
                    buff.data() + this->header.size,
                    rhs.data(),
                    rhs.size()
                );
                uint32_t str_size = rhs.size();
                memcpy(
                    buff.data() + this->header.size + rhs.size(),
                    &str_size,
                    sizeof( uint32_t )
                );
                this->header.size += rhs.size() + sizeof( uint32_t );

                return ( *this );
            }

            Packet< T >& operator>>( std::string& rhs ) {
                uint32_t str_size;
                this->header.size -= sizeof( uint32_t );
                memcpy(
                    &str_size,
                    buff.data() + this->header.size,
                    sizeof( uint32_t )
                );
                this->header.size -= str_size;
                rhs.resize( str_size );
                memcpy(
                    rhs.data(),
                    buff.data() + this->header.size,
                    str_size
                );
                buff.resize( this->header.size );

                return ( *this );
            }

            template< typename data_type >
            Packet< T >& operator<<( const data_type& rhs ) {
                static_assert(
                    std::is_standard_layout< data_type >::value,
                    "Data pushed into packet must be standart layout."
                );

                buff.resize(
                    this->header.size + sizeof( data_type )
                );
                memcpy(
                    buff.data() + this->header.size,
                    &rhs,
                    sizeof( data_type )
                );
                this->header.size += sizeof( data_type );

                return ( *this );
            }

            template< typename data_type >
            Packet< T >& operator>>( data_type& rhs ) {
                static_assert(
                    std::is_standard_layout< data_type >::value,
                    "Data pulled from packet must be standart layout."
                );

                this->header.size -= sizeof( data_type );
                memcpy(
                    &rhs,
                    buff.data() + this->header.size,
                    sizeof( data_type )
                );
                buff.resize(
                    this->header.size
                );

                return ( *this );
            }

            size_t size() const {
                return ( this->header.size );
            }
        };

        template< typename T >
        class connection;

        template< typename T >
        struct owned_packet {
            std::shared_ptr< connection< T > > owner;
            Packet< T > packet;
        };
    }
}
