<?php

header( "Access-Control-Allow-Origin: *" );

http_response_code( 200 );

require "db_connection.php";

// $sql = sprintf(
//     "
//         SELECT (name)
//         FROM users
//         WHERE id = %d;
//     ",
//     $_POST[ "id" ],
// );

// $result = $db_connection->query( $sql );

$SQLQuery = $mysqli->prepare(
    "
        SELECT (name)
        FROM users
        WHERE id = ?;
    "
);

$id = $mysqli->real_escape_string( $_POST[ "id" ] );

$SQLQuery->bind_param( "i", $id );

$result = $SQLQuery->execute();

if ( $result === true ) {
    while ( $row = $result->fetch_array() ) {
        echo $row[ "name" ];
    }

} else {
    die( "Failed to get user: " . $db_connection->error );
}

?>
