<?php

include("../config.php");

 	include(conexao);

 	$obj = json_decode($json,true);

 	$receitaId = $obj['receita_id'];
	$ingredienteId = $obj['ingrediente_id'];

	$InsertQuery = "call remove_ingredient($receitaId, $ingredienteId)";


    $executa=$mysqli->query($InsertQuery);
	$error=$mysqli->error;

	if(empty($error)){

	echo json_encode(['success']);
	}else{
	echo "Falha";
	echo $error;
}
	


?>