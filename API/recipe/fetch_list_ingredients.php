<?php

	include("..\config.php");

 	include(conexao);
 	include(funcoes);

 	$search_query = isset($obj['search_query']) ? $obj['search_query'] : "%";
 	$search_query = tirarAcentos(strtolower($search_query));


 	if($search_query == null){

 		

 	}else{
 		$CheckSQL = "
 		SELECT 	v.ingredientes_id,
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
		where lower(v.ingredientes_desc) like '%$search_query%' LIMIT 10";

	 	$result = $mysqli->query($CheckSQL);

		if($result->num_rows >0) {

			while($row[] = $result->fetch_assoc()) {
				$Item = $row;
				$json = json_encode($Item, JSON_NUMERIC_CHECK);
			}

		}else{
			echo "No Results Found";
		}

 	}

	echo $json;


?>