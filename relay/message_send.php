<?php

header( "Access-Control-Allow-Origin: *" );

http_response_code( 200 );

require "db_connection.php";

$SQLQuery = $mysqli->prepare(
    "
        INSERT INTO messages ( peer, text )
        VALUES ( ?, ? );
    "
);

if ( is_int( filter_input( INPUT_POST, "peer", FILTER_VALIDATE_INT ) ) === false ) {
    die( htmlspecialchars( "Failed to get message peer: " . $db_connection->error ) );
}

$peer = filter_input( INPUT_POST, "peer" );

if ( filter_input( INPUT_POST, "text" ) === false ) {
    die( htmlspecialchars( "Failed to get message text: " . $db_connection->error ) );
}

$text = htmlspecialchars( filter_input( INPUT_POST, "text" ) );

$SQLQuery->bind_param( "is", $peer, $text );

$result = $SQLQuery->execute();

if ( $result === false ) {
    echo htmlspecialchars( "Message send failed: " . $db_connection->error );

    die( htmlspecialchars( "Message send failed: " . $db_connection->error ) );
}

?>
