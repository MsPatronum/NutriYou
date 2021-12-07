<?php
	include("../config.php");
	
	include(conexao);
	
	$keys=array('usuario_id','receita_id');
	
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
	
	$usuario_id = $obj['usuario_id'];
	$receita_id = $obj['receita_id'];
	
	// DADOS PARA TESTE
	//$receita_id = 1;
	
	//FIM DOS DADOS PARA TESTE
	
	$stmt = $mysqli->prepare("SELECT 
							    v.receita_id,
							    v.ingredientes_id,
							    v.ingredientes_desc,
							    v.receita_ingredientes_qtd,
							    v.ingredientes_base_qtd,
							    v.ingredientes_base_unity,
							    v.humidity_qtd,
							    v.humidity_unit,
							    v.protein_qtd,
							    v.protein_unit,
							    v.lipid_qtd,
							    v.lipid_unit,
							    v.carbohydrate_qtd,
							    v.carbohydrate_unit,
							    v.fiber_qtd,
							    v.fiber_unit,
							    v.energy_kcal,
							    v.energy_kj
							FROM
							    v_receita_ingredientes v
							WHERE v.receita_id = ?

							");
	$stmt->bind_param("s", $receita_id);
		
		//if the recipe is successfully added to the database
	if($stmt->execute()){
		$stmt -> store_result();
		$stmt -> bind_result($receita_id,$ingredientes_id,$ingredientes_desc,$receita_ingredientes_qtd,$ingredientes_base_qtd,$ingredientes_base_unity,$humidity_qtd,$humidity_unit,$protein_qtd,$protein_unit,$lipid_qtd,$lipid_unit,$carbohydrate_qtd,$carbohydrate_unit,$fiber_qtd,$fiber_unit,$energy_kcal,$energy_kj);
		if($stmt->num_rows() >= 1){
			$stmt->fetch();
			$ingredientes = [];
            $inc = 0;
            $stmt->execute();
			$result = $stmt->get_result();
            while ($row = $result->fetch_assoc()) {
                $ingredientes[] = array(
                	'receita_id' => $row['receita_id'],
					'ingredientes_id' => $row['ingredientes_id'],
					'ingredientes_desc' => $row['ingredientes_desc'],
					'receita_ingredientes_qtd' => $row['receita_ingredientes_qtd'],
					'ingredientes_base_qtd' => $row['ingredientes_base_qtd'],
					'ingredientes_base_unity' => $row['ingredientes_base_unity'],
					'humidity_qtd' => $row['humidity_qtd'],
					'humidity_unit' => $row['humidity_unit'],
					'protein_qtd' => $row['protein_qtd'],
					'protein_unit' => $row['protein_unit'],
					'lipid_qtd' => $row['lipid_qtd'],
					'lipid_unit' => $row['lipid_unit'],
					'carbohydrate_qtd' => $row['carbohydrate_qtd'],
					'carbohydrate_unit' => $row['carbohydrate_unit'],
					'fiber_qtd' => $row['fiber_qtd'],
					'fiber_unit' => $row['fiber_unit'],
					'energy_kcal' => $row['energy_kcal'],
					'energy_kj' => $row['energy_kj']
                );
                $inc++;
            }
            $response['error'] = false;
            $response['cod'] = 1;
            $response['message'] = 'Ingredientes retornados com sucesso.';
            //enviando a resposta
            $response['data'] = $ingredientes;
            $stmt->close();
		}else{
			$response['error'] = false;
			$response['message'] = 'Não há nenhum ingrediente';
			$stmt->close();
		}
	}else{
		$response['error'] = true;
		$response['message'] = 'Erro no retorno dos ingredientes.';
		$stmt->close();

	}
	echo json_encode($response);


?>