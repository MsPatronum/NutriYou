<?php 
$mysqli = new mysqli('localhost','root','','tcc_database');

mysqli_set_charset($mysqli, "utf8");

 // Getting the received JSON into $json variable.
	$json = file_get_contents('php://input');

	// Decoding the received JSON and store into $obj variable.
	$obj = json_decode($json,true);

?>