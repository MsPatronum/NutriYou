<?php
	include("../config.php");
	
	include(conexao);
	
	$keys=array('receita_id', 'ingrediente_id', 'quantidade');
	
	
	for ($i = 0; $i < count($keys); $i++){
		if(!isset($obj[$keys[$i]]))
		 {
			  $response['error'] = true;
				$response['message'] = 'Required Filed Missed';
				echo json_encode($response);
			  return;
		 }
	
	}
	
	$receita_id = $obj['receita_id'];
	$ingrediente_id = $obj['ingrediente_id'];
	$quantidade = $obj['quantidade'];
	

	//setar quantidade para a configurada 100 gramas

	$qtd = $quantidade/100;

	$stmt = $mysqli->prepare("INSERT INTO receita_ingredientes (receita_id, ingredientes_id, receita_ingredientes_qtd) VALUES (?, ?, ?)");
	$stmt->bind_param("sss", $receita_id, $ingrediente_id, $qtd);

	if($stmt->execute()){
    	echo json_encode(['success']);

    	$nutrireceita = $mysqli->prepare("
    		SELECT 
    			receita_id, 
    			humidity_qtd, 
    			humidity_unit,
    			protein_qtd,
    			protein_unit,
    			lipid_qtd,
    			lipid_unit,
    			carbohydrate_qtd,
    			carbohydrate_unit,
    			fiber_qtd,
    			finer_unit,
    			energy_kcal,
    			energy_kj
    		FROM 
    			receita_val_nutricional
    		WHERE receita_id = ?
    		");
    	$nutrireceita->bind_param("s", $receita_id);
    	if($nutrireceita->execute()){
    		$nutrireceita->store_result();
    		if($nutrireceita->num_rows == 1){
    			$nutrireceita->bind_result(
    				$rec_receita_id,
					$rec_humidity_qtd,
					$rec_humidity_unit,
					$rec_protein_qtd,
					$rec_protein_unit,
					$rec_lipid_qtd,
					$rec_lipid_unit,
					$rec_carbohydrate_qtd,
					$rec_carbohydrate_unit,
					$rec_fiber_qtd,
					$rec_finer_unit,
					$rec_energy_kcal,
					$rec_energy_kj);

    			$nutriingrediente = $mysqli->prepare("
    				SELECT 
		    			ingrediente_id, 
		    			humidity_qtd, 
		    			humidity_unit,
		    			protein_qtd,
		    			protein_unit,
		    			lipid_qtd,
		    			lipid_unit,
		    			carbohydrate_qtd,
		    			carbohydrate_unit,
		    			fiber_qtd,
		    			finer_unit,
		    			energy_kcal,
		    			energy_kj
		    		FROM 
		    			receita_val_nutricional
		    		WHERE ingrediente_id = ?
    			");
    			$nutriingrediente->bind_param("s", $ingrediente_id);
    			if($nutriingrediente->execute()){
    				$nutriingrediente->store_result();
    				if($nutriingrediente->num_rows == 1){
    					$nutriingrediente->bind_result(
    						$ing_ingrediente_id,
							$ing_humidity_qtd,
							$ing_humidity_unit,
							$ing_protein_qtd,
							$ing_protein_unit,
							$ing_lipid_qtd,
							$ing_lipid_unit,
							$ing_carbohydrate_qtd,
							$ing_carbohydrate_unit,
							$ing_fiber_qtd,
							$ing_finer_unit,
							$ing_energy_kcal,
							$ing_energy_kj);

    					$new_humidity_qtd = $ing_humidity_qtd + $rec_humidity_qtd;
						$new_humidity_unit = $ing_humidity_unit + $rec_humidity_unit;
						$new_protein_qtd = $ing_protein_qtd + $rec_protein_qtd;
						$new_protein_unit = $ing_protein_unit + $rec_protein_unit;
						$new_lipid_qtd = $ing_lipid_qtd + $rec_lipid_qtd;
						$new_lipid_unit = $ing_lipid_unit + $rec_lipid_unit;
						$new_carbohydrate_qtd = $ing_carbohydrate_qtd + $rec_carbohydrate_qtd;
						$new_carbohydrate_unit = $ing_carbohydrate_unit + $rec_carbohydrate_unit;
						$new_fiber_qtd = $ing_fiber_qtd + $rec_fiber_qtd;
						$new_finer_unit = $ing_finer_unit + $rec_finer_unit;
						$new_energy_kcal = $ing_energy_kcal + $rec_energy_kcal;
						$new_energy_kj = $ing_energy_kj + $rec_energy_kj;

						$update = $mysqli->prepare("
							UPDATE receita_val_nutricional
							")








    				}else{
    					$response['error'] = true;
						$response['message'] = 'Conflito de ID de ingrediente';
						$stmt->close();
						$nutrireceita->close();
						$nutriingrediente->close();
    				}
    			}else{
    				$response['error'] = true;
					$response['message'] = 'Não foi possível buscar os valores nutricionais do ingrediente';
					$stmt->close();
					$nutrireceita->close();
					$nutriingrediente->close();
    			}
    		}else{
    			$response['error'] = true;
				$response['message'] = 'Conflito de ID de receita';
				$stmt->close();
				$nutrireceita->close();
    		}
    	}else{
    		$response['error'] = true;
			$response['message'] = 'Nao foi possível buscar os valores nutricionais da receita';
			$stmt->close();
			$nutrireceita->close();
			$nutriingrediente->close();
    	}

    }else{
    	$response['error'] = true;
		$response['message'] = 'Erro ao inserir ingredientes na receita';
		$stmt->close();
		$nutrireceita->close();
		$nutriingrediente->close();
	}	
    echo json_encode($response, JSON_UNESCAPED_UNICODE);



?>