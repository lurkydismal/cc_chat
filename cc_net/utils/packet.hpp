#pragma once
#include "common.hpp"

namespace cc
{
    namespace net
    {
        template<typename T>
        struct packet_header
        {
            T action{};
            uint32_t size = 0;
        };

        template<typename T>
        struct packet
        {
            packet_header<T> header{};
            std::vector<uint8_t> buff;

            packet<T>& operator=(const T rhs)
            {
                this->header.action = rhs;
                return *this;
            }

            bool operator==(const T rhs) const
            {
                return this->header.action == rhs;
            }

            bool operator!=(const T rhs) const
            {
                return !(*this == rhs);
            }

            template<typename data_type>
            packet<T>& operator<<(const data_type& rhs)
            {
                static_assert(std::is_standard_layout<data_type>::value, "Data pushed into packet must be standart layout.");

                buff.resize(this->header.size + sizeof(data_type));
                memcpy(buff.data() + this->header.size, &rhs, sizeof(data_type));
                this->header.size += sizeof(data_type);
                return *this;
            }

            template<typename data_type>
            packet<T>& operator>>(data_type& rhs)
            {
                static_assert(std::is_standard_layout<data_type>::value, "Data pulled from packet must be standart layout.");

                this->header.size -= sizeof(data_type);
                memcpy(&rhs, buff.data() + this->header.size, sizeof(data_type));
                buff.resize(this->header.size);
                return *this;
            }

            size_t size() const
            {
                return this->header.size;
            }
        };

        template<typename T>
        class connection;

        template<typename T>
        struct owned_packet
        {
            std::shared_ptr<connection<T>> owner;
            packet<T> packet;
        };
    }
}