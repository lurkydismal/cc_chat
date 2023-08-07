<?php

header( "Access-Control-Allow-Origin: *" );

http_response_code( 200 );

require "db_connection.php";

$SQLQuery = $mysqli->prepare(
    "
        SELECT *
        FROM users
        WHERE email = ? AND password = ?;
    "
);

if ( filter_input( INPUT_POST, "email", FILTER_VALIDATE_EMAIL ) === false ) {
    die( "Failed to get user email: " . $db_connection->error );
}

$email = filter_input( INPUT_POST, "email" );

if ( filter_input( INPUT_POST, "password" ) === false ) {
    die( "Failed to get user password: " . $db_connection->error );
}

$password = htmlspecialchars( filter_input( INPUT_POST, "password" ) );

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
