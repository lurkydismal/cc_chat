<?php

header( "Access-Control-Allow-Origin: *" );

http_response_code( 200 );

require "db_connection.php";

$SQLQuery = $mysqli->prepare(
    "
        SELECT *
        FROM messages
        WHERE id = ?;
    "
);

if ( is_int( filter_input( INPUT_POST, "id", FILTER_VALIDATE_INT ) ) === false ) {
    die( "Failed to get message id: " . $db_connection->error );
}

$id = filter_input( INPUT_POST, "id" );

$SQLQuery->bind_param( "i", $id );

$result = $SQLQuery->execute();

if ( $result === true ) {
    while ( $row = $result->fetch_array() ) {
        echo $row[ "peer" ] . "|" . $row[ "text" ] . "|" . $row[ "timestamp" ];
    }

} else {
    die( "Failed to get message: " . $db_connection->error );
}

?>
