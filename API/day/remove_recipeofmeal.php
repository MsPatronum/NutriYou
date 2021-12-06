<?php

include("../config.php");

 	include(conexao);

 	$obj = json_decode($json,true);

 	$idRefeicao = $obj['refeicao_id'];
	$userId = $obj['user_id'];
	$udmId = $obj['udmId'];
	$receitaId = $obj['cod_receita'];
	$today = $obj['data'];

	$InsertQuery = "call remove_receitadarefeicao($userId, $idRefeicao, $udmId, $receitaId, '$today', @resultado)";


    $executa=$mysqli->query($InsertQuery);
	$error=$mysqli->error;

	if(empty($error)){

	echo json_encode(['success']);
	}else{
	echo "Falha";
	echo $error;
}
	


?>