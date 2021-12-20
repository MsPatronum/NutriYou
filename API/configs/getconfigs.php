<?php
	include("../config.php");
	
	include(conexao);
	
	$keys=array('usuario_id');
	
	//
	/*for ($i = 0; $i < count($keys); $i++){
		if(!isset($obj[$keys[$i]]))
		 {
			  $response['error'] = true;
				$response['message'] = 'Required Filed Missed';
				echo json_encode($response);
			  return;
		 }
	
	}*/

	$usuario_id = 1;//$obj['usuario_id'];
	
	/*$profissionalId = 1;
	$token = "b4hshbs2cnve";*/
	
	// DADOS PARA TESTE
	/*$receita_id = 1;
	$stepnum = 1;
	$stepdesc = "descricao";*/

	$select = $mysqli->prepare("
		select usuario_id, usuario_permit_profissional from usuario where usuario_id = ?
		");
	$select->bind_param("s", $usuario_id);
	if($select->execute()){

		$select->store_result();
        if($select->num_rows == 1){
            $select->bind_result($usuario_id, $perm);
            $select->fetch();
            $configs = array('usuario_id'=>$usuario_id,
                     'usuario_permit_profissional'=>$perm);
        }

		//adding the user data in response
		$response['error'] = false;
		$response['message'] = 'Permissao selecionada!';
		$response['data'] = $configs;
	}else{
		$response['error'] = true;
		$response['message'] = 'Permissão não selecionada!';
	}

	echo json_encode($response, JSON_UNESCAPED_UNICODE);


?>