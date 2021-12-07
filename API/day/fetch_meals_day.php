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
                echo json_encode($response);
              return;
         }
    
    }
 
    // Populate ID from JSON $obj array and store into $ID variable.
    $user_id = $obj['user_id'];
    $date = $obj['date'];
    $refeicao_cod = $obj['refeicao_cod'];
 
    //Fetching the selected record as per ID.
    $stmt = $mysqli->prepare("SELECT GROUP_CONCAT(v.receita_nome SEPARATOR ', ') AS receitas, v.momento_kcal FROM v_userdiameal v WHERE v.usuario_id = ? AND v.user_dia_data = ? AND v.momento_id = ? ");
    $stmt->bind_param("sss", $user_id, $date, $refeicao_cod);
    

    if($stmt->execute()){
        $stmt->store_result();
        if($stmt->num_rows == 1){
            $stmt->bind_result($receitas, $momento_kcal);
            $stmt->fetch();
            $refeicao = array('receitas'=>$receitas,
                     'momento_kcal'=>$momento_kcal);
            $response['error'] = false;
            $response['message'] = 'Receitas retornadas com sucesso.';
            //enviando a resposta
            $response['data'] = $refeicao;
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