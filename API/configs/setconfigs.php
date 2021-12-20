<?php
	include("../config.php");
	
	include(conexao);
	
	$keys=array('usuario_id', 'perm');
	
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
	$perm = $obj['perm'];
	$usuario_id = $obj['usuario_id'];
	
	/*$perm = 0;
	$usuario_id = 1;*/
	
	// DADOS PARA TESTE
	/*$receita_id = 1;
	$stepnum = 1;
	$stepdesc = "descricao";*/

	$select = $mysqli->prepare("
		UPDATE usuario set usuario_permit_profissional = ? where usuario_id = ?
		");
	$select->bind_param("ss",$perm, $usuario_id);
	if($select->execute()){
		//adding the user data in response
		$response['error'] = false;
		$response['message'] = 'Permissao modificada!';
	}else{
		$response['error'] = true;
		$response['message'] = 'Permissão não modificada!';
	}

	echo json_encode($response, JSON_UNESCAPED_UNICODE);


?>