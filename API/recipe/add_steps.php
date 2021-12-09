<?php
	include("../config.php");
	
	include(conexao);
	
	$keys=array('receita_id', 'rp_numero', 'rp_desc');
	
	//
	for ($i = 0; $i < count($keys); $i++){
		if(!isset($obj[$keys[$i]]))
		 {
			  $response['error'] = true;
				$response['message'] = 'Required Filed Missed';
				echo json_encode($response);
			  return;
		 }
	
	}
	
	$receita_id = $obj['receita_id'];
	$rp_numero = $obj['rp_numero'];
	$rp_desc = $obj['rp_desc'];
	
	
	// DADOS PARA TESTE
	/*$receita_id = 1;
	$stepnum = 1;
	$stepdesc = "descricao";*/

	$select = $mysqli->prepare("INSERT INTO receita_passos (receita_id, rp_numero, rp_desc) values (?,?,?) ");
	$select->bind_param("sss",$receita_id, $rp_numero, $rp_desc);
	if($select->execute()){
		//adding the user data in response
		$response['error'] = false;
		$response['message'] = 'Passo adicionado com sucesso!';
	}else{
		$response['error'] = true;
		$response['message'] = 'Passo não adicionado!';
	}

	echo json_encode($response, JSON_UNESCAPED_UNICODE);


?>