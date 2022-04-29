#include <iostream>
#include <cryptopp/hex.h>
#include <cryptopp/sha.h>
#include <soci/soci.h>
#include <soci/mysql/soci-mysql.h>
#include <stdexcept>
#include <vector>

void printUsage( void ) {
    std::cout
        << "tool_useradd usage:"               << std::endl
        << "./tool_useradd <login> <password>" << std::endl
    << std::endl;
}

int main( const int argc, const char* argv[] ) {
    if ( argc < 3 ) {
        printUsage();

        return ( EXIT_FAILURE );
    }

    std::string encodedPassword;
    uint8_t     encodedBuffer[ CryptoPP::SHA512::DIGESTSIZE ];
    const std::string            dbLogin    = argv[ 1 ];
    const std::vector< uint8_t > dbPassword = argv[ 2 ];

    ( new CryptoPP::SHA512 ).CalculateDigest(
        encodedBuffer,
        dbPassword.data(),
        dbPassword.size(),
    );
    CryptoPP::HexEncoder hexEncoder(
        new CryptoPP::StringSink( encodedPassword )
    );
    hexEncoder.Put(
        encodedBuffer,
        CryptoPP::SHA512::DIGESTSIZE
    );
    hexEncoder.MessageEnd();
    soci::session SQLConnection(
        soci::mysql,
        (
            "db=" +
            MYSQL_DB +
            " user=" +
            MYSQL_USER +
            " password=\'" +
            MYSQL_PASSWD +
            "\' host=" +
            MYSQL_HOST +
            " port=" +
            std::to_string( MYSQL_PORT )
        )
    );

    if ( !SQLConnection.is_connected() ) {
        throw (
            std::exception( "Unable to connect to mysql server" )
        );
    }

    std::string tableContent;

    SQLConnection.once
        << "select user from users where user=:login",
        soci::use( dbLogin ),
        soci::into( tableContent );

    if ( !tableContent.empty() ) {
        throw (
            std::exception( "User exists" )
        );
    }

    SQLConnection.once
        << "insert into users( user, passwd ) values( :login, :passwd )",
        soci::use( dbLogin ),
        soci::use( encodedPassword );

    return ( EXIT_SUCCESS );
}
