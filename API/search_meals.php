<?php

	include("config.php");

 	include(conexao);

 	$search_query = isset($obj['search_query']) ? $obj['search_query'] : "%";

 	if($search_query == null){

 		

 	}else{
 		$CheckSQL = "SELECT * from receita r where r.receita_nome like '%$search_query%'";

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