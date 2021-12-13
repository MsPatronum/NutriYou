<?php

	include("..\config.php");

 	include(conexao);
 	include(funcoes);

 	$usuario_id = $obj['usuario_id'];

 	$CheckSQL = "
 		SELECT ud.usuario_id, ud.user_dia_data, udm.udc_kcal, udm.udm_kcal FROM user_dia ud, user_dia_macros udm where udm.user_dia_id = ud.user_dia_id and ud.usuario_id = ?";

 	$stmt = $mysqli->prepare($CheckSQL);

 	$stmt->bind_param("s", $usuario_id);
 	if($stmt->execute()){
 		$result = $stmt->get_result();
		$stmt -> store_result();
		$stmt -> bind_result($usuario_id, $user_dia_data, $config_kcal, $dia_kcal);

		if($result->num_rows >0) {

			while($data = $result->fetch_assoc()) { 
				if($data['udm_kcal'] > $data['udc_kcal']){

					$detaildia[] = array(
						'data'=>$data['user_dia_data'],
						'udc_kcal'=>$data['udc_kcal'],
						'udm_kcal'=>$data['udm_kcal'],
						'class'=>'red'
					);
				}else{
					$detaildia[] = array(
						'data'=>$data['user_dia_data'],
						'udc_kcal'=>$data['udc_kcal'],
						'udm_kcal'=>$data['udm_kcal'],
						'class'=>'green'
					);
				}	
			}
			$data['usuario_id'] = $usuario_id;
			$data['detalhes'] = $detaildia;
			

			$response['error'] = false;
			$response['cod'] = 200;
            $response['message'] = 'Lista de datas retornada com sucesso.';
            //enviando a resposta
            $response['data'] = $data;
            $stmt->close();
		}else{
			$response['error'] = true;
			$response['cod'] = 204;
            $response['message'] = "Não foi possível retornar nenhum dado.";
		}
	}else{
		$response['error'] = false;
		$response['cod'] = 400;
        $response['message'] = 'Não foi possível executar a query de retorno.';
	}
 	
	$json = json_encode($response, JSON_NUMERIC_CHECK);
	echo $json;

?>