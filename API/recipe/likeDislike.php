<?php

	include("../config.php");

 	include(conexao);

 	$obj = json_decode($json,true);

 	$receita_id = $obj['receita_id'];
	$option = $obj['option'];
	$userId = $obj['userId'];


	print($option);

	/*$InsertQuery = "call add_receitanarefeicao($userId, $idRefeicao, $receitaId, '$today', @resultado)";


    $executa=$mysqli->query($InsertQuery);
	
	$error=$mysqli->error;

	if(empty($error)){
		
		echo json_encode(['success']);
	}else{
		echo "Falha";
		echo $error;
	}*/
	


?>