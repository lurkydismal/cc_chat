<?php

header( "Access-Control-Allow-Origin: *" );

http_response_code( 200 );

require "db_connection.php";

$SQLQuery = $mysqli->prepare(
    "
        INSERT INTO users( name, email, password )
        VALUES ( ?, ?, ? );
    "
);

if ( filter_input( INPUT_POST, "name" ) === false ) {
    die( htmlspecialchars( "Failed to set user name: " . $db_connection->error ) );
}

$name = htmlspecialchars( filter_input( INPUT_POST, "name" ) );

if ( filter_input( INPUT_POST, "email", FILTER_VALIDATE_EMAIL ) === false ) {
    die( htmlspecialchars( "Failed to set user email: " . $db_connection->error ) );
}

$email = filter_input( INPUT_POST, "email" );

if ( filter_input( INPUT_POST, "password" ) === false ) {
    die( htmlspecialchars( "Failed to set user password: " . $db_connection->error ) );
}

$password = htmlspecialchars( filter_input( INPUT_POST, "password" ) );

$SQLQuery->bind_param( "sss", $name, $email, $password );

$result = $SQLQuery->execute();

if ( $result === true ) {
    echo htmlspecialchars( "OK" );

} else {
    die( htmlspecialchars( "Failed to sign up user: " . $db_connection->error ) );
}

?>
