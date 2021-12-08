<?php

	include("..\config.php");

 	include(conexao);

 	$ingrediente_id = $obj['ingrediente_id'];
 	//$ingrediente_id = 1;



 	$stmt = $mysqli->prepare(
 		"SELECT v.ingredientes_id,
 				v.ingredientes_desc,
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
		FROM v_ingredientes v
		where v.ingredientes_id = ? ");
    $stmt->bind_param("s", $ingrediente_id);
    

    if($stmt->execute()){
        $stmt->store_result();
        if($stmt->num_rows == 1){
            $stmt->bind_result(
            	$ingredientes_id,
				$ingredientes_desc,
				$ingredientes_base_qtd,
				$ingredientes_base_unity,
				$humidity_qtd,
				$humidity_unit,
				$protein_qtd,
				$protein_unit,
				$lipid_qtd,
				$lipid_unit,
				$carbohydrate_qtd,
				$carbohydrate_unit,
				$fiber_qtd,
				$fiber_unit,
				$energy_kcal,
				$energy_kj);
            $stmt->fetch();
            $ingrediente = array(
            	'ingredientes_id'=>$ingredientes_id,
 				'ingredientes_desc'=>$ingredientes_desc,
			    'ingredientes_base_qtd'=>$ingredientes_base_qtd,
			    'ingredientes_base_unity'=>$ingredientes_base_unity,
			    'humidity_qtd'=>$humidity_qtd,
			    'humidity_unit'=>$humidity_unit,
			    'protein_qtd'=>$protein_qtd,
			    'protein_unit'=>$protein_unit,
			    'lipid_qtd'=>$lipid_qtd,
			    'lipid_unit'=>$lipid_unit,
			    'carbohydrate_qtd'=>$carbohydrate_qtd,
			    'carbohydrate_unit'=>$carbohydrate_unit,
			    'fiber_qtd'=>$fiber_qtd,
			    'fiber_unit'=>$fiber_unit,
			    'energy_kcal'=>$energy_kcal,
			    'energy_kj'=>$energy_kj);
            $response['error'] = false;
            $response['message'] = 'Ingrediente retornado com sucesso.';
            //enviando a resposta
            $response['data'] = $ingrediente;
            $stmt->close();
        }else{
            $response['error'] = false;
            $response['message'] = 'Nao existe nada registrado aqui.';
        }
    }else{
        $response['error'] = true;
            $response['message'] = 'Erro no retorno da data';
            $stmt->close();
    }

    echo json_encode($response, JSON_UNESCAPED_UNICODE);


?>