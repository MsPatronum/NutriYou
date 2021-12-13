<?php

include("../config.php");

 	include(conexao);

 	$obj = json_decode($json,true);

 	$idRefeicao = $obj['refeicao_id'];
	$userId = $obj['user_id'];
	$receitaId = $obj['cod_receita'];
	$porcoes = $obj['porcao'];
	$today = $obj['data'];

	$InsertQuery = "call add_receitanarefeicao($userId, $idRefeicao, $receitaId, $porcoes, '$today', @resposta)";



    $executa=$mysqli->query($InsertQuery);
	
	$error=$mysqli->error;

	if(empty($error)){
		
		echo json_encode(['success']);
	}else{
		echo "Falha";
		echo $error;
	}
	


?>