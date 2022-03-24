#include <iostream>
#include <cryptopp/hex.h>
#include <cryptopp/sha.h>
#include <soci/soci.h>
#include <soci/mysql/soci-mysql.h>
#include <stdexcept>

void usage()
{
    std::cout   << "tool_useradd usage:" << std::endl
                << "./tool_useradd <login> <password>" << std::endl << std::endl;
}

int main(int argc, char** argv)
{
    if (argc < 3)
    {
        usage();
        return 1;
    }
    std::string login = argv[1];
    std::string passwd = argv[2];
    std::string encoded_passwd;

    CryptoPP::SHA512 encoder;
    uint8_t encoded_buff[CryptoPP::SHA512::DIGESTSIZE];
    encoder.CalculateDigest(encoded_buff, reinterpret_cast<const uint8_t*>(passwd.c_str()), passwd.size());
    CryptoPP::HexEncoder hex_to_str(new CryptoPP::StringSink(encoded_passwd));
    hex_to_str.Put(encoded_buff, CryptoPP::SHA512::DIGESTSIZE);
    hex_to_str.MessageEnd();

    try
    {
        soci::session sql(soci::mysql, std::string("db=") + MYSQL_DB + " user=" + MYSQL_USER + " password='" + MYSQL_PASSWD + "' host=" + MYSQL_HOST + " port=" + std::to_string(MYSQL_PORT));
        if (!sql.is_connected())
            throw std::runtime_error("Unable to connect to mysql server");
        std::string temp;
        sql.once << "select user from users where user=:login", soci::use(login), soci::into(temp);
        if (!temp.empty())
            throw std::runtime_error("User exists");
        sql.once << "insert into users(user, passwd) values(:login, :passwd)", soci::use(login), soci::use(encoded_passwd);
    }
    catch(const std::exception& e)
    {
        std::cerr << e.what() << '\n';
        return 1;
    }
    return 0;
}