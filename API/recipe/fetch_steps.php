<?php
	include("../config.php");
	
	include(conexao);
	
	$keys=array('receita_id');
	
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
	
	$receita_id = $obj['receita_id'];
	
	
	// DADOS PARA TESTE
	/*$receita_id = 1;
	$stepnum = 1;
	$stepdesc = "descricao";*/


	//FIM DOS DADOS PARA TESTE
	
	/*$stmt = $mysqli->prepare("INSERT INTO receita_passos (receita_id, rp_numero, rp_desc) VALUES (?,?,?)");
	$stmt->bind_param("sss", $receita_id, $stepnum, $stepdesc);
		
		//if the recipe is successfully added to the database
	if($stmt->execute()){*/
	
		//fetching the user back
		$select = $mysqli->prepare("SELECT receita_id, rp_numero, rp_desc FROM receita_passos WHERE receita_id = ? ORDER BY rp_numero asc");
		$select->bind_param("s",$receita_id);
		if($select->execute()){
			$select->bind_result($receita_id, $stepnum, $stepdesc);
			$select->store_result();
			$select->fetch();
			if($select->num_rows()>=1){
				$steps = [];
	            $inc = 0;
	            $select->execute();
	            $result = $select->get_result();
	            while ($row = $result->fetch_assoc()) {
	            	$steps[] = array(
	                	'receita_id'=>$row['receita_id'],
	                    'rp_numero'=>$row['rp_numero'],
		 				'rp_desc'=>$row['rp_desc']);
	                $inc++;
	            }
	            $select->close();
		
				//adding the user data in response
				$response['error'] = false;
				$response['message'] = 'Ingrediente adicionado com sucesso!';
				$response['data'] = $steps;

			}else{
				$response['error'] = true;
				$response['message'] = "Não foi possível selecionar os dados";
			}

		}else{

			$response['error'] = true;
			$response['message'] = 'Passo não adicionado!';

		}
	
	/*}else{
		$response['error'] = true;
		$response['message'] = 'Erro ao adicionar o ingrediente na receita.';
		$stmt->close();
	}*/
	
	echo json_encode($response, JSON_UNESCAPED_UNICODE);


?>