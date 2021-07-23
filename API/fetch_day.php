<?php
	include("config.php");

	include(conexao);
	include(funcoes);
	
	$keys=array('user_id', 'date');
	
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
	
	$user_id = $_POST['user_id'];
	$date = $_POST['date'];*/
	
	$user_id = 2;
	$date = '2021-07-23';
	
	
	//checking if the user already has a day setup
	$stmt = $mysqli->prepare("SELECT user_dia_id FROM user_dia WHERE usuario_id = ? AND  user_dia_data = ?");
	$stmt->bind_param("ss", $user_id, $date);
	$stmt->execute();
	$stmt->store_result();

	//if the day already exist in the database, select it!
	if($stmt->num_rows == 1){
		//SELECIONANDO A VIEW RESPONSÁVEL POR TRAZER O DIA SELECIONADO
		$stmt = $mysqli->prepare("SELECT udm_kcal, udm_carb, udm_prot, udm_fibra, udm_gord, udc_kcal, udc_carb, udc_prot, udc_fibra, udc_gord FROM  v_userdia WHERE usuario_id = ? AND user_dia_data = ?");
		$stmt->bind_param("ss", $user_id, $date);
		$stmt->execute();
		//adicionando todas as colunas em váriáveis
		$stmt->bind_result($udm_kcal, $udm_carb,  $udm_prot,  $udm_fibra, $udm_gord, $udc_kcal, $udc_carb, $udc_prot, $udc_fibra, $udc_gord);
		//adicionando as variáveis em um array para serem enviadas via json
		$stmt->fetch();
		$dia = array('userDiaKcal'=>$udm_kcal,
					 'userDiaCarb'=>$udm_carb, 
					 'userDiaProt'=>$udm_prot, 
					 'userDiaFibra'=>$udm_fibra,
					 'userDiaGord'=>$udm_gord,
					 'userConfigKcal'=>$udc_kcal,
					 'userConfigCarb'=>$udc_carb,
					 'userConfigProt'=>$udc_prot,
					 'userConfigFibra'=>$udc_fibra,
					 'userConfigGord'=>$udc_gord);
		$response['error'] = false;
		$response['message'] = 'Dia ja registrado.';
		//enviando a resposta
		$response['data'] = $dia;
		$stmt->close();

	//if the day doesn't exist, create it and select it!
	}else if ($stmt->num_rows == 0) {

		$stmt = $mysqli->prepare("CALL new_day(?, ?, @resposta)");
		$stmt->bind_param("ss",  $user_id, $date);


		//if the day is created successfully
		if($stmt->execute()){
			//fetching the day back
			$stmt = $mysqli->prepare("SELECT udm_kcal,udm_carb, udm_prot, udm_fibra,udm_gord, udc_kcal, udc_carb, udc_prot, udc_fibra, udc_gord FROM v_userdia WHERE usuario_id = ? AND user_dia_data = ?");
			$stmt->bind_param("ss", $user_id, $date);
			$stmt->execute();
			$stmt->bind_result($udm_kcal, $udm_carb,  $udm_prot,  $udm_fibra, $udm_gord, $udc_kcal, $udc_carb, $udc_prot, $udc_fibra, $udc_gord);
			$stmt->fetch();
			$dia = array('userDiaKcal'=>$udm_kcal,
					 'userDiaCarb'=>$udm_carb, 
					 'userDiaProt'=>$udm_prot, 
					 'userDiaFibra'=>$udm_fibra,
					 'userDiaGord'=>$udm_gord,
					 'userConfigKcal'=>$udc_kcal,
					 'userConfigCarb'=>$udc_carb,
					 'userConfigProt'=>$udc_prot,
					 'userConfigFibra'=>$udc_fibra,
					 'userConfigGord'=>$udc_gord);
			$stmt->close();

			//adding the day data in response
			$response['error'] = false;
			$response['message'] = 'Dia registrado com sucesso';
			$response['data'] = $dia;

		}else{
			$response['error'] = true;
			$response['message'] = 'Erro no retorno da data';
			$stmt->close();
		}

	}
	echo json_encode($response);


?>


		