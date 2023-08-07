<?php

header( "Access-Control-Allow-Origin: *" );

http_response_code( 200 );

require "db_connection.php";

// $sql = sprintf(
//     "
//         SELECT *
//         FROM users
//         WHERE email = '%s' AND password = '%s';
//     ",
//     $_POST[ "email" ],
//     $_POST[ "password" ],
// );

// $result = $db_connection->query( $sql );

$SQLQuery = $mysqli->prepare(
    "
        SELECT *
        FROM users
        WHERE email = ? AND password = ?;
    "
);

if ( isset( $_POST[ "email" ] ) === false ) {
    die( "Failed to get user email: " . $db_connection->error );
}

$email = $mysqli->real_escape_string( $_POST[ "email" ] );

if ( isset( $_POST[ "password" ] ) === false ) {
    die( "Failed to get user password: " . $db_connection->error );
}

$password = $mysqli->real_escape_string( $_POST[ "password" ] );

$SQLQuery->bind_param( "ss", $email, $password );

$result = $SQLQuery->execute();

if ( $result === true ) {
    while ( $row = $result->fetch_array() ) {
        echo $row[ "id" ] . "|" . $row[ "name" ] . "|" . $row[ "email" ];
    }

} else {
    die( "Login failed: " . $db_connection->error );
}

?>
