<?php
	include("../config.php");
	
	include(conexao);
	
	$keys=array('receita_id', 'ingrediente_id', 'qtd');
	
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
	$ingrediente_id = 4;
	$qtd = 150; //em gramas

	//FIM DOS DADOS PARA TESTE

	//preciso passar a quantidade de gramas para a medida cadastrada, cada 100 gramas
	$qtd_ingrediente = $qtd/100;
	
	$stmt = $mysqli->prepare("INSERT INTO receita_ingredientes (receita_id, ingredientes_id, receita_ingredientes_qtd) VALUES (?,?,?)");
	$stmt->bind_param("sss", $receita_id, $ingrediente_id, $qtd_ingrediente);
		
		//if the recipe is successfully added to the database
	if($stmt->execute()){
	
		//fetching the user back
		$stmt = $mysqli->prepare("SELECT * FROM receita WHERE usuario_id = ? ORDER BY receita_id desc limit 1");
		$stmt->bind_param("s",$usuario_id);
		$stmt->execute();
		$stmt->bind_result($receita_id, $usuario_id, $nivel, $tempo_preparo, $porcoes, $nome, $descricao, $modo);
		$stmt->fetch();
	
		$recipe = array(
			'receita_id' => $receita_id,
			'usuario_id' => $usuario_id,
			'nome' => $nome,
			'descricao' => $descricao,
			'nivel' => $nivel,
			'modo' => $modo,
			'tempo_preparo' => $tempo_preparo,
			'porcoes' => $porcoes
		);
	
		$stmt->close();
	
		//adding the user data in response
		$response['error'] = false;
		$response['message'] = 'Ingrediente adicionado com sucesso!';
		$response['data'] = $user;
	
	}else{
		$response['error'] = true;
		$response['message'] = 'Erro ao adicionar o ingrediente na receita.';
		$stmt->close();
	}
	
	echo json_encode($response);


?>