<?php

header( "Access-Control-Allow-Origin: *" );

http_response_code( 200 );

require "db_connection.php";

// $sql = sprintf(
//     "
//         INSERT INTO users( name, email, password )
//         VALUES ( '%s', '%s', '%s' );
//     ",
//     $_POST[ "name" ],
//     $_POST[ "email" ],
//     $_POST[ "password" ],
// );

// $result = $db_connection->query( $sql );

$SQLQuery = $mysqli->prepare(
    "
        INSERT INTO users( name, email, password )
        VALUES ( ?, ?, ? );
    "
);

$name = $mysqli->real_escape_string( $_POST[ "name" ] );
$email = $mysqli->real_escape_string( $_POST[ "email" ] );
$password = $mysqli->real_escape_string( $_POST[ "password" ] );

$SQLQuery->bind_param( "sss", $name, $email, $password );

$result = $SQLQuery->execute();

if ( $result === true ) {
    echo "OK";

} else {
    die( "Failed to sign up user: " . $db_connection->error );
}

?>
