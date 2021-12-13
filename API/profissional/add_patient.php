<?php
	include("../config.php");
	
	include(conexao);
	
	/*$keys=array('profissional', 'token');
	
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
	
	$profissionalId = $obj['profissional'];
	$token = $obj['token'];*/
	
	$profissionalId = 1;
	$token = "b4hshbs2cnve";
	
	// DADOS PARA TESTE
	/*$receita_id = 1;
	$stepnum = 1;
	$stepdesc = "descricao";*/

	$select = $mysqli->prepare("
		INSERT INTO paciente_profissional (paciente_id, profissional_id) value ((select usuario_id from usuario where usuario_token = '?'), ?)");
	$select->bind_param("ss",$token, $profissionalId);
	if($select->execute()){
		//adding the user data in response
		$response['error'] = false;
		$response['message'] = 'Paciente adicionado com sucesso!';
	}else{
		$response['error'] = true;
		$response['message'] = 'Paciente não adicionado!';
	}

	echo json_encode($response, JSON_UNESCAPED_UNICODE);


?>