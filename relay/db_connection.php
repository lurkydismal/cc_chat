<?php

$db_address  = "localhost:3306";
$db_username = "root";
$db_password = "secretsecret";
$db_name     = "cc_chat";

$db_connection = new mysqli(
    $db_address,
    $db_username,
    $db_password,
    $db_name,
);

if ( $db_connection->connect_errno ) {
    echo "Connection failed: " . $db_connection->connect_error;

    die( "Connection failed: " . $db_connection->connect_error );
}

?>
