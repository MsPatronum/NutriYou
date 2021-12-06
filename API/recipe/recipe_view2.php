<?php

    include("../config.php");

    include(conexao);
    include(funcoes);
    
    /*$keys=array('receita_id');
    
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
    $receita_id = $obj['receita_id'];*/

    $receita_id = 1;
 
    ////////////////////////// DEALHES DA RECEITA/////////////////////
    $receita_detalhes = $mysqli->prepare("
        SELECT 
            v.receita_id, v.receita_nome, 
            v.receita_desc, v.receita_porcoes, v.receita_tempo_preparo, 
            v.rn_nivel, v.momento, 
            v.humidity_qtd, v.humidity_unit,
            v.protein_qtd,v.protein_unit, 
            v.lipid_qtd, v.lipid_unit,
            v.carbohydrate_qtd, v.carbohydrate_unit, 
            v.fiber_qtd, v.fiber_unit,
            v.energy_kcal, v.energy_kj 
        FROM 
            view_receita v 
        WHERE
           v.receita_id = ? ");
    $receita_detalhes->bind_param("s", $receita_id);
    
    //Se executar
    if($receita_detalhes->execute()){
        //guardar resultado
        $receita_detalhes->store_result();
        //verificando o número de linhas
        if($receita_detalhes->num_rows == 1){
            //se o número de linhas for 1, então guardar os resultados em variáveis
            $receita_detalhes->bind_result(
                $receita_id,
                $receita_nome,
                $receita_desc,
                $receita_porcoes,
                $receita_tempo_preparo,
                $rn_nivel,
                $momento,
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
                $energy_kj
            );
            
            $receita_detalhes->fetch();
            //adicionando as informações da receita em um array
            $info_receita = array(
                'receita_id'=>$receita_id,
                'receita_nome'=>$receita_nome,
                'receita_desc'=>$receita_desc,
                'receita_porcoes'=>$receita_porcoes,
                'receita_tempo_preparo'=>$receita_tempo_preparo,
                'rn_nivel'=>$rn_nivel,
                'momento'=>$momento,
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
                'energy_kj'=>$energy_kj
            );

        //////////////////////// INGREDIENTES DA RECEITA///////////////////////
            
            //PREPARANDO SQL
            $receita_ingredientes = $mysqli->prepare(
                "SELECT 
                    v.receita_id, 
                    v.ingredientes_id, 
                    v.ingredientes_desc, 
                    v.receita_ingredientes_qtd,
                    v.ingredientes_base_qtd,
                    v.ingredientes_base_unity
                FROM 
                    v_receita_ingredientes v 
                WHERE 
                    v.receita_id = ?"
            );
            $receita_ingredientes->bind_param("s", $receita_id);







            

            
        
        $response['error'] = false;
        $response['cod'] = 1;
        $response['message'] = 'Receitas retornadas com sucesso.';
        //enviando a resposta
        $response['info_receita'] = $info_receita;
        //$response['passos'] = $passos;
        //$response['ingredientes'] = $ingredientes;
        //$response['imagens'] = $imagens;
        $receita_detalhes->close();

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
            $receita_detalhes->close();
    }

    echo json_encode($response, JSON_UNESCAPED_UNICODE);

?>