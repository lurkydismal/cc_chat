#pragma once
#include "common.hpp"
#include "packet.hpp"
#include "mtqueue.hpp"

namespace cc
{
    namespace net
    {
        template<typename T>
        class connection : public std::enable_shared_from_this<connection<T>>
        {
        public:
            enum class owner_type
            {
                server,
                client
            };
        public:
            connection(owner_type parent, asio::io_context& asio_context, asio::ip::tcp::socket socket, mtqueue<owned_packet<T>>& input_queue)
                : parent(parent), asio_context(asio_context), socket(std::move(socket)), input_queue(input_queue)
            {}
            virtual ~connection()
            {
                this->close();
            }
        public:
            void connect_to_server(asio::ip::tcp::resolver::results_type& endpoints)
            {
                if (parent == owner_type::client)
                {
                    asio::async_connect(socket, endpoints, 
                    [this](std::error_code ec, asio::ip::tcp::endpoint ep)
                    {
                        if (!ec)
                            read_header();
                    });
                }
            }

            void connect_to_client(int32_t uid)
            {
                if (parent == owner_type::server)
                {
                    if (socket.is_open())
                    {
                        id = uid;
                        read_header();
                    }
                }
            }

            void send(const packet<T>& packet)
            {
                asio::post(asio_context, 
                [this, packet]()
                {
                    bool b = !output_queue.empty();
                    output_queue.push_back(packet);
                    if (!b)
                        write_header();
                });
            }

            void close()
            {
                if (socket.is_open())
                    asio::post(asio_context, [this](){ socket.close(); });
            }

            bool is_open() const
            {
                return socket.is_open();
            }

            uint32_t get_id() const
            {
                return id;
            }

            void set_name(const std::string& value)
            {
                name = value;
            }

            std::string get_name() const
            {
                return name;
            }

            std::string get_ip() const
            {
                return socket.remote_endpoint().address().to_string();
            }
        private:
            void read_header()
            {
                asio::async_read(socket, asio::buffer(&input_temp_packet.header, sizeof(packet_header<T>)),
                [this](std::error_code ec, size_t length)
                {
                    if (!ec)
                    {
                        if(input_temp_packet.header.size > 0)
                        {
                            input_temp_packet.buff.resize(input_temp_packet.header.size);
                            read_body();
                        }
                        else
                            add();
                    }
                    else
                    {
                        socket.close();
                    }
                });
            }

            void read_body()
            {
                asio::async_read(socket, asio::buffer(input_temp_packet.buff),
                [this](std::error_code ec, size_t length)
                {
                    if (!ec)
                    {
                        add();
                    }
                    else
                    {
                        socket.close();
                    }
                });
            }

            void write_header()
            {
                asio::async_write(socket, asio::buffer(&output_queue.front().header, sizeof(packet_header<T>)),
                [this](std::error_code ec, size_t length)
                {
                    if (!ec)
                    {
                        if (output_queue.front().header.size > 0)
                            write_body();
                        else
                        {
                            output_queue.pop_front();
                            if (!output_queue.empty())
                                write_header();
                        }
                    }
                    else
                    {
                        socket.close();
                    }
                });
            }

            void write_body()
            {
                asio::async_write(socket, asio::buffer(output_queue.front().buff),
                [this](std::error_code ec, size_t length)
                {
                    if (!ec)
                    {
                        output_queue.pop_front();
                        if (!output_queue.empty())
                            write_header();
                    }
                    else
                    {
                        socket.close();
                    }
                });
            }

            void add()
            {
                if (parent == owner_type::client)
                    input_queue.push_back({ nullptr, std::move(input_temp_packet) });
                else
                    input_queue.push_back({ this->shared_from_this(), std::move(input_temp_packet) });
                read_header();
            }
        protected:
            asio::io_context& asio_context;
            asio::ip::tcp::socket socket;
            mtqueue<packet<T>> output_queue;
            mtqueue<owned_packet<T>>& input_queue;
            owner_type parent;
            packet<T> input_temp_packet;
            uint32_t id = 0;
            std::string name;
        };
    }
}