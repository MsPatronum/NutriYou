<?php
include ("../config.php");

include (conexao);
include (funcoes);

$keys = array('usuario_id', 'user_data');

//$keys=array('user_id', 'date');
/*for ($i = 0; $i < count($keys); $i++){
		if(!isset($_POST[$keys[$i]]))
		 {
			 $response['error'] = true;
				$response['message'] = 'Required Filed Missed';
				echo json_encode($response);
			 return;
		 }
	
	}
	$usuario_id=$_POST['usuario_id'];
	$user_data=$_POST['user_data'];*/
	
	$usuario_id = 2; 
	$user_data = '2021-07-23'; 

	//check if the user already has a mood for the day
	
	$stmt = $mysqli->prepare("SELECT * FROM v_userdiamood WHERE usuario_id = ? AND user_dia_data = ?");
	$stmt->bind_param("ss", $usuario_id, $user_data);
	$stmt->execute();
	$stmt->store_result();

	if($stmt->num_rows > 0){

		$stmt->bind_result( $user_dia_mood_id, $usuario_id, $user_dia_data, $emocoes_feliz, $emocoes_sensivel, $emocoes_triste, $emocoes_raiva, $sono_0a3, $sono_3a6, $sono_6a9, $sono_9oumais, $vitalidade_ativo, $vitalidade_alta, $vitalidade_baixa, $vitalidade_exaustao, $banheiro_otimo, $banheiro_normal, $banheiro_prisaoventre, $banheiro_diarreia, $desejo_doce, $desejo_salgado, $desejo_carboidratos, $digestao_otimo, $digestao_inchaco, $digestao_enjoo, $digestao_comgases, $pele_boa, $pele_oleosa, $pele_seca, $pele_acne, $mental_focado, $mental_tranquilidade, $mental_distracao, $mental_estresse, $motivacao_motivado, $motivacao_desanimado, $motivacao_produtivo, $motivacao_preguica, $peso_kg, $exercicio_corrida, $exercicio_academia, $exercicio_bicicleta, $exercicio_natacao, $festa_bebidas, $festa_fumo, $festa_ressaca, $festa_outrassubs );

			$stmt->fetch();

			$mood = array(
				'user_dia_mood_id' => $user_dia_mood_id,
				'user_dia_data' => $user_dia_data,
				'emocoes_feliz' => $emocoes_feliz,
				'emocoes_sensivel' => $emocoes_sensivel,
				'emocoes_triste' => $emocoes_triste,
				'emocoes_raiva' => $emocoes_raiva,
				'sono_0a3' => $sono_0a3,
				'sono_3a6' => $sono_3a6,
				'sono_6a9' => $sono_6a9,
				'sono_9oumais' => $sono_9oumais,
				'vitalidade_ativo' => $vitalidade_ativo,
				'vitalidade_alta' => $vitalidade_alta,
				'vitalidade_baixa' => $vitalidade_baixa,
				'vitalidade_exaustao' => $vitalidade_exaustao,
				'banheiro_otimo' => $banheiro_otimo,
				'banheiro_normal' => $banheiro_normal,
				'banheiro_prisaoventre' => $banheiro_prisaoventre,
				'banheiro_diarreia' => $banheiro_diarreia,
				'desejo_doce' => $desejo_doce,
				'desejo_salgado' => $desejo_salgado,
				'desejo_carboidratos' => $desejo_carboidratos,
				'digestao_otimo' => $digestao_otimo,
				'digestao_inchaco' => $digestao_inchaco,
				'digestao_enjoo' => $digestao_enjoo,
				'digestao_comgases' => $digestao_comgases,
				'pele_boa' => $pele_boa,
				'pele_oleosa' => $pele_oleosa,
				'pele_seca' => $pele_seca,
				'pele_acne' => $pele_acne,
				'mental_focado' => $mental_focado,
				'mental_tranquilidade' => $mental_tranquilidade,
				'mental_distracao' => $mental_distracao,
				'mental_estresse' => $mental_estresse,
				'motivacao_motivado' => $motivacao_motivado,
				'motivacao_desanimado' => $motivacao_desanimado,
				'motivacao_produtivo' => $motivacao_produtivo,
				'motivacao_preguica' => $motivacao_preguica,
				'peso_kg' => $peso_kg,
				'exercicio_corrida' => $exercicio_corrida,
				'exercicio_academia' => $exercicio_academia,
				'exercicio_bicicleta' => $exercicio_bicicleta,
				'exercicio_natacao' => $exercicio_natacao,
				'festa_bebidas' => $festa_bebidas,
				'festa_fumo' => $festa_fumo,
				'festa_ressaca' => $festa_ressaca,
				'festa_outrassubs' => $festa_outrassubs
			);

			$stmt->close();
			$response['error'] = false;
			$response['message'] = 'Mood capturado com sucesso';
			$response['data'] = $mood;
	}else{
		$response['error'] = true;
		$response['message'] = 'Não há nada aqui.';
		$stmt->close();

	}
	echo json_encode($response, JSON_UNESCAPED_UNICODE);

?>