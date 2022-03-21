#pragma once
#include <client_interface.hpp>

enum class actions : uint32_t
{
    auth,
    ping,
    msg,
    disconnect
};

typedef cc::net::connection<actions> connection_t;
typedef std::shared_ptr<connection_t> connection_ptr_t;
typedef cc::net::packet<actions> packet_t;
typedef cc::net::mtqueue<cc::net::owned_packet<actions>> iqueue_t;
typedef cc::net::mtqueue<packet_t> oqueue_t;

class client : public cc::net::client_interface<actions>
{
public:
    client() = default;
public:
    void draw();
    bool is_authorized();
    void auth(const std::string &login, const std::string &passwd);
private:
    std::string input_login;
    std::string input_passwd;
};