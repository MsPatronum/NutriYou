<?php
	include("../config.php");
	
	include(conexao);
	
	$keys=array('nome', 'descricao', 'nivel', 'tempo_preparo', 'porcoes', 'usuario_id', 'modo');
	
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
	
	$nome = $_POST['nome'];
	$descricao = $_POST['descricao'];
	$nivel = $_POST['nivel'];
	$tempo_preparo = $_POST['tempo_preparo'];
	$porcoes = $_POST['porcoes'];
	$usuario_id = $_POST['usuario_id'];
	$modo = $_POST['modo'];
	*/
	
	// DADOS PARA TESTE
	$nome = 'Arroz na panela';
	$descricao = 'Receita fácil de arroz na panela';
	$nivel = 1;
	$tempo_preparo = '00:40';
	$porcoes = '4';
	$usuario_id = 1;
	$modo = 1; //1 para privado, 0 para público
	//FIM DOS DADOS PARA TESTE
	
	$stmt = $mysqli->prepare("INSERT INTO receita (usuario_id, nivel_receita_id, receita_tempo_preparo, receita_porcoes, receita_nome, receita_desc, recita_modo) VALUES (?,?,?,?,?,?,?)");
	$stmt->bind_param("sssssss", $usuario_id, $nivel, $tempo_preparo, $porcoes, $nome, $descricao, $modo);
		
		//if the recipe is successfully added to the database
	if($stmt->execute()){
	
		//fetching the recipe back
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
	
		//adding the recipe data in response
		$response['error'] = false;
		$response['message'] = 'Receita registrado com sucesso!';
		$response['data'] = $recipe;
	
	}else{
		$response['error'] = true;
		$response['message'] = 'Erro na criação da receita.';
		$stmt->close();
	}
	
	echo json_encode($response);


?>