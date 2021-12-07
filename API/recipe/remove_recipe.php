<?php

include("../config.php");

 	include(conexao);

 	$obj = json_decode($json,true);

 	$receita_id = $obj['receita_id'];

	$InsertQuery = "DELETE FROM receita WHERE (receita_id = $receita_id);";


    $executa=$mysqli->query($InsertQuery);
	$error=$mysqli->error;

	if(empty($error)){

	echo json_encode(['success']);
	}else{
	echo "Falha";
	echo $error;
}
	


?>