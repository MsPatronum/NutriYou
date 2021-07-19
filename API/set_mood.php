<?php
	include("config.php");

	include(conexao);
	include(funcoes);
	
	$keys=array( 'emocoes_feliz', 'emocoes_sensivel', 'emocoes_triste', 'emocoes_raiva', 'sono_0a3', 'sono_3a6', 'sono_6a9', 'sono_9oumais', 'vitalidade_ativo', 'vitalidade_alta', 'vitalidade_baixa', 'vitalidade_exaustao', 'banheiro_otimo', 'banheiro_normal', 'banheiro_prisaoventre', 'banheiro_diarreia', 'desejo_doce', 'desejo_salgado', 'desejo_carboidratos', 'digestao_otimo', 'digestao_inchaco', 'digestao_enjoo', 'digestao_comgases', 'pele_boa', 'pele_oleosa', 'pele_seca', 'pele_acne', 'mental_focado', 'mental_tranquilidade', 'mental_distracao', 'mental_estresse', 'motivacao_motivado', 'motivacao_desanimado', 'motivacao_produtivo', 'motivacao_preguica', 'peso_kg', 'exercicio_corrida', 'exercicio_academia', 'exercicio_bicicleta', 'exercicio_natacao', 'festa_bebidas', 'festa_fumo', 'festa_ressaca', 'festa_outrassubs');

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
	$emocoes_feliz=$_POST['emocoes_feliz']; $emocoes_sensivel=$_POST['emocoes_sensivel']; $emocoes_triste=$_POST['emocoes_triste']; $emocoes_raiva=$_POST['emocoes_raiva']; $sono_0a3=$_POST['sono_0a3']; $sono_3a6=$_POST['sono_3a6']; $sono_6a9=$_POST['sono_6a9']; $sono_9oumais=$_POST['sono_9oumais']; $vitalidade_ativo=$_POST['vitalidade_ativo']; $vitalidade_alta=$_POST['vitalidade_alta']; $vitalidade_baixa=$_POST['vitalidade_baixa']; $vitalidade_exaustao=$_POST['vitalidade_exaustao']; $banheiro_otimo=$_POST['banheiro_otimo']; $banheiro_normal=$_POST['banheiro_normal']; $banheiro_prisaoventre=$_POST['banheiro_prisaoventre']; $banheiro_diarreia=$_POST['banheiro_diarreia']; $desejo_doce=$_POST['desejo_doce']; $desejo_salgado=$_POST['desejo_salgado']; $desejo_carboidratos=$_POST['desejo_carboidratos']; $digestao_otimo=$_POST['digestao_otimo']; $digestao_inchaco=$_POST['digestao_inchaco']; $digestao_enjoo=$_POST['digestao_enjoo']; $digestao_comgases=$_POST['digestao_comgases']; $pele_boa=$_POST['pele_boa']; $pele_oleosa=$_POST['pele_oleosa']; $pele_seca=$_POST['pele_seca']; $pele_acne=$_POST['pele_acne']; $mental_focado=$_POST['mental_focado']; $mental_tranquilidade=$_POST['mental_tranquilidade']; $mental_distracao=$_POST['mental_distracao']; $mental_estresse=$_POST['mental_estresse']; $motivacao_motivado=$_POST['motivacao_motivado']; $motivacao_desanimado=$_POST['motivacao_desanimado']; $motivacao_produtivo=$_POST['motivacao_produtivo']; $motivacao_preguica=$_POST['motivacao_preguica']; $peso_kg=$_POST['peso_kg']; $exercicio_corrida=$_POST['exercicio_corrida']; $exercicio_academia=$_POST['exercicio_academia']; $exercicio_bicicleta=$_POST['exercicio_bicicleta']; $exercicio_natacao=$_POST['exercicio_natacao']; $festa_bebidas=$_POST['festa_bebidas']; $festa_fumo=$_POST['festa_fumo']; $festa_ressaca=$_POST['festa_ressaca']; $festa_outrassubs=$_POST['festa_outrassubs'];*/
	
	$emocoes_feliz=1; $emocoes_sensivel=1; $emocoes_triste=1; $emocoes_raiva=0; $sono_0a3=0; $sono_3a6=0; $sono_6a9=0; $sono_9oumais=1; $vitalidade_ativo=1; $vitalidade_alta=1; $vitalidade_baixa=0; $vitalidade_exaustao=0; $banheiro_otimo=1; $banheiro_normal=1; $banheiro_prisaoventre=0; $banheiro_diarreia=0; $desejo_doce=1; $desejo_salgado=0; $desejo_carboidratos=1; $digestao_otimo=0; $digestao_inchaco=1; $digestao_enjoo=0; $digestao_comgases=1; $pele_boa=0; $pele_oleosa=1; $pele_seca=0; $pele_acne=1; $mental_focado=1; $mental_tranquilidade=0; $mental_distracao=0; $mental_estresse=0; $motivacao_motivado=0; $motivacao_desanimado=0; $motivacao_produtivo=0; $motivacao_preguica=1; $peso_kg=82.5; $exercicio_corrida=1; $exercicio_academia=1; $exercicio_bicicleta=1; $exercicio_natacao=0; $festa_bebidas=0; $festa_fumo=0; $festa_ressaca=0; $festa_outrassubs=0;

	?>