<?php

    include("../config.php");

    include(conexao);
    include(funcoes);
    
    $keys=array('user_id', 'date', 'refeicao_cod');
    
    for ($i = 0; $i < count($keys); $i++){
        if(!isset($obj[$keys[$i]]))
         {
              $response['error'] = true;
                $response['message'] = 'Required Filed Missed';
                $response['cod'] = 4;
                echo json_encode($response);
              return;
         }
    
    }
 
    // Populate ID from JSON $obj array and store into $ID variable.
    $user_id = $obj['user_id'];
    $date = $obj['date'];
    $refeicao_cod = $obj['refeicao_cod'];

    /*$user_id = 1;
    $date = '2021-12-03';
    $refeicao_cod = 1;*/
 
    //Fetching the selected record as per ID.
    $stmt = $mysqli->prepare("SELECT v.receita_id, v.udm_receita_id, v.receita_nome, v.receita_kcal, v.categorias_receita FROM v_userdiameal v WHERE
    v.usuario_id = ? AND v.user_dia_data = ? AND v.momento_id = ? ");
    $stmt->bind_param("sss", $user_id, $date, $refeicao_cod);
    
    if($stmt->execute()){
        $stmt->store_result();
        if($stmt->num_rows >= 1){
            $refeicao = [];
            $inc = 0;
            $stmt->bind_result($receita_id, $udm_receita_id, $receita_nome, $receita_kcal, $categorias_receita);
            $stmt->fetch();

            $stmt->execute();
            $result = $stmt->get_result();
            while ($row = $result->fetch_assoc()) {
                $refeicao[] = array('receita_id'=>$row["receita_id"],
                     'udm_receita_id' => $row['udm_receita_id'],
                     'receita_nome'=>$row["receita_nome"],
                     'receita_kcal'=>$row["receita_kcal"],
                     'refeicao_categorias'=>$row["categorias_receita"]);
                $inc++;
            }
            $response['error'] = false;
            $response['cod'] = 1;
            $response['message'] = 'Receitas retornadas com sucesso.';
            //enviando a resposta
            $response['data'] = $refeicao;
            $stmt->close();
        }else{
            $response['error'] = false;
            $response['cod'] = 2;
            $response['message'] = 'Nao existe nada registrado aqui.';
            $response['data'] = null;
        }
    }else{
        $response['error'] = true;
        $response['cod'] = 3;
            $response['message'] = 'Erro no retorno da data';
            $stmt->close();
    }

    echo json_encode($response);

 ?>