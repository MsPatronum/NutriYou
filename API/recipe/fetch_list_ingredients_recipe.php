<?php

	include("..\config.php");

 	include(conexao);

 	$receita_id = $obj['receita_id'];
 	//$receita_id = 12;



 	$stmt = $mysqli->prepare(
 		"SELECT  receita_id,
		    ingredientes_id,
		    ingredientes_desc,
		    ingredientes_base_qtd,
		    ingredientes_base_unity,
		    humidity_qtd,
		    humidity_unit,
		    protein_qtd,
		    protein_unit,
		    lipid_qtd,
		    lipid_unit,
		    carbohydrate_qtd,
		    carbohydrate_unit,
		    fiber_qtd,
		    fiber_unit,
		    energy_kcal,
		    energy_kj
		FROM v_receita_ingredientes
		where receita_id = ?
			");
    $stmt->bind_param("s", $receita_id);
    

    if($stmt->execute()){
        $stmt->store_result();
        $stmt->bind_result(
        	$receita_id,
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
        $stmt->store_result();
        if($stmt->num_rows >= 1){
        	$ingredientes = [];
            $inc = 0;
            $stmt->execute();
            $result = $stmt->get_result();
            while ($row = $result->fetch_assoc()) {
                $ingredientes[] = array(
                	'receita_id'=>$row['receita_id'],
                    'ingredientes_id'=>$row['ingredientes_id'],
	 				'ingredientes_desc'=>$row['ingredientes_desc'],
				    'ingredientes_base_qtd'=>$row['ingredientes_base_qtd'],
				    'ingredientes_base_unity'=>$row['ingredientes_base_unity'],
				    'humidity_qtd'=>$row['humidity_qtd'],
				    'humidity_unit'=>$row['humidity_unit'],
				    'protein_qtd'=>$row['protein_qtd'],
				    'protein_unit'=>$row['protein_unit'],
				    'lipid_qtd'=>$row['lipid_qtd'],
				    'lipid_unit'=>$row['lipid_unit'],
				    'carbohydrate_qtd'=>$row['carbohydrate_qtd'],
				    'carbohydrate_unit'=>$row['carbohydrate_unit'],
				    'fiber_qtd'=>$row['fiber_qtd'],
				    'fiber_unit'=>$row['fiber_unit'],
				    'energy_kcal'=>$row['energy_kcal'],
				    'energy_kj'=>$row['energy_kj']);
                $inc++;
            }
            $response['error'] = false;
            $response['message'] = 'Ingrediente retornado com sucesso.';
            //enviando a resposta
            $response['data'] = $ingredientes;
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



