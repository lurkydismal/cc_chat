<?php

header( "Access-Control-Allow-Origin: *" );

http_response_code( 200 );

require "db_connection.php";

// $sql = sprintf(
//     "
//         INSERT INTO messages ( peer, text )
//         VALUES ( %d, '%s' );
//     ",
//     $_POST[ "peer" ],
//     $_POST[ "text" ],
// );

// $result = $db_connection->query( $sql );

$SQLQuery = $mysqli->prepare(
    "
        INSERT INTO messages ( peer, text )
        VALUES ( ?, ? );
    "
);

$peer = $mysqli->real_escape_string( $_POST[ "peer" ] );
$text = $mysqli->real_escape_string( $_POST[ "text" ] );

$SQLQuery->bind_param( "is", $peer, $text );

$result = $SQLQuery->execute();

if ( $result === false ) {
    echo "Message send failed: " . $db_connection->error;

    die( "Message send failed: " . $db_connection->error );
}

?>
