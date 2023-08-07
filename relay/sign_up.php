<?php

header( "Access-Control-Allow-Origin: *" );

http_response_code( 200 );

require "db_connection.php";

$sql = sprintf(
    "
        INSERT INTO users( name, email, password )
        VALUES ( '%s', '%s', '%s' );
    ",
    $_POST[ "name" ],
    $_POST[ "email" ],
    $_POST[ "password" ],
);

$result = $db_connection->query( $sql );

if ( $result === true ) {
    echo "OK";
}

?>
