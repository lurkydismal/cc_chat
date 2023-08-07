<?php

header( "Access-Control-Allow-Origin: *" );

http_response_code( 200 );

require "db_connection.php";

$sql = sprintf(
    "
        SELECT *
        FROM messages
        WHERE id = %d;
    ",
    $_POST[ "id" ],
);

$result = $db_connection->query( $sql );

if ( $result === true ) {
    while ( $row = $result->fetch_array() ) {
        echo $row[ "peer" ] . "|" . $row[ "text" ] . "|" . $row[ "timestamp" ];
    }
}

?>
