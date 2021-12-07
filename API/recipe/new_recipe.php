<?php
	include("../config.php");
	
	include(conexao);
	
	$keys=array('usuario_id','nivel_receita_id','receita_tempo_preparo','receita_porcoes','receita_nome','receita_desc','receita_modo','receita_status');
	
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
	
	$nome = $obj['receita_nome'];
	$descricao = $obj['receita_desc'];
	$nivel = $obj['nivel_receita_id'];
	$tempo_preparo = $obj['receita_tempo_preparo'];
	$porcoes = $obj['receita_porcoes'];
	$usuario_id = $obj['usuario_id'];
	$modo = $obj['receita_modo'];
	$status = $obj['receita_status'];
	
	
	// DADOS PARA TESTE
	/*$nome = 'Arroz na panela';
	$descricao = 'Receita fácil de arroz na panela';
	$nivel = 1;
	$tempo_preparo = '00:40';
	$porcoes = '4';
	$usuario_id = 1;
	$modo = 1; //1 para privado, 0 para público
	$status = 0; // 1 para publicado, 0 para em edição*/
	//FIM DOS DADOS PARA TESTE
	
	$stmt = $mysqli->prepare("INSERT INTO receita (usuario_id, nivel_receita_id, receita_tempo_preparo, receita_porcoes, receita_nome, receita_desc, recita_modo, receita_status) VALUES (?,?,?,?,?,?,?,?)");
	$stmt->bind_param("ssssssss", $usuario_id, $nivel, $tempo_preparo, $porcoes, $nome, $descricao, $modo, $status);
		
		//if the recipe is successfully added to the database
	if($stmt->execute()){
	
		//fetching the recipe back
		$stmt = $mysqli->prepare("SELECT * FROM receita WHERE usuario_id = ? ORDER BY receita_id desc limit 1");
		$stmt->bind_param("s",$usuario_id);
		$stmt->execute();
		$stmt->bind_result($receita_id, $usuario_id, $nivel, $tempo_preparo, $porcoes, $nome, $descricao, $modo, $status);
		$stmt->fetch();
	
		$recipe = array(
			'receita_id' => $receita_id,
			'usuario_id' => $usuario_id,
			'nome' => $nome,
			'descricao' => $descricao,
			'nivel' => $nivel,
			'modo' => $modo,
			'tempo_preparo' => $tempo_preparo,
			'porcoes' => $porcoes,
			'status'=>$status
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
	
	echo json_encode($response, JSON_UNESCAPED_UNICODE);


?>