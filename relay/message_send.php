<?php

header( "Access-Control-Allow-Origin: *" );

http_response_code( 200 );

include "db_connection.php";

$sql = sprintf(
    "
        INSERT INTO messages ( peer, text )
        VALUES ( %d, '%s' );
    ",
    $_POST[ "peer" ],
    $_POST[ "text" ],
);

$result = $db_connection->query( $sql );

?>