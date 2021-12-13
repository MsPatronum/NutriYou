<?php 

	include("..\config.php");

 	include(conexao);
 	include(funcoes);

 	$usuario_id = 1;


	$query = "SELECT p.usuario_id, CONCAT(p.usuario_nome, ' ', p.usuario_sobrenome) AS nome_completo, p.usuario_token FROM usuario u, usuario p, paciente_profissional pp WHERE u.usuario_permit_profissional = 1 AND u.usuario_id = pp.profissional_id AND pp.paciente_id = p.usuario_id and u.usuario_id = ?";

	$stmt = $mysqli->prepare($query);

 	$stmt->bind_param("s", $usuario_id);
 	if($stmt->execute()){
 		$result = $stmt->get_result();
		$stmt -> store_result();
		$stmt -> bind_result($paciente_id, $nome_completo, $paciente_token);

		if($result->num_rows >0) {

			while($data = $result->fetch_assoc()) { 
				$listpatients[] = array(
					'paciente_id'=>$data['usuario_id'],
					'nome_completo'=>$data['nome_completo'],
					'paciente_token'=>$data['usuario_token']
				);
			}
			$data['usuario_id'] = $usuario_id;
			$data['list_patients'] = $listpatients;

			$response['error'] = false;
			$response['cod'] = 200;
            $response['message'] = 'Lista de pacientes retornada com sucesso.';
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