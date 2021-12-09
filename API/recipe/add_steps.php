<?php
	include("../config.php");
	
	include(conexao);
	
	$keys=array('receita_id', 'rp_numero', 'rp_desc');
	
	//
	/*for ($i = 0; $i < count($keys); $i++){
		if(!isset($_POST[$keys[$i]]))
		 {
			  $response['error'] = true;
				$response['message'] = 'Required Filed Missed';
				echo json_encode($response);
			  return;
		 }
	
	}
	
	$receita_id = $_POST['receita_id'];
	$ingrediente_id = $_POST['ingrediente_id'];
	$qtd = $_POST['qtd'];
	*/
	
	// DADOS PARA TESTE
	$receita_id = 1;
	$stepnum = 1;
	$stepdesc = "descricao";

	$select = $mysqli->prepare("SELECT receita_id, rp_numero, rp_desc FROM receita_passos WHERE receita_id = ? ORDER BY rp_numero desc");
	$select->bind_param("s",$receita_id);
	if($select->execute()){
		//adding the user data in response
		$response['error'] = false;
		$response['message'] = 'Passo adicionado com sucesso!';
		$response['data'] = $steps;
	}else{
		$response['error'] = true;
		$response['message'] = 'Passo não adicionado!';
	}

	echo json_encode($response, JSON_UNESCAPED_UNICODE);


?>