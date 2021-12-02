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
 
    //Fetching the selected record as per ID.
    $stmt = $mysqli->prepare("SELECT v.receita_id, v.receita_nome, v.receita_kcal FROM v_userdiameal v WHERE
    v.usuario_id = ? AND v.user_dia_data = ? AND v.momento_id = ? ");
    $stmt->bind_param("sss", $user_id, $date, $refeicao_cod);
    
    if($stmt->execute()){
        $stmt->store_result();
        if($stmt->num_rows == 1){
            $stmt->bind_result($receita_id, $receita_nome, $receita_kcal);
            $stmt->fetch();
            $refeicao = array('receita_id'=>$receita_id,
                     'receita_nome'=>$receita_nome,
                     'receita_kcal'=>$receita_kcal);
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