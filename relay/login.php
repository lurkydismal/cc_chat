<?php

header( "Access-Control-Allow-Origin: *" );

http_response_code( 200 );

include "db_connection.php";

$sql = sprintf(
    "
        SELECT *
        FROM users
        WHERE email = '%s' AND password = '%s';
    ",
    $_POST[ "email" ],
    $_POST[ "password" ],
);

$result = $db_connection->query( $sql );

if ( $result ) {
    while ( $row = $result->fetch_array() ) {
        echo $row[ "id" ] . "|" . $row[ "name" ] . "|" . $row[ "email" ];
    }
}

?>